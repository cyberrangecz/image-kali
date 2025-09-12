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

# install rsyslog
sudo apt-get -y install rsyslog

# install and configure chrony
sudo apt-get -y install chrony
sudo sed -i 's/pool .*/pool 0.pool.ntp.org iburst/' /etc/chrony/chrony.conf
sudo systemctl enable chrony
sudo systemctl start chrony

# never blank, put to sleep or switch off monitor
# for current user
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0

# for all new users
sudo apt-get -y install xmlstarlet
sudo xmlstarlet ed --inplace -s '/channel/property' -t elem -n property /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property/property[last()]' -t attr -n name -v dpms-enabled /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property/property[last()]' -t attr -n type -v bool /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property/property[last()]' -t attr -n value -v false /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property' -t elem -n property /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property/property[last()]' -t attr -n name -v blank-on-ac /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property/property[last()]' -t attr -n type -v int /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
sudo xmlstarlet ed --inplace -s '/channel/property/property[last()]' -t attr -n value -v 0 /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml

# Fix cloud-init
sudo mkdir -p /etc/systemd/system/cloud-init-main.service.d
sudo tee /etc/systemd/system/cloud-init-main.service.d/override.conf << EOF
[Unit]
Wants=network-pre.target
Before=sysinit.target
EOF

sudo systemctl daemon-reload
