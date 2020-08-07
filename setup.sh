#!/bin/bash

# import scripts
. ./move_dot_files.sh

# update & upgrade
apt-get update -y
apt-get upgrade -y

# run installation script
sh install.sh

# move dotfiles
sh move_dot_files.sh