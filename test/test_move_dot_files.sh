#!/bin/bash

# imports scripts
. ../move_dot_files.sh
. ./utils.sh

# test _file_check_ function
function test_file_check {
  _file_check_ "test_file" # calls _file_check_ function from move_dot_files.sh
  # check if test_file exists
  # $ret_val = 1 if file exist or $ret_val = 0 if file does not exists
  if [ $ret_val -eq 1 ]; then
    result_print -s "${FUNCNAME[0]}"
  else
    result_print -f "${FUNCNAME[0]}"
  fi
}

# invoke test_file_check
test_file_check