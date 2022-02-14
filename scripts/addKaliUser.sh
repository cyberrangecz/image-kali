#!/bin/sh -x

# add user kali with password kali, set sudo
sudo useradd -p '$6$MgXsM45n54LLBS$hAWz9IhWUmJsXBWmmACKRUkuC5I.gMhvtqr7HFVXfehave2OddmrvdLJUUzu0VSI2K9w2ezj/tvHeICDkkbxH1' --create-home --shell /bin/zsh kali
echo "kali  ALL=(ALL)  NOPASSWD: ALL" | sudo tee /etc/sudoers.d/kali > /dev/null
sudo sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

