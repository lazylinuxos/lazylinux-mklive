#!/bin/bash

sudo ./mkiso.sh \
    -b "xfce" \
    -r /hostdir/binpkgs \
    -r https://sourceforge.net/projects/lazylinux/files/repo \
    -r https://repo-default.voidlinux.org/current/nonfree