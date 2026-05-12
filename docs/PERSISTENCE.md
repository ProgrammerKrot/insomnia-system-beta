# USB Persistence Guide

## Overview

Insomnia System supports **live persistence** via a dedicated `ext4` partition
labeled `persistence` on the same USB drive. Changes to the filesystem survive reboots.

## What Gets Persisted

With `/union` in `persistence.conf`, the **entire root filesystem** is overlaid
using `overlayfs`. This means:

- Installed packages persist
- User dotfiles persist
- System configuration changes persist
- `/tmp` and `/run` are still ephemeral

## Setup

### Automatic (recommended)

```bash
sudo ./scripts/deploy/flash-usb.sh insomnia-*.iso /dev/sdX
```

### Manual

```bash
# After writing the ISO with dd:
sudo parted /dev/sdX mkpart primary ext4 4200MiB 100%
sudo mkfs.ext4 -L persistence /dev/sdX3
sudo mount /dev/sdX3 /mnt
echo "/union" | sudo tee /mnt/persistence.conf
sudo umount /mnt
```

## Bootloader Configuration

The persistence boot entry passes these kernel parameters:

```
persistence persistence-label=persistence cow_spacesize=1G
```

`cow_spacesize` limits copy-on-write RAM usage during the session.
Increase if you work with large files in the live session before sync.

## Backup Persistence Data

```bash
# From another machine, mount and rsync:
sudo mount -o ro /dev/sdX3 /mnt/persist
rsync -avz /mnt/persist/ ~/insomnia-backup/
sudo umount /mnt/persist
```

## Resizing the Persistence Partition

If you need more space later:

```bash
sudo e2fsck -f /dev/sdX3
sudo resize2fs /dev/sdX3  # grows to fill partition
# Or use parted/gparted to resize the partition first
```
