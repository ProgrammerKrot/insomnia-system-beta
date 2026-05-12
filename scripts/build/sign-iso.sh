#!/usr/bin/env bash
# sign-iso.sh — GPG-sign an Insomnia ISO and generate checksums
# Usage: ./sign-iso.sh <iso-file> [gpg-key-id]
set -euo pipefail

ISO="${1:?Usage: sign-iso.sh <iso-file> [gpg-key-id]}"
GPG_KEY="${2:-}"

[[ -f "$ISO" ]] || { echo "[!] File not found: $ISO"; exit 1; }

echo "[*] Generating checksums..."
sha256sum "$ISO" > "${ISO}.sha256"
b2sum    "$ISO" > "${ISO}.b2"

if [[ -n "$GPG_KEY" ]]; then
  echo "[*] Signing with key: $GPG_KEY"
  gpg --detach-sign --armor -u "$GPG_KEY" "$ISO"
  echo "[+] Signature: ${ISO}.asc"
else
  echo "[*] No GPG key specified — skipping signature."
fi

echo "[+] SHA256: $(cat "${ISO}.sha256")"
echo "[+] Done."
