#!/bin/sh -x

# add user vagrant with password vagrant, set sudo, add public ssh key
sudo useradd -p '$1$9bp.cPKY$BeaZIuXT4PyfJBnTu74c4.' --uid 900 --create-home --shell /bin/zsh vagrant
echo "vagrant  ALL=(ALL)  NOPASSWD: ALL" | sudo tee /etc/sudoers.d/vagrant > /dev/null
sudo sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sudo mkdir -p /home/vagrant/.ssh
sudo chmod 0700 /home/vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" | sudo tee /home/vagrant/.ssh/authorized_keys > /dev/null
sudo chmod 0600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant
