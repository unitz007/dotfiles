#!/bin/bash


# file check function
_file_check_() {
    ret_val=0
    if [ -f "$1" ]; then
      ret_val=1
    fi
    return $ret_val
}