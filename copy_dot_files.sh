#!/bin/bash

# checks if file exist
# file to be checked is passed as first argument
function file_exist {
  ret_val=0
  if [ -f "$1" ]; then
    ret_val=1
  else
    ret_val=0
  fi
  return $ret_val
}

# copies dot files
# first arg ($1) -> file to be checked
# second arg ($2) -> file to be copied
# third arg ($3) -> directory to copy file to
function copy_dot_files {
  file_exist "$1"
  if [ $ret_val -eq 1 ]; then
    mv "$1" "$1-backup"
    cp "$2" "$3"
  else
    cp "$2" "$3"
  fi
}

# config.fish file
copy_dot_files "$HOME"/.config/fish/config.fish ./fish/config.fish "$HOME"/.config/fish/