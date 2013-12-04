#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

mkdir /usr/share/solr
unzip /vagrant/files/apache-solr-3.6.2/apache-solr-3.6.2.war -d /usr/share/solr
sudo ln -s /usr/share/solr /usr/share/jetty/webapps/solr
echo 'Installed solr'

echo  "NO_START=0" >> /etc/default/jetty
echo  "JETTY_HOST=0.0.0.0" >> /etc/default/jetty
echo  "JAVA_OPTIONS=\"-Dsolr.solr.home=/usr/share/solr $JAVA_OPTIONS\"" >> /etc/default/jetty
echo  "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /etc/default/jetty
echo 'Configured Jetty'

cp /vagrant/files/solr_config/solr.xml /usr/share/solr/solr.xml
mkdir -p /var/lib/solr/instance1/data
chown -R jetty:jetty /var/lib/solr/
chown -R jetty:jetty /usr/share/solr
mkdir -p /usr/share/solr/instance1
cp -r /vagrant/files/solr_config/conf /usr/share/solr/instance1/
service jetty restart
echo 'Configured solr'
