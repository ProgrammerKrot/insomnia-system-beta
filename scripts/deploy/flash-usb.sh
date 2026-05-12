#!/usr/bin/env bash
# flash-usb.sh — Write Insomnia ISO to USB and create persistence partition
# Usage: sudo ./flash-usb.sh <iso-file> <device>  e.g. /dev/sdb
set -euo pipefail

ISO="${1:?Usage: flash-usb.sh <iso-file> <device>}"
DEVICE="${2:?Usage: flash-usb.sh <iso-file> <device>}"

_log() { echo -e "\e[1;37m[*]\e[0m $*"; }
_ok()  { echo -e "\e[1;32m[+]\e[0m $*"; }
_err() { echo -e "\e[1;31m[!]\e[0m $*" >&2; exit 1; }

[[ $EUID -eq 0 ]]  || _err "Must run as root."
[[ -f "$ISO" ]]    || _err "ISO not found: $ISO"
[[ -b "$DEVICE" ]] || _err "$DEVICE is not a block device."

echo ""
echo -e "  \e[1;31mWARNING: ALL DATA ON $DEVICE WILL BE DESTROYED.\e[0m"
echo ""
read -rp "  Type 'yes-destroy' to confirm: " confirm
[[ "$confirm" == "yes-destroy" ]] || { echo "Aborted."; exit 0; }

_log "Unmounting any partitions on $DEVICE..."
umount "${DEVICE}"?* 2>/dev/null || true

_log "Writing ISO (this may take several minutes)..."
dd if="$ISO" of="$DEVICE" bs=4M status=progress oflag=sync
sync

_log "Re-reading partition table..."
partprobe "$DEVICE"
sleep 3

# Detect last partition end sector
LAST_END=$(parted "$DEVICE" --script unit MiB print \
  | awk '/^ [0-9]/ {end=$3} END {print end}' \
  | tr -d 'MiB')

if [[ -z "$LAST_END" ]]; then
  _err "Could not detect last partition end. Aborting persistence setup."
fi

_log "Creating persistence partition after ${LAST_END}MiB..."
parted "$DEVICE" --script mkpart primary ext4 "${LAST_END}MiB" 100%
partprobe "$DEVICE"
sleep 2

# Identify new partition (last one)
PERSIST_PART=$(lsblk -lnpo NAME "$DEVICE" | tail -1)
_log "Formatting persistence partition: $PERSIST_PART"
mkfs.ext4 -L persistence -F "$PERSIST_PART"

MNT=$(mktemp -d)
mount "$PERSIST_PART" "$MNT"
echo "/union" > "$MNT/persistence.conf"
umount "$MNT"
rmdir "$MNT"

_ok "Done."
_ok "Persistence partition: $PERSIST_PART (label: persistence)"
_ok "Boot the USB and select 'Insomnia System (Persistent)' from GRUB/syslinux."
