#!/bin/bash
set -e

export http_proxy="http://172.17.0.6:3128"
export DEBIAN_FRONTEND=noninteractive

WORKING_PATH=$PWD

PL_RELEASE="puppetlabs-release-precise.deb"
PL_RELEASE_URL="http://apt.puppetlabs.com/$PL_RELEASE"
RMQ_KEY_URL="http://www.rabbitmq.com/rabbitmq-signing-key-public.asc"
ANCOR_PUPPET_URL="https://github.com/arguslab/ancor-puppet.git"
PUPPET_VERSION="3.4.2-1puppetlabs1"
MCO_VERSION="2.4.1-1puppetlabs1"

cp hosts /etc/hosts

## Install basic tools
apt-get update
apt-get install -y -q curl git vim htop

## RabbitMQ repository
echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
curl $RMQ_KEY_URL | apt-key add -

## Puppetlabs repository
curl -O $PL_RELEASE_URL
dpkg -i $PL_RELEASE
rm $PL_RELEASE

set -x

apt-get update
apt-get install -y -q puppet=$PUPPET_VERSION \
    puppet-common=$PUPPET_VERSION \
    puppetmaster=$PUPPET_VERSION \
    puppetmaster-common=$PUPPET_VERSION \
    puppet-dashboard \
    mcollective=$MCO_VERSION \
    mcollective-client=$MCO_VERSION \
    mcollective-common=$MCO_VERSION \
    ruby-stomp rabbitmq-server \
    mysql-server mongodb-server redis-server \
    mcollective-puppet-agent

# Stop and disable the puppetmaster service, use apache2 + passenger instead
service puppetmaster stop
service puppet-dashboard stop
update-rc.d -f puppetmaster remove
update-rc.d -f puppet-dashboard remove

## Enable some required and optional RabbitMQ plugins
rabbitmq-plugins enable rabbitmq_stomp rabbitmq_management rabbitmq_tracing rabbitmq_federation_management
service rabbitmq-server restart

## Download the management CLI tool from the local RabbitMQ management server
curl --no-proxy "" --retry 5 -O http://localhost:15672/cli/rabbitmqadmin
chmod +x rabbitmqadmin
mv rabbitmqadmin /usr/local/bin

## Setup the necessary structures on RabbitMQ for MCollective
rabbitmqadmin declare vhost name=/mcollective
rabbitmqadmin declare user name=mcollective password=marionette tags=administrator
rabbitmqadmin declare permission vhost=/mcollective user=mcollective configure=".*" write=".*" read=".*"
rabbitmqadmin declare exchange -u mcollective -p marionette -V /mcollective name=mcollective_broadcast type=topic
rabbitmqadmin declare exchange -u mcollective -p marionette -V /mcollective name=mcollective_directed type=direct

cp mcollective/client.cfg /etc/mcollective/client.cfg
cp mcollective/server.cfg /etc/mcollective/server.cfg

service mcollective restart

# mco returns a non-zero exit code.. fine
set +e
mco ping
set -e

# Configure the Puppet master with Hiera and the ancor-puppet repository
rm -r /etc/puppet
git clone $ANCOR_PUPPET_URL /etc/puppet
/etc/puppet/install-modules

cp hiera.yaml /etc/hiera.yaml
cp global.yaml /var/lib/hiera
gem install hiera-http

# Configure Puppet Dashboard
Q1="CREATE DATABASE dashboard CHARACTER SET utf8;"
Q2="CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'dashboard';"
Q3="GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';"
Q4="FLUSH PRIVILEGES;"

mysql -u root -e "$Q1 $Q2 $Q3 $Q4"

cp database.yml /etc/puppet-dashboard/database.yml
cp puppet-dashboard /etc/default/puppet-dashboard

cd /usr/share/puppet-dashboard && RAILS_ENV=production rake db:migrate && cd $WORKING_PATH

service puppet-dashboard-workers restart

# Setup Puppet to use Passenger
a2enmod ssl headers

RACK_PATH=/usr/share/puppet/rack

mkdir -p $RACK_PATH/public $RACK_PATH/tmp
cp /usr/share/puppet/ext/rack/config.ru $RACK_PATH
chown puppet:puppet $RACK_PATH/config.ru

## TODO In httpd 2.4 and later, this file should end in ".conf"
cp vhost-puppetmaster.conf /etc/apache2/sites-available/puppetmaster
cp vhost-puppet-dashboard.conf /etc/apache2/sites-available/puppet-dashboard
a2ensite puppetmaster puppet-dashboard
service apache2 restart

puppet agent -t
