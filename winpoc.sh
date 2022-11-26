#!/bin/bash
#3h
vagrant box add windows-2022-amd64 https://app.vagrantup.com/goffinet/boxes/windows-2022-amd64/versions/1.0.0/providers/libvirt.box \
  && vagrant box add ubuntu-20.04-amd64 https://app.vagrantup.com/goffinet/boxes/ubuntu-22.04-amd64/versions/1.0.0/providers/libvirt.box
gh_username=rgl
git_dir=/data/windows-domain-controller-vagrant
git clone https://github.com/$gh_username/windows-domain-controller-vagrant $git_dir
sed -i 's/pt-PT/fr-FR/g' $git_dir/provision/*.ps1
sed -i 's/pt-PT/fr-FR/g' $git_dir/test-nodes/provision/*.ps1
sed -i "s|lv.keymap = 'pt'|lv.keymap = 'fr'|g" $git_dir/Vagrantfile
sed -i "s|lv.keymap = 'pt'|lv.keymap = 'fr'|g" $git_dir/test-nodes/Vagrantfile
patch $git_dir/Vagrantfile < ./patch1
patch $git_dir/test-nodes/Vagrantfile < ./patch2

# Install and configure vagrant plugins
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-windows-update
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-windows-sysprep

cd $git_dir
vagrant up
cd test-nodes
vagrant up
