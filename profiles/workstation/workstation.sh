#!/bin/sh
# vim:filetype=sh

# Author: Brian Wilson <doc@wiltech.org>
# Project: Fulgur Linux
# Profile: workstation
#
#

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime

usermod -s /bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

# Update mirror list
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
reflector --country 'United States' --latest 100 --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

systemctl enable NetworkManager.service
systemctl enable bluetooth.service

groupadd doc
useradd -m -g users -G "wheel,lp,audio,video" -s /bin/zsh doc
echo -e "Set password for <doc>"
passwd doc

genfstab -U / >> /etc/fstab

echo "FulgurWS-$$" > /etc/hostname

