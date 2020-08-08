#!/bin/bash

# imports scripts

RED='\033[00;31m'
GREEN='\033[00;32m'

# function prints result of test in terminal
function result_print {
  if [ "$1" == "-s" ]; then
    echo -e "$2: ${GREEN}FOUND"
  elif [ "$1" == "-f" ]; then
    echo -e "$2: ${RED}MISSING"
    exit
  fi
}

# file check function
_file_check_() {
  for arg in "$@"
  do
    if [ -f "$arg" ]; then
        result_print -s "$arg"
      else
        result_print -f "$arg"
    fi
  done
}

# test _file_check_ function
function test_file_check {
  _file_check_ ./fish/config.fish # test files in fish directory
  _file_check_  ./bash/.bashrc ./bash/.bash_aliases # check files in bash directory
#  _file_check_ ./git/.gitconfig
}

# invoke test_file_check
test_file_check