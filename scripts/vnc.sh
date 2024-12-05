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
sudo tee -a /etc/polkit-1/rules.d/colord.rules << EOF
polkit.addRule(function(action, subject) {
    if (action.id.startsWith("org.freedesktop.color-manager.")) {
        return polkit.Result.YES;
    }
});

EOF
