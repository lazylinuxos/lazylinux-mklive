#!/usr/bin/env bash

if [[ "$#" -lt 2 ]]; then
  echo "Error: No argument provided"
  echo "Usage: $0 <desktop_environment> <path_to_img>"
  exit 1
fi

de="$1"
path="$2"

yes | ./mkiso.sh \
    -a "x86_64" \
    -b "$de" \
    -r https://github.com/lazylinuxos/lazy-repo/releases/latest/download \
    -r https://repo-default.voidlinux.org/current/nonfree \
    -v "linux6.19" \
    -o "$path"