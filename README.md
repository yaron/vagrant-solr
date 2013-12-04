vagrant-solr
============

Vagrant scripts to get a solr server running for  a drupal search api site.

Create a clone, do a 'vagrant up' and you should be able to connect to http://localhost:8984/solr in your browser.

This has been tested with a debian 64 bit box as its base, and will install jetty from apt-get, solr 3.6.2 from the war file that is included in the repo and java-7-openjdk.
