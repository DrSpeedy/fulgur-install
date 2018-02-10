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
work_dir=/tmp/work

# Directory where the root system will be built
build_dir=/mnt

# Location of the pacman.conf used to build the live system
pacman_conf=${work_dir}/pacman.conf

# Installation profile
install_profile="set-top-box"
profile_dir="${script_dir}/profiles/${install_profile}"


# Source in utility scripts
source "${script_dir}/resources/alias.rc"
source "${script_dir}/resources/util.rc"
source "${script_dir}/resources/configure.rc"

# Run configuration scripts to build partition
# table and set other system install variables
configure_system() {
    _msg_info "Running configuration..."
    
    __select_disk
    __select_partition_scheme
    #_select_hostname
    #_select_timezone
}

# Initialize the build enviornment
initialize() {
    _msg_info "Initializing build environment..."
    mkdir -p ${work_dir}
    mkdir -p ${build_dir}

    _msg_info "Generating pacman.conf..."
    _msg_info "${script_dir}/pacman.conf -> ${pacman_conf}"

    local _cache_dirs
    _cache_dirs=($(pacman -v 2>&1 | grep '^Cache Dirs:' | sed 's/Cache Dirs:\s*//g'))
    sed -r "s|^#?\\s*CacheDir.+|CacheDir = $(echo -n ${_cache_dirs[@]})|g" ${script_dir}/pacman.conf > ${pacman_conf}

    # Run pre-build profile hook if it exists
    _run_profile_hook "pre-install"
}

make_basefs() {
    _msg_info "Building basefs..."
    local _pkgs=(base base-devel git zsh grub)
    local _adtl_pkgs=$(grep -h -v ^# ${script_dir}/pkglist.{any,$arch})
    _pacman ${_pkgs[@]} ${_adtl_pkgs[@]}

    if [[ $? -ne 0 ]]; then
        _msg_error "Package installation failed!" 2
    fi

    # EFI tools
    if [[ ${use_uefi} ]]; then
        _msg_info "EFI detected! Installing additional packages..."
        local _efi_pkgs=(efibootmgr)
        _pacman ${_efi_pkgs}

        if [[ $? -ne 0 ]]; then
            _msg_error "EFI tools installation failed!" 2
        fi
    fi
    

    _msg_info "Syncing airootfs..."
    _rsync ${script_dir}/airootfs/* ${build_dir}

    _msg_info "Running base provisioning script..."
    _chroot_run "/root/base.sh"
    rm ${build_dir}/root/base.sh

    # mkbasefs.hook
    _run_profile_hook "mkbasefs"
}

make_profile() {
    # Double line break for easier reading of output
    echo -e "\n\n"
    _msg_info "Building ${install_profile}..."
    _msg_info "${profile_dir}"
    
    if [[ -d ${profile_dir} ]]; then
        local _pkgs=$(grep -h -v ^# ${profile_dir}/pkglist.{any,$arch})
        _pacman ${_pkgs[@]}

        _rsync ${profile_dir}/airootfs/* ${build_dir}
        _rsync ${profile_dir}/${install_profile}.sh ${build_dir}/root

        _msg_info "Running ${install_profile} provisioning script..."
        _chroot_run "/root/${install_profile}.sh"
        _chroot_run "rm /root/${install_profile}.sh"

    else
        _msg_error "Profile ${profile} not found!" 3
    fi

    # mkprofile.hook
    _run_profile_hook "mkprofile"
}

make_grub_bootloader() {
    if [[ ${use_uefi} -eq 0 ]]; then
        _msg_info "Installing GRUB..."

        grub-install --target=i386-pc --root-dir=${build_dir} ${install_disk}

        _rsync ${script_dir}/grub/grub.cfg ${build_dir}/etc/default/grub
        _chroot_run "grub-mkconfig -o /boot/grub/grub.cfg"
    fi
}

_run_once initialize
_run_once make_pacman_config
_run_once configure_system
_run_once make_basefs
_run_once make_profile
_run_once make_grub_bootloader

_run_profile_hook "post-install"
