#!/bin/bash

# imports scripts

RED='\033[00;31m'
GREEN='\033[00;32m'

# function prints result of test in terminal
function result_print {
  if [ "$1" == "-s" ]; then
    echo -e "$2: ${GREEN}PASSED"
  elif [ "$1" == "-f" ]; then
    echo -e "$2: ${RED}FAILED"
    exit
  fi
}

# file check function
_file_check_() {
    ret_val=0
    if [ -f "$1" ]; then
        result_print -s "$1"
      else
        result_print -f "$1"
    fi

}

# test _file_check_ function
function test_file_check {
  _file_check_ ../fish/config.fish # calls _file_check_ function from move_dot_files.sh
}

# invoke test_file_check
test_file_check