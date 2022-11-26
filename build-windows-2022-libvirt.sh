#!/bin/bash
cd /data
git clone https://github.com/rgl/windows-vagrant
cd windows-vagrant
#sed -i 's/wget/wget -4/g' Makefile
mkdir /data/tmp
export TMPDIR=/data/tmp
make build-windows-2022-libvirt
vagrant box add -f windows-2022-amd64 windows-2022-amd64-libvirt.box
#vagrant cloud auth login
#vagrant cloud publish goffinet/windows-2022-amd64 1.0.0 libvirt windows-2022-amd64-libvirt.box -d "windows-2022-amd64 libvirt based on https://github.com/rgl/windows-vagrant" --version-description "packer build" --release --short-description "windows-2022-amd64 libvirt packer build"
