#!/bin/bash

mkdir ~/workspace
cd ~/workspace

## Download and run RVM
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

rvm install ruby-1.9.3

## Teriminal Preferences - Select "Run Command as Login Shell" option Exit and reopen terminal
ruby -v
rvm use --default ruby-1.9.3

gem install bundler

git clone git@github.com:arguslab/ancor.git
cd ancor
bundle install

echo 'Now setup the ANCOR configuration file using the example in "config/ancor.yml.example"'
echo 'Afterwards run "bin/setup-mcollective"'
echo 'In case of running the terminal in a GUI: "Run command as login shell" should be enabled'
