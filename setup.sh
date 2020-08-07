#!/bin/bash

# update & upgrade
apt-get update -y
apt-get upgrade -y

# run installation script
source install.sh

# move dotfiles
source move_dot_files.sh