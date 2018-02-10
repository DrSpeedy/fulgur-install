#!/bin/sh

# Author: Brian Wilson <doc@wiltech.org>
# Project: Fulgur Linux
#
#

__make_initcpio() {
    _msg_info "Building ${profile} initcpio..."
    _rsync ${_profiled}/mkinitcpio.conf ${build_dir}/etc/
    _chroot_run "mkinitcpio -P"
}

__configure_filesystem() {

    local _attached_devs=$()

    OPTION=$(dialog --clear --backtitle "[ Configure Filesystem ]" \
    --title "Fulgur Linux Workstation" \
    --menu "$MENUTEXT" 20 75 8 \
    "${THEMES[@]}" 3>&2 2>&1 1>&3)
}

workstation_build() {
    _msg_info "Building ${profile}..."
}
