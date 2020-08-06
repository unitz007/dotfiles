#!/bin/bash

# update & upgrade
apt-get update -y
apt-get upgrade -y

# run installation script
source install.sh