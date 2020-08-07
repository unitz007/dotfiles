#!/bin/bash

RED='\033[00;31m'
GREEN='\033[00;32m'

# function prints result of test in terminal
function result_print {
  if [ "$1" == "-s" ]; then
    echo -e "$2: ${GREEN}PASSED"
  elif [ "$1" == "-f" ]; then
    echo -e "$2: ${RED}FAILED"
  fi
}