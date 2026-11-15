#!/usr/bin/env bash

if [[ "$#" -lt 1 ]]; then
  echo "Error: No argument provided"
  exit 1
fi

de="$1"
path="lazylinux-$de-x86_64-$(date +%Y%m%d).iso"

yes | ./mkiso.sh \
    -a "x86_64" \
    -b "$de" \
    -P ./common/extra.packages \
    -P ./profiles/$de/extra.packages \
    -r https://github.com/lazylinuxos/lazy-repo/releases/latest/download \
    -r https://repo-default.voidlinux.org/current/nonfree \
    -r https://github.com/xlibre-void/xlibre/releases/latest/download \
    -r https://github.com/sonicde-void/sonicde-void/releases/latest/download \
    -- -C "live.autologin" -v "linux-mainline" -o "$path" -I ./common/ -I ./profiles/$de/
