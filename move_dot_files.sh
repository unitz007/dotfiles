#!/bin/bash

file=$1
# file check function
function _file_check_ {
    if [ -f "$file" ]; then
      echo "$file exists."
    else
      echo "$file does not exist"
fi
}

# TESTS

# file exist test functionality

