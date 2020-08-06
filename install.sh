#!/bin/bash

# Note: Run script with sudo

##########################################################################
#                               TOOLS                                    #
##########################################################################
# install curl                                                           #
apt-get install curl -y                                                 #
# install snap                                                           #
apt-get install snapd -y                                                #
# install sdkman                                                         #
curl -s "https://get.sdkman.io" | bash                                   #
# shellcheck disable=SC1090                                              #
# load sdkman                                                            $
source "$HOME/.sdkman/bin/sdkman-init.sh"                                #
# install git                                                            #
apt-get install git -y                                                   #
# heroku                                                                 #
snap install --classic heroku                                            #
# docker                                                                 #
snap install docker                                                      #
# fish shell                                                             #
apt-get install fish -y                                                  #
# tmux (terminal multiplexer)                                            #
apt-get install tmux -y                                                  #
# ssh                                                                    #
apt install openssh-server -y                                            #
##########################################################################
#                         PROGRAMMING LANGUAGE(S)                        #
##########################################################################
# install Java                                                           #
apt-get install openjdk-11-jdk -y                                        #
# install Rust                                                           #
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh           #
##########################################################################
#                         BUILD TOOLS & PACKAGE MANAGERS                 #
##########################################################################
# Install build tools                                                    #
apt-get install maven -y                                                 #
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
apt-get install nodejs -y                                                #
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