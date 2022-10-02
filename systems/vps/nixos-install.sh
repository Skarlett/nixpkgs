#!/usr/bin/env bash
set -ex

parted --script /dev/vda mklabel msdos
parted --script /dev/vda mkpart primary 1MB 100%
parted --script /dev/vda set 1 boot on
mkfs.ext4 /dev/vda1 -L ROOT

mount /dev/vda1 /mnt
nixos-generate-config --root /mnt

mv configuration.nix /mnt/etc/nixos/configuration.nix
