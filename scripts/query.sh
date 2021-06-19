#!/bin/sh

function yes_no
{
  read -p "$1" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}
