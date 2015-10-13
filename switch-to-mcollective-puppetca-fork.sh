#!/bin/sh
set -x -e

MCO_PLUGINS=/usr/share/mcollective/plugins/mcollective
CLONE_PATH=/tmp/mcollective-puppetca-agent

rm -rf $CLONE_PATH
rm -rf $MCO_PLUGINS/agent/puppetca*
rm -rf $MCO_PLUGINS/util/puppetca*

git clone https://github.com/arguslab/mcollective-puppetca-agent.git $CLONE_PATH
cp -r $CLONE_PATH/agent $MCO_PLUGINS
cp -r $CLONE_PATH/util $MCO_PLUGINS

rm -r $CLONE_PATH

service mcollective restart
