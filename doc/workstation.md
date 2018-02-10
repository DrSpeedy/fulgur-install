# Fulgur Workstation
#### Maintainer: Brian Wilson <doc@wiltech.org>
#### GIT: ssh://git@bitbucket.org:wiltech/fulgur.git
======

## Introduction:
Fulgur Workstation is a light-weight highly configurable workstation
platform for software and networking development.

## Top Level Features:

### Tiling window manager:
Fulgur's user interface is based on i3-gaps. Fulgure has it's own templated
configuration system. <see doc/i3.md>

### Neovim:
Fulgur is designed to be primary operated via command line. Neovim was chosen
to be the primary editor due to it's built in terminal buffer support.
<see doc/neovim.md>

    - Tight integration with shell
    - Tight integration with ranger file manager

## Bottom Level Features:

### Networking: <see doc/networking/*>
    #### Intended features:
    - NetworkManager as backbone
    - Bluetooth support
    - Samba support

### Shell:
    - ZSH with oh-my-zsh support as default shell
    - Prepackaged default system configuration
    - XDG environment integration

### File System:
#### Example:
```
/dev/loop0                          LOOP    8G      /var/swap
/dev/sda                            DISK    250G
    /dev/sda1                       EXT2    128M    /boot
    /dev/sda2                       LVM
        /dev/mapper/fulgur-root     EXT4    40G     /
        /dev/mapper/fulgur-home     EXT4    200G    /home
```

#### Boot:
    - Bios-Boot should be it's own ext2 partition of 128MB
    - EFI-Boot should be a 512MB fat32 partition at beginning of disk
    - EFI directory should be mounted at /boot/EFI
    - Default bootloader is grub2

#### Rootfs:
    - The root FS should be located on it's own logical volume with ext4 format
    - The user home (/home/) should also be it's own logical volume with ext4 format
    - Swap space should NOT be a partition, however a file located at /swap.img
    - Swap file should be loaded as a loop device
    - Encryption support via LVM on LUKS

### Package Management:
For now the Fulgur will use the mirrors provided by Arch Linux. A custom repository for
Fulgur-specific packages can be found at <https://cerberus.wiltech.org/repo>

### SSH:
Fulgur is meant to be highly network-friendly. SSH is a big part of this.
    - SSHFS support
    - SSH disabled by default (security)


### Systemd:
    - Automatically reconfigure mirrorlist
    - Package database synchronization
    - Update notifications for *users*

### Kernel:
    - KVM support
    - Based on LTS Arch Linux LTS
    - LVM and LUKS support
    - ZFS (further reading into linux zfs project licensing needed)
