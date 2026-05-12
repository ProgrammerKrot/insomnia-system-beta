#!/usr/bin/env bash
# build-iso.sh — Insomnia System ISO builder
# Usage: sudo ./scripts/build/build-iso.sh [--dry-run] [--profile epm-only]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROFILE_DIR="$REPO_ROOT/archiso"
OUT_DIR="$REPO_ROOT/output"
WORK_DIR="/tmp/insomnia-work"
ISO_LABEL="INSOMNIA_$(date +%Y%m)"
DRY_RUN=false
PROFILE_VARIANT="full"

_log()  { echo -e "\e[1;37m[*]\e[0m $*"; }
_ok()   { echo -e "\e[1;32m[+]\e[0m $*"; }
_err()  { echo -e "\e[1;31m[!]\e[0m $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)        DRY_RUN=true ;;
    --profile)        PROFILE_VARIANT="$2"; shift ;;
    *)                _err "Unknown option: $1" ;;
  esac
  shift
done

[[ $EUID -ne 0 ]] && _err "Must run as root: sudo $0"
command -v mkarchiso &>/dev/null || _err "archiso not installed. Run: pacman -S archiso"

if [[ "$PROFILE_VARIANT" == "epm-only" ]]; then
  _log "EPM-only build: removing GUI packages from list..."
  # Create a temp profile with GUI packages stripped
  WORK_PROFILE="$(mktemp -d)/insomnia-epm"
  cp -a "$PROFILE_DIR" "$WORK_PROFILE"
  sed -i '/^# ── GUI/,/^# ──/{ /^[a-z]/d }' "$WORK_PROFILE/packages.x86_64"
  PROFILE_DIR="$WORK_PROFILE"
fi

_log "Building Insomnia System ISO"
_log "  Profile  : $PROFILE_DIR"
_log "  Output   : $OUT_DIR"
_log "  Label    : $ISO_LABEL"
_log "  Variant  : $PROFILE_VARIANT"

if [[ "$DRY_RUN" == "true" ]]; then
  _ok "Dry run complete. Profile looks valid."
  exit 0
fi

mkdir -p "$OUT_DIR"
[[ -d "$WORK_DIR" ]] && rm -rf "$WORK_DIR"

mkarchiso \
  -v \
  -w "$WORK_DIR" \
  -o "$OUT_DIR" \
  -L "$ISO_LABEL" \
  "$PROFILE_DIR"

ISO_FILE=$(ls -t "$OUT_DIR"/*.iso 2>/dev/null | head -1)
[[ -z "$ISO_FILE" ]] && _err "Build failed: no ISO found in $OUT_DIR"

SHA256=$(sha256sum "$ISO_FILE" | awk '{print $1}')
echo "$SHA256  $(basename "$ISO_FILE")" > "${ISO_FILE%.iso}.sha256"

_ok "Build complete: $ISO_FILE"
_ok "SHA256: $SHA256"
