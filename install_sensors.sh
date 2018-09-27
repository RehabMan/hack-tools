#!/bin/bash
#set -x

# include subroutines
DIR=$(dirname ${BASH_SOURCE[0]})
source "$DIR/_install_subs.sh"

warn_about_superuser
install_fakesmc_sensor_kexts
rebuild_kernel_cache

#EOF
