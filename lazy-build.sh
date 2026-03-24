#!/bin/bash

sudo ./mkiso.sh \
    -a "x86_64" \
    -b "niri" \
    -r /hostdir/binpkgs \
    -r https://github.com/lazylinuxos/lazy-repo/releases/download/v1.0 \
    -r https://repo-default.voidlinux.org/current/nonfree