#!/bin/sh

# Author: Brian Wilson <doc@wiltech.org>
# Project: Fulgur Linux
#
# This build script is responsible for building
# a configurable Fulgur Linux system. This script
# does not install the system or package in any
# way. Fulgur Linux is heavily based on Arch Linux, if run
# with the base profile selected, the live system IS Arch Linux
# as of now.

# Get architechure this script is running on
arch=$(uname -m)

# Path to the directory this script is running
# from. This script should always be in the project
# root.
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Directory where this script will do it's work
work_dir=/tmp/work.$$

# Directory where the root system will be built
build_dir=/mnt

# Location of the pacman.conf used to build the live system
pacman_conf=${work_dir}/pacman.conf

# Installation profile
install_profile="set-top-box"
profile_dir="${script_dir}/profile/${install_profile}"


# Source in utility scripts
source "${script_dir}/resources/util.sh"
source "${script_dir}/resources/configure.sh"

# Run configuration scripts to build partition
# table and set other system install variables
configure_system() {
    _msg_info "Running configuration..."
    
    _select_disk
    _select_partition_scheme
    #_select_hostname
    #_select_timezone
}

# Initialize the build enviornment
initialize() {
    _msg_info "Initializing build environment..."
    mkdir -p ${build_dir}

    _msg_info "Generating pacman.conf -> ${pacman_conf}..."

    local _cache_dirs
    _cache_dirs=($(pacman -v 2>&1 | grep '^Cache Dirs:' | sed 's/Cache Dirs:\s*//g'))
    sed -r "s|^#?\\s*CacheDir.+|CacheDir = $(echo -n ${_cache_dirs[@]})|g"\ 
        ${script_dir}/pacman.conf > ${pacman_conf}

    # Run pre-build profile hook if it exists
    if [[ -f ${profile_dir}/hooks/pre-build.hook ]]; then
        _msg_info "Running prebuild hook..."
        exec ${profile_dir}/hooks/pre-build.hook
    fi
}

make_basefs() {
    _msg_info "Building basefs..."
    local _pkgs=(base base-devel git zsh)
    local _adtl_pkgs=$(grep -h -v ^# ${script_dir}/pkglist.{any,$arch})
    setarch ${arch} _pacman ${_pkgs[@]} ${_adtl_pkgs[@]}

    _msg_info "Syncing airootfs..."
    _rsync ${script_dir}/airootfs/* ${build_dir}

    _msg_info "Running base provisioning script..."
    _chroot_run "exec /root/base.sh"
}

make_profile() {
    # Double line break for easier reading of output
    echo -e "\n\n"
    _msg_info "Building ${profile}..."
    
    if [[ -d ${profile_dir} && ${install_profile} -ne "base" ]]; then
        _rsync ${profile_dir}/${install_profile}.sh ${build_dir}/root

        _msg_info "Running ${install_profile} provisioning script..."
        _chroot_run "exec /root/${install_profile}.sh"
        _chroot_run "rm /root/${install_profile}.sh"

        #TODO: Post install hook
    else
        _msg_error "Profile ${profile} not found!" 3
    fi
}



_run_once configure_system
_run_once initialize
_run_once make_basefs
_run_once make_profile
