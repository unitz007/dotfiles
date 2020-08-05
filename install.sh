#!/bin/bash

# Note: Run script with sudo

# update & upgrade
apt-get update --y && apt-get upgrade --y
##########################################################################
#                               TOOLS                                    #
##########################################################################
# install curl                                                           #
apt-get install curl --y                                                 #
# install sdkman                                                         #
curl -s "https://get.sdkman.io" | bash                                   #
# shellcheck disable=SC1090                                              #
# load sdkman                                                            $
source "$HOME/.sdkman/bin/sdkman-init.sh"                                #
# install git                                                            #
apt-get install git --y                                                  #
# heroku                                                                 #
snap install --classic heroku                                            #
# install snap                                                           #
apt-get install snapd --y                                                #
# docker                                                                 #
snap install docker                                                      #
# fish shell                                                             #
apt-get install fish --y                                                 #
# tmux (terminal multiplexer)                                            #
apt-get install tmux --y                                                 #
##########################################################################
#                         PROGRAMMING LANGUAGE(S)                        #
##########################################################################
# install Java                                                           #
apt-get install openjdk-11-jdk --y                                       #
# install Rust                                                           #
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh           #
##########################################################################
#                         BUILD TOOLS & PACKAGE MANAGERS                 #
##########################################################################
# Install build tools                                                    #
apt-get install maven --y                                                #
# install gradle                                                         #
sdk install gradle 6.5.1                                                 #
##########################################################################
#                               FRAMEWORK(S)                             #
##########################################################################
# install spring boot                                                    #
sdk install springboot                                                   #
# install angular                                                        #
npm install -g @angular/cli                                              #
# install Node                                                           #
apt-get install nodejs                                                   #
##########################################################################
#                                 IDE(S)                                 #
##########################################################################
# install intelliJ IDEA                                                  #
snap install intellij-idea-community --classic                           #
# install vscode                                                         #
snap install code --classic                                              #
##########################################################################
#                               DATABASE(S)                              #
##########################################################################
# mysql                                                                  #
apt-get install mariadb-server --y                                       #
mysql_secure_installation                                                #
##########################################################################