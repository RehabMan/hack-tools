#!/bin/bash
#set -x

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/_hda_subs.sh

# Assumes layout plists, Platforms plist in Resources_$1

if [[ "$1" == "" ]]; then
    echo Usage: $0 {codec}
    echo Example: $0 ALC283
    exit
fi

createAppleHDAInjector "$1"
