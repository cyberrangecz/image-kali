#!/bin/sh -x

# install ansible
DEBIAN_FRONTEND=noninteractive sudo apt-get -y install ansible

# fix networking issue
printf '\nauto eth0\niface eth0 inet dhcp\n\n' | sudo tee -a /etc/network/interfaces > /dev/null

