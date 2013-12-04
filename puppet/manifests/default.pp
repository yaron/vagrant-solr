## Begin Server manifest

if $server_values == undef {
  $server_values = hiera('server', false)
}

# Ensure the time is accurate, reducing the possibilities of apt repositories
# failing for invalid certificates
include '::ntp'

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

group { 'puppet': ensure => present }
group { 'www-data': ensure => present }

user { $::ssh_username:
  shell  => '/bin/bash',
  home   => "/home/${::ssh_username}",
  ensure => present
}

file { "/home/${::ssh_username}":
    ensure => directory,
    owner  => $::ssh_username,
}

# copy dot files to ssh user's home directory
exec { 'dotfiles':
  cwd     => "/home/${::ssh_username}",
  command => "cp -r /vagrant/files/dot/.[a-zA-Z0-9]* /home/${::ssh_username}/ && chown -R ${::ssh_username} /home/${::ssh_username}/.[a-zA-Z0-9]*",
  onlyif  => "test -d /vagrant/files/dot",
  require => User[$::ssh_username]
}

case $::osfamily {
  # debian, ubuntu
  'debian': {
    class { 'apt': }

    Class['::apt::update'] -> Package <|
        title != 'python-software-properties'
    and title != 'software-properties-common'
    |>

    ensure_packages( ['augeas-tools'] )
  }
  # redhat, centos
  'redhat': {
    class { 'yum': extrarepo => ['epel'] }

    Class['::yum'] -> Yum::Managed_yumrepo <| |> -> Package <| |>

    exec { 'bash_git':
      cwd     => "/home/${::ssh_username}",
      command => "curl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > /home/${::ssh_username}/.bash_git",
      creates => "/home/${::ssh_username}/.bash_git"
    }

    file_line { 'link ~/.bash_git':
      ensure  => present,
      line    => 'if [ -f ~/.bash_git ] ; then source ~/.bash_git; fi',
      path    => "/home/${::ssh_username}/.bash_profile",
      require => [
        Exec['dotfiles'],
        Exec['bash_git'],
      ]
    }

    file_line { 'link ~/.bash_aliases':
      ensure  => present,
      line    => 'if [ -f ~/.bash_aliases ] ; then source ~/.bash_aliases; fi',
      path    => "/home/${::ssh_username}/.bash_profile",
      require => [
        File_line['link ~/.bash_git'],
      ]
    }

    ensure_packages( ['augeas'] )
  }
}

case $::operatingsystem {
  'debian': {
    add_dotdeb { 'packages.dotdeb.org': release => $lsbdistcodename }
  }
}

if !empty($server_values['packages']) {
  ensure_packages( $server_values['packages'] )
}

define add_dotdeb ($release){
   apt::source { $name:
    location          => 'http://packages.dotdeb.org',
    release           => $release,
    repos             => 'all',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => '89DF5277',
    key_server        => 'keys.gnupg.net',
    include_src       => true
  }
}

