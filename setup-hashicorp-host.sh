#!/bin/bash
#https://github.com/rgl/xfce-desktop-vagrant/blob/master/provision-virtualization-tools.sh
# abort this script on errors.
#set -eux
#2h à la main

#- création d'un compte sudoer, mot de passe fort, clé ssh
#- authentification ssh par clé (uniquement à configurer)
#- installation et lancement fail2ban
#- installation et configuration firewall
#- password recovery et force des mots de passe
#- séparer flux de data

source /etc/os-release
if [ $ID == "ubuntu" ] && [ $VERSION_ID == "20.04" ] && [ $(id -u) -eq 0 ] ; then echo requirements matched ; else exit ; fi

# working with hetzner servers
interface=$(ip l show up | grep '^2:' | cut -f2 -d " " | sed 's/://')

hostnamectl set-hostname winpoc

# Prevent apt et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

# Firewall installation
if [ "$(sudo systemctl status firewalld > /dev/null 2>&1 ; echo $?)" != "0" ] ; then
apt update
apt install -y firewalld
firewall-cmd --permanent --zone=public --add-interface=$interface
firewall-cmd --reload
systemctl enable firewalld
fi

# Add vagrant user and group with ALL=(ALL) NOPASSWD:ALL sudo rights
if  grep -q "vagrant" <<< $(cat /etc/group) ; then
groupadd vagrant
fi
if  grep -q "vagrant" <<< $(cat /etc/passwd) ; then
useradd -m -d /home/vagrant -g vagrant -s /bin/bash vagrant
echo "vagrant     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vagrant
fi

# Install virtualization tools
apt update && apt -y upgrade
apt -y install \
qemu-kvm \
libvirt-dev \
virtinst \
virt-viewer \
libguestfs-tools \
virt-manager \
uuid-runtime \
curl \
linux-source \
libosinfo-bin \
genisoimage \
qemu-kvm \
xorriso \
libcdio-utils \
qemu-utils \
jq \
unzip \
build-essential \
libvirt-daemon-system \
dnsmasq \
p7zip-full \
vinagre \
spice-client-gtk \
git \
xauth lightdm-remote-session-freerdp2 \
software-properties-common

# Configure the security_driver to prevent errors alike (when using terraform):
#   Could not open '/var/lib/libvirt/images/terraform_example_root.img': Permission denied'
sed -i -E 's,#?(security_driver)\s*=.*,\1 = "none",g' /etc/libvirt/qemu.conf
systemctl restart libvirtd
# let the vagrant user manage libvirtd.
# see /usr/share/polkit-1/rules.d/60-libvirt.rules
usermod -aG libvirt vagrant

# install terraform.new
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# install terraform.
#terraform_version=1.0.10
#terraform_url="https://releases.hashicorp.com/terraform/$terraform_version/terraform_${terraform_version}_linux_amd64.zip"
#terraform_filename="$(basename $terraform_url)"
#wget -q $terraform_url
#unzip $terraform_filename
#install terraform /usr/local/bin
#rm terraform $terraform_filename
## install the libvirt provider.
#terraform_libvirt_provider_version=0.6.11
#terraform_libvirt_provider_url="/https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v${terraform_libvirt_provider_version}/terraform-provider-libvirt_${terraform_libvirt_provider_version}_linux_amd64.zip"
#terraform_libvirt_provider_filename="/tmp/$(basename $terraform_libvirt_provider_url)"
#wget -qO $terraform_libvirt_provider_filename $terraform_libvirt_provider_url
#su vagrant -c bash <<VAGRANT_EOF
#!/bin/bash
#set -euxo pipefail
#cd ~
#unzip $terraform_libvirt_provider_filename
#install -d ~/.terraform.d/plugins/linux_amd64
#install terraform-provider-libvirt ~/.terraform.d/plugins/linux_amd64/
#rm terraform-provider-libvirt
#VAGRANT_EOF
#rm $terraform_libvirt_provider_filename

# install Packer.
apt install -y unzip
packer_version=1.8.4
wget -q -O/tmp/packer_${packer_version}_linux_amd64.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip
unzip /tmp/packer_${packer_version}_linux_amd64.zip -d /usr/local/bin
# install useful packer plugins.
#wget -q -O/tmp/packer-provisioner-windows-update-linux.tgz https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.9.0/packer-provisioner-windows-update-linux.tgz
#tar xf /tmp/packer-provisioner-windows-update-linux.tgz -C /usr/local/bin
#chmod +x /usr/local/bin/packer-provisioner-windows-update
#rm /tmp/packer-provisioner-windows-update-linux.tgz

# install vagrant new
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-windows-update
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-windows-sysprep

# install Vagrant old
#vagrant_version=2.3.3
#wget -q -O/tmp/vagrant_${vagrant_version}_x86_64.deb https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb
#dpkg -i /tmp/vagrant_${vagrant_version}_x86_64.deb
#rm /tmp/vagrant_${vagrant_version}_x86_64.deb
## install useful vagrant plugins.
#apt install -y libvirt-dev gcc make
#su vagrant -c bash <<'VAGRANT_EOF'
##!/bin/bash
#set -eux
#cd ~
#CONFIGURE_ARGS='with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' vagrant plugin install vagrant-libvirt
#CONFIGURE_ARGS='with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' vagrant plugin install vagrant-windows-update
#CONFIGURE_ARGS='with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' vagrant plugin install vagrant-reload
#CONFIGURE_ARGS='with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' vagrant plugin install vagrant-windows-sysprep
#VAGRANT_EOF
## add support for smb shared folders.
## see https://github.com/hashicorp/vagrant/pull/9948
#pushd /opt/vagrant/embedded/gems/$vagrant_version/gems/vagrant-$vagrant_version
#wget -q https://github.com/hashicorp/vagrant/commit/ed7139fa1e896d0b84ed32180b72a647bf9f37eb.patch
#patch -p1 <ed7139fa1e896d0b84ed32180b72a647bf9f37eb.patch
#rm ed7139fa1e896d0b84ed32180b72a647bf9f37eb.patch
#popd
apt install -y samba smbclient
smbpasswd -a -s vagrant <<'EOF'
vagrant
vagrant
EOF
sudo bash -c 'cat >/etc/sudoers.d/vagrant-nfs-synced-folders' <<'EOF'
Cmnd_Alias VAGRANT_SMB_ADD = /usr/sbin/sharing -a * -S * -s * -g * -n *
Cmnd_Alias VAGRANT_SMB_REMOVE = /usr/sbin/sharing -r *
Cmnd_Alias VAGRANT_SMB_LIST = /usr/sbin/sharing -l
Cmnd_Alias VAGRANT_SMB_PLOAD = /bin/launchctl load -w /System/Library/LaunchDaemons/com.apple.smb.preferences.plist
Cmnd_Alias VAGRANT_SMB_DLOAD = /bin/launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist
Cmnd_Alias VAGRANT_SMB_DSTART = /bin/launchctl start com.apple.smbd
%admin ALL=(root) NOPASSWD: VAGRANT_SMB_ADD, VAGRANT_SMB_REMOVE, VAGRANT_SMB_LIST, VAGRANT_SMB_PLOAD, VAGRANT_SMB_DLOAD, VAGRANT_SMB_DSTART
EOF

cd

mkdir -p /data/images
cd /var/lib/libvirt
rm -rf images
ln -s /data/images images

# install the nfs server.
sudo apt install -y nfs-kernel-server

# enable password-less configuration of the nfs server exports.
sudo bash -c 'cat >/etc/sudoers.d/vagrant-nfs-synced-folders' <<'EOF'
Cmnd_Alias VAGRANT_EXPORTS_CHOWN = /bin/chown 0\:0 /tmp/*
Cmnd_Alias VAGRANT_EXPORTS_MV = /bin/mv -f /tmp/* /etc/exports
Cmnd_Alias VAGRANT_NFSD_CHECK = /etc/init.d/nfs-kernel-server status
Cmnd_Alias VAGRANT_NFSD_START = /etc/init.d/nfs-kernel-server start
Cmnd_Alias VAGRANT_NFSD_APPLY = /usr/sbin/exportfs -ar
%sudo ALL=(root) NOPASSWD: VAGRANT_EXPORTS_CHOWN, VAGRANT_EXPORTS_MV, VAGRANT_NFSD_CHECK, VAGRANT_NFSD_START, VAGRANT_NFSD_APPLY
EOF

usermod -a -G kvm,libvirt,libvirt-qemu,libvirt-dnsmasq,sambashare vagrant
chown -R vagrant:vagrant /data

## Install x2go
#add-apt-repository -y ppa:x2go/stable
#apt -y install xubuntu-desktop x2goserver x2goserver-xsession

#reboot
