#!/bin/sh -x

ISOPATH="$HOME/VBoxGuestAdditions.iso"

if [ ! -e "$ISOPATH" ]; then
    echo "Error: virtualbox guest additions ISO not found at $ISOPATH"
    exit 1
fi

# Mount virtualbox guest additions ISO and install
sudo mkdir -p /tmp/VBoxGuestAdditions
sudo mount -o loop,ro "$ISOPATH" /tmp/VBoxGuestAdditions
echo "yes" | sudo /tmp/VBoxGuestAdditions/VBoxLinuxAdditions.run --nox11

sudo rm "$ISOPATH"
sudo umount /tmp/VBoxGuestAdditions
sudo rmdir /tmp/VBoxGuestAdditions
