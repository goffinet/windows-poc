# Windows POC

Help tools to :

- install Hashicorp products with qemu/kvm Libvirt
- build https://github.com/rgl/windows-vagrant and https://github.com/rgl/ubuntu-vagrant Vagrant boxes for Libvirt
- launch the Windows AD/client lab with Vagrant/Libvirt https://github.com/rgl/windows-domain-controller-vagrant

## Setup your host

```bash
bash -x setup-hashicorp-host.sh
reboot
#ssh-keygen -b 4096 -t rsa -f /tmp/sshkey -q -N ""
```

```
curl https://raw.githubusercontent.com/vagrant-libvirt/vagrant-libvirt-qa/main/scripts/install.bash -o install-vagrant.bash
bash -x install-vagrant.bash
vagrant plugin install vagrant-windows-update
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-windows-sysprep

```

## Build Windows 2022 and Ubuntu 20.04 images

```bash
bash -x build-windows-2022-libvirt.sh
bash -x build-ubuntu-amd64-libvirt.sh
```

## Launch the fixed windows-domain-controller-vagrant

[windows-domain-controller-vagrant](https://github.com/rgl/windows-domain-controller-vagrant)

```bash
su - vagrant
bash -x winpoc.sh
```


## Credits

- https://github.com/rgl/windows-vagrant
- https://github.com/rgl/ubuntu-vagrant
- https://github.com/rgl/xfce-desktop-vagrant
- https://github.com/dmacvicar/terraform-provider-libvirt
- https://github.com/rgl/windows-domain-controller-vagrant
