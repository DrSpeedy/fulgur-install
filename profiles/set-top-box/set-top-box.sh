#!/bin/sh
# vim:filetype=sh

# Author: Brian Wilson <doc@wiltech.org>
# Project: Fulgur Linux
# Profile: set-top-box
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

# Initialize pacman and populate the keyring
pacman-key --init
pacman-key --populate archlinux

systemctl set-default multi-user.target
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable nginx.service
systemctl enable sshd.service
systemctl enable stb.service

groupadd media
useradd -m -g media -G "users,lp,audio,video" -s /bin/zsh media

useradd -m -p "password" -g users -G "wheel,lp,audio,video" -s /bin/zsh doc
echo -e "Set password for <doc>"
#passwd doc

genfstab -L / >> /etc/fstab

echo "STB-$$" > /etc/hostname

