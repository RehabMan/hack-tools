#!/bin/bash
#set -x

# script to update LiluFriend.kext or LiluFriendLite.kext

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/_install_subs.sh

warn_about_superuser

if [[ ! -e "$KEXTDEST"/LiluFriend.kext && ! -e "$KEXTDEST"/LiluFriendLite.kext ]]; then
    remove_kext LiluFriendLite.kext
    remove_kext LiluFriend.kext
    _create_and_install_lilufriend "$(dirname ${BASH_SOURCE[0]})"/template_kexts/LiluFriendTemplate.kext LiluFriend.kext
    exit
fi

if [[ -e "$KEXTDEST"/LiluFriend.kext ]]; then
    "$(dirname ${BASH_SOURCE[0]})"/create_lilufriend.sh "$(dirname ${BASH_SOURCE[0]})"/template_kexts/LiluFriendTemplate.kext LiluFriend.kext
    remove_kext LiluFriendLite.kext
    remove_kext LiluFriend.kext
    install_kext LiluFriend.kext
    rebuild_kernel_cache
fi

if [[ -e "$KEXTDEST"/LiluFriendLite.kext ]]; then
    "$(dirname ${BASH_SOURCE[0]})"/create_lilufriend.sh "$(dirname ${BASH_SOURCE[0]})"/template_kexts/LiluFriendLiteTemplate.kext LiluFriendLite.kext
    remove_kext LiluFriend.kext
    remove_kext LiluFriendLite.kext
    install_kext LiluFriendLite.kext
    rebuild_kernel_cache
fi
