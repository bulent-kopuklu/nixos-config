#! /usr/bin/env bash


DEVICE=/dev/nvme0n1

sudo su

sgdisk --clear \
  --new=1:0:+2048MiB --typecode=1:ef00 --change-name=1:BOOT \
  --new=2:0:0 --typecode=3:8300 --change-name=2:cryptsystem \
  $DEVICE

cryptsetup luksFormat --type luks2 --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/cryptsystem
cryptsetup open /dev/disk/by-partlabel/cryptsystem system

mkdir /mnt/nixos

mkfs.btrfs --label system /dev/mapper/system
mount -t btrfs LABEL=system /mnt/nixos

btrfs subvolume create /mnt/nixos/@root
btrfs subvolume create /mnt/nixos/@home
btrfs subvolume create /mnt/nixos/@nix
btrfs subvolume create /mnt/nixos/@snapshots

umount -R /mnt/nixos

mount -t btrfs -o defaults,x-mount.mkdir,ssd,noatime,subvol=@root LABEL=system /mnt/nixos
mount -t btrfs -o defaults,x-mount.mkdir,ssd,noatime,subvol=@home LABEL=system /mnt/nixos/home
mount -t btrfs -o defaults,x-mount.mkdir,ssd,noatime,subvol=@snapshots LABEL=system /mnt/nixos/nix
mount -t btrfs -o defaults,x-mount.mkdir,ssd,noatime,subvol=@snapshots LABEL=system /mnt/nixos/.snapshots

mkfs.fat -F32 -n BOOT /dev/disk/by-partlabel/BOOT
mkdir /mnt/boot
mount LABEL=BOOT /mnt/boot

cd /mnt

git clone https://github.com/bulent-kopuklu/nixos-config.git

nixos-install --verbose --root /mnt/nixos --flake /mnt/nixos-config#bulentk-g14
