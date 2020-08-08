#!/bin/bash

# test
source test.sh

# update & upgrade
apt-get update -y
apt-get upgrade -y

# run installation script
source install.sh

# move dotfiles
source copy_dot_files.sh