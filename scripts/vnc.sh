#!/bin/sh -x

# remove TightVNC
apt remove -y tightvncserver

# install TigerVNC
apt-get update
mkdir -p /var/log/apt/
apt-get install -y tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer

# configure xvnc.socket
sudo tee -a /etc/systemd/system/xvnc.socket << EOF

[Unit]
Description=XVNC Server on port 5900

[Socket]
ListenStream=5900
Accept=yes

[Install]
WantedBy=sockets.target

EOF

sudo tee -a  /etc/systemd/system/xvnc@.service << EOF

[Unit]
Description=Daemon for each XVNC connection

[Service]
ExecStart=-/usr/bin/Xvnc -inetd -query localhost -geometry 2000x1200 -once -SecurityTypes=None
User=nobody
StandardInput=socket
StandardError=syslog

EOF

# configure lightdm
sudo tee -a /etc/lightdm/lightdm.conf << EOF

[XDMCPServer]
enabled=true
port=177

EOF

# enable and start xvnc.socket
systemctl daemon-reload
systemctl enable xvnc.socket
systemctl start xvnc.socket

sudo systemctl restart lightdm.service

# Fix "Authentication is required to create a color managed device" popup
sudo ls -Rl /etc/polkit-1/
#sudo tee -a /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla << EOF
#[Allow Colord all Users]
#Identity=unix-user:*
#Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.#color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
#ResultAny=no
#ResultInactive=no
#ResultActive=yes
#
#EOF
