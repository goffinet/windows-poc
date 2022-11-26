#!/bin/bash
version=20.04
cd /data
git clone https://github.com/rgl/ubuntu-vagrant
git switch ${version}
cd ubuntu-vagrant
mkdir /data/tmp
export TMPDIR=/data/tmp
make build-libvirt
vagrant box add -f ubuntu-${version}-amd64 ubuntu-${version}-amd64-libvirt.box
#vagrant cloud auth login
#vagrant cloud publish goffinet/ubuntu-${version}-amd64 1.0.0 libvirt ubuntu-${version}-amd64-libvirt.box -d "ubuntu-${version}-amd64 libvirt" --version-description "packer build" --release --short-description "ubuntu-${version}-amd64 libvirt packer build"
