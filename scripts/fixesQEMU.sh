#!/bin/sh -x

# apt update
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
DEBIAN_FRONTEND=noninteractive sudo apt-get update
