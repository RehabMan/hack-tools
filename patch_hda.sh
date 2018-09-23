#!/bin/bash
#set -x

# include subroutines
DIR=$(dirname ${BASH_SOURCE[0]})
source "$DIR/_hda_subs.sh"

# Assumes layout plists, Platforms plist in Resources_$1

if [[ "$1" == "" ]]; then
    echo Usage: patch_hda.sh {codec}
    echo Example: patch_hda.sh ALC283
    exit
fi

createAppleHDAInjector "$1"
createAppleHDAInjector_HCD "$1"
createAppleHDAResources "$1"
createPatchedAppleHDA "$1"
