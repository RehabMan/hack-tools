#!/bin/bash
#set -x

# script to create LiluFriend from a template and Lilu dependencies in /L/E or /S/L/E

plbuddy="/usr/libexec/PlistBuddy"

function get_plist_property
# $1 plist path
# $2 property path
{
    local property=$($plbuddy -c "Print $2" "$1" 2>&1)
    if [[ "$property" == *"Does Not Exist"* ]]; then
        echo "__property_not_found__"
    else
        echo "$property"
    fi
}

function delete_plist_property
# $1 plist path
# $2 property path
{
    $plbuddy -c "Delete $2" "$1" >/dev/null 2>&1
}

function set_plist_string_property
# $1 plist path
# $2 property path
# $3 property value
{
    delete_plist_property "$1" "$2"
    $plbuddy -c "Add '$2' string" "$1"
    $plbuddy -c "Set '$2' '$3'" "$1"
}

function check_bundlelibraries
# $1 Info.plist to check OSBundleLibraries for as.vit9696.Lilu dependency
{
    local check=$(get_plist_property "$1" ":CFBundleIdentifier")
    if [[ "$check" == "__property_not_found__" ]]; then echo "NO" && exit; fi
    if [[ "$check" == "as.vit9696.Lilu" ]]; then echo "YES" && exit; fi
    if [[ "$check" == "com.apple.security.LiluFriend" || "$check" == "com.apple.security.LiluFriendLite" ]]; then echo "NO" && exit; fi
    check=$(get_plist_property "$1" ":OSBundleLibraries:as.vit9696.Lilu")
    if [[ "$check" != "__property_not_found__" ]]; then echo "YES"; else echo "NO"; fi
}

function add_dependency
# $1 kext path with Lilu dependency
# $2 LiluFriend kext path
{
    local plist="$1"/Contents/Info.plist
    local version=$(get_plist_property "$plist" ":OSBundleCompatibleVersion")
    if [[ "$version" == "__property_not_found__" ]]; then
        version=$(get_plist_property "$plist" ":CFBundleVersion")
    fi
    if [[ "$version" != "__property_not_found__" ]]; then
        local bundleid=$(get_plist_property "$plist" ":CFBundleIdentifier")
        if [[ "$bundleid" != "__property_not_found__" ]]; then
            echo " $kext: $bundleid $version"
            set_plist_string_property "$2/Contents/Info.plist" ":OSBundleLibraries:$bundleid" "$version"
        fi
    fi
}

function add_all_lilu_dependencies
# $1 is directory to search
# $2 is LiluFriend.kext destination
{
    for kext in $(echo "$1"/*.kext); do
        local check=$(check_bundlelibraries "$kext"/Contents/Info.plist)
        if [[ "$check" == "YES" ]]; then
            add_dependency "$kext" "$2"
        fi
        if [[ -e "$kext"/Contents/PlugIns ]]; then
            for plugin in $(echo $kext/Contents/PlugIns/*.kext); do
                local check=$(check_bundlelibraries "$plugin"/Contents/Info.plist)
                if [[ "$check" == "YES" ]]; then
                    add_dependency "$plugin" "$2"
                fi
            done
        fi
    done
}

function build_it
# $1 path to target LiluFriend.kext or LiluFriendLite.kext
{
    local minor_ver=$([[ "$(sw_vers -productVersion)" =~ [0-9]+\.([0-9]+) ]] && echo ${BASH_REMATCH[1]})
    # on 10.11 or later, no need to scan /S/L/E as hack kexts are installed to /L/E only
    if [[ $minor_ver -lt 11 ]]; then
        add_all_lilu_dependencies /System/Library/Extensions "$1"
    fi
    add_all_lilu_dependencies /Library/Extensions "$1"
}

# script entry
# $1 is template to use
# $2 is output kext name

if [[ "$1" == "" && "$2" == "" ]]; then
    "$0" "$(dirname ${BASH_SOURCE[0]})"/template_kexts/LiluFriendTemplate.kext LiluFriend.kext
    "$0" "$(dirname ${BASH_SOURCE[0]})"/template_kexts/LiluFriendLiteTemplate.kext LiluFriendLite.kext
    exit
fi

if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Creates a custom LiluFriend.kext or LiluFriendLite from a template"
    echo "based on the Lilu dependend kexts installed to /L/E and /S/L/E."
    echo "Usage:"
    echo "    $0 LiluFriendTemplate.kext LiluFriend.kext"
    echo "-OR-"
    echo "    $0"
    echo ""
    echo "Without parameters, both ./LiluFriend.kext and ./LiluFriendLite.kext are generated."
    exit
fi

echo Making "$2" from "$1"
rm -Rf "$2"
cp -R "$1" "$2"
build_it "$2"
