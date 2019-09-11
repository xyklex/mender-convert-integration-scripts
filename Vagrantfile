# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true
  config.vm.provision "shell", inline: <<-SHELL
     curl -fsSL https://get.docker.com -o get-docker.sh
     sh get-docker.sh
     sudo usermod -aG docker vagrant
  SHELL
end
