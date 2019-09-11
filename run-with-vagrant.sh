#!/bin/sh
#
# Create the mender-convert integration binaries using Vagrant.
# This should (in theory) work on Windows and Mac
#

vagrant up --provider virtualbox
vagrant ssh -- 'bash -c "cd /vagrant && /vagrant/docker-create-integration-binaries"'
vagrant destroy -f
