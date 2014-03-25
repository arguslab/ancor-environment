#!/bin/bash
WORKSPACE_PATH=$HOME/workspace
ANCOR_PATH=$WORKSPACE_PATH/ancor

## Download and run RVM
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

rvm install ruby-1.9.3

## Teriminal Preferences - Select "Run Command as Login Shell" option Exit and reopen terminal
ruby -v
rvm use --default ruby-1.9.3

gem install bundler

# Clone and install dependencies
mkdir -p $WORKSPACE_PATH && cd $WORKSPACE_PATH
git clone https://github.com/arguslab/ancor.git $ANCOR_PATH
cd $ANCOR_PATH && bundle install

echo '=============================================================================================='
echo 'Now setup the ANCOR configuration file using the example in "config/ancor.yml.example"'
echo 'Afterwards run "bin/setup-mcollective"'
echo 'In case of running the terminal in a GUI: "Run command as login shell" should be enabled'
echo '=============================================================================================='
