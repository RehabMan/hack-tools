#!/bin/bash

#set -x

unpatched=/System/Library/Extensions

echo "Type your password if requested (to mount EFI partition, and to patch $unpatched/AppleHDA.kext binary)"

# AppleHDA patching function
function prepatchAppleHDAbinary()
{
    echo "Patching $unpatched/AppleHDA.kext..."
    local EFI=$("$(dirname ${BASH_SOURCE[0]})"/mount_efi.sh)
    local TOOLS="$(dirname ${BASH_SOURCE[0]})"

# patch binary using AppleHDA patches in config.plist/KernelAndKextPatches/KextsToPatch
    local bin=$unpatched/AppleHDA.kext/Contents/MacOS/AppleHDA
    local config="$EFI"/EFI/CLOVER/config.plist
    echo $config
    for ((patch=0; 1; patch++)); do
        comment=`/usr/libexec/PlistBuddy -c "Print :KernelAndKextPatches:KextsToPatch:$patch:Comment" "$config" 2>&1`
        if [[ "$comment" == *"Does Not Exist"* ]]; then
            break
        fi
        name=`/usr/libexec/PlistBuddy -c "Print :KernelAndKextPatches:KextsToPatch:$patch:Name" "$config" 2>&1`
        if [[ "$name" == "com.apple.driver.AppleHDA" ]]; then
            disabled=`/usr/libexec/PlistBuddy -c "Print :KernelAndKextPatches:KextsToPatch:$patch:Disabled" "$config" 2>&1`
            if [[ "$disabled" != "true" ]]; then
                printf "Comment: %s\n" "$comment"
                find=`/usr/libexec/PlistBuddy -x -c "Print :KernelAndKextPatches:KextsToPatch:$patch:Find" "$config" 2>&1`
                repl=`/usr/libexec/PlistBuddy -x -c "Print :KernelAndKextPatches:KextsToPatch:$patch:Replace" "$config"`
                find=$([[ "$find" =~ \<data\>(.*)\<\/data\> ]] && echo ${BASH_REMATCH[1]})
                repl=$([[ "$repl" =~ \<data\>(.*)\<\/data\> ]] && echo ${BASH_REMATCH[1]})
                find=`echo $find | base64 --decode | xxd -p | tr '\n' ' '`
                repl=`echo $repl | base64 --decode | xxd -p | tr '\n' ' '`
                sudo "$TOOLS"/binpatch "$find" "$repl" $bin
            fi
        fi
    done

    echo "Done."
}

# patch the binary
prepatchAppleHDAbinary

# update kernel cache
sudo touch /System/Library/Extensions && sudo kextcache -u /
