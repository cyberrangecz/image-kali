#!/bin/bash -x

# set GRUB_TIMEOUT to 0
sudo sed -i "s/^GRUB_TIMEOUT=[0-9]*/GRUB_TIMEOUT=0/" /etc/default/grub
sudo update-grub

# disable root login using password
sudo passwd -l root

# disable ssh login using password
sudo sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config

# install resolvconf
sudo apt-get -y install resolvconf

# install and configure chrony
sudo apt-get -y install chrony
sudo sed -i 's/pool .*/pool 0.pool.ntp.org iburst/' /etc/chrony/chrony.conf
sudo systemctl enable chrony
sudo systemctl start chrony
