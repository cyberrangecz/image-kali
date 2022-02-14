#!/bin/sh -x

# install cloud support

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y cloud-init qemu-guest-agent cloud-guest-utils cloud-initramfs-growroot spice-vdagent

# copy custom cloud-init configuration (do not modify default apt source list)
sudo cp -f /tmp/cloud.cfg /etc/cloud/cloud.cfg

# delete default configuration
sudo rm -rf /etc/cloud/cloud.cfg.d

# enable cloud-init at boot time, disabled by standard Kali network service policy after installation
sudo systemctl enable cloud-init
sudo systemctl enable cloud-init-local.service
sudo systemctl enable cloud-final.service
sudo systemctl enable cloud-config.service
