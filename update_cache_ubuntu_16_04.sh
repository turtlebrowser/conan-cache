#!/bin/bash

UBUNTU_VERSION="16.04"

[ $# -eq 0 ] && { echo "Usage: $0 <full path to APPLICATION checkout>"; exit 1; }

./update_cache_linux.sh "$1" "$UBUNTU_VERSION"