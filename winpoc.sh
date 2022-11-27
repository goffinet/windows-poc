#!/bin/bash
#3h
vagrant box add windows-2022-amd64 https://app.vagrantup.com/goffinet/boxes/windows-2022-amd64/versions/1.0.0/providers/libvirt.box \
  && vagrant box add ubuntu-20.04-amd64 https://app.vagrantup.com/goffinet/boxes/ubuntu-22.04-amd64/versions/1.0.0/providers/libvirt.box
gh_username=rgl
git_dir=/data/windows-domain-controller-vagrant
git clone https://github.com/$gh_username/windows-domain-controller-vagrant $git_dir
cp patch $git_dir
cd $git_dir
git apply patch

# Install and configure vagrant plugins
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-windows-update
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-windows-sysprep

cd $git_dir
vagrant up
cd test-nodes
vagrant up
