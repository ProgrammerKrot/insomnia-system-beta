#!/usr/bin/env bash
# build-iso.sh — Merge this overlay onto archiso releng, then run mkarchiso
# Usage: sudo ./scripts/build/build-iso.sh [--dry-run] [--profile epm-only|full]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OVERLAY_DIR="$REPO_ROOT/archiso"
RELENG_DIR="/usr/share/archiso/configs/releng"
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
[[ -d "$RELENG_DIR" ]] || _err "Missing $RELENG_DIR — install archiso"

PROFILE_DIR="$(mktemp -d)/insomnia-profile"
trap 'rm -rf "$(dirname "$PROFILE_DIR")"' EXIT

_log "Copying official releng profile..."
cp -a "$RELENG_DIR/." "$PROFILE_DIR/"

_log "Merging Insomnia airootfs overlay..."
cp -a "$OVERLAY_DIR/airootfs/." "$PROFILE_DIR/airootfs/"

_log "Applying Insomnia package list..."
cp "$OVERLAY_DIR/packages.x86_64" "$PROFILE_DIR/packages.x86_64"

if [[ -f "$PROFILE_DIR/profiledef.sh" ]]; then
  sed -i \
    -e 's/^iso_name=.*/iso_name="insomnia"/' \
    -e 's/^iso_publisher=.*/iso_publisher="Insomnia System <https:\/\/github.com\/ProgrammerKrot\/InsomniaSys-beta>"/' \
    -e 's/^iso_application=.*/iso_application="Insomnia System Live\/Rescue"/' \
    "$PROFILE_DIR/profiledef.sh" || true
fi

if [[ "$PROFILE_VARIANT" == "epm-only" ]]; then
  _log "EPM-only build: stripping GUI packages from list..."
  sed -i '/^# ── GUI/,/^# ──/{ /^[a-z]/d }' "$PROFILE_DIR/packages.x86_64"
fi

_log "Building Insomnia System ISO"
_log "  Profile  : $PROFILE_DIR"
_log "  Output   : $OUT_DIR"
_log "  Label    : $ISO_LABEL"
_log "  Variant  : $PROFILE_VARIANT"

if [[ "$DRY_RUN" == "true" ]]; then
  _ok "Dry run complete. Merged profile ready (not building)."
  _log "Package count: $(grep -cE '^[a-zA-Z0-9]' "$PROFILE_DIR/packages.x86_64" || true)"
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
