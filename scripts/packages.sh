#!/bin/sh -x

# install cloud support

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y cloud-init qemu-guest-agent cloud-guest-utils cloud-initramfs-growroot spice-vdagent

# copy custom cloud-init configuration (do not modify default apt source list)
sudo cp -f /tmp/cloud.cfg /etc/cloud/cloud.cfg

# delete default configuration
sudo rm -rf /etc/cloud/cloud.cfg.d

# force enable cloud-init.target
sudo mkdir -p /etc/systemd/system/cloud-init.target.d
sudo tee /etc/systemd/system/cloud-init.target.d/override.conf << EOF
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cloud-init.target
