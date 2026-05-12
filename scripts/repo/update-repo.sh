#!/usr/bin/env bash
# update-repo.sh — Build all PKGBUILDs and update the insomnia pacman repo
# Usage: ./scripts/repo/update-repo.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKGBUILD_DIR="$REPO_ROOT/pkgbuilds"
REPO_DIR="$REPO_ROOT/insomnia-repo/x86_64"
GPG_KEY="${INSOMNIA_GPG_KEY:-}"

_log() { echo -e "\e[1;37m[*]\e[0m $*"; }
_ok()  { echo -e "\e[1;32m[+]\e[0m $*"; }
_err() { echo -e "\e[1;31m[!]\e[0m $*" >&2; exit 1; }

mkdir -p "$REPO_DIR"

for pkg_dir in "$PKGBUILD_DIR"/*/; do
  pkg_name=$(basename "$pkg_dir")
  _log "Building package: $pkg_name"
  (
    cd "$pkg_dir"
    makepkg -sf --noconfirm --clean
    for pkg in ./*.pkg.tar.zst; do
      [[ -f "$pkg" ]] || continue
      if [[ -n "$GPG_KEY" ]]; then
        gpg --detach-sign --use-agent --no-armor -u "$GPG_KEY" "$pkg"
      fi
      mv "$pkg" "$REPO_DIR/"
      [[ -f "${pkg}.sig" ]] && mv "${pkg}.sig" "$REPO_DIR/"
    done
  )
done

_log "Updating repository database..."
if [[ -n "$GPG_KEY" ]]; then
  repo-add --sign --key "$GPG_KEY" \
    "$REPO_DIR/insomnia.db.tar.gz" \
    "$REPO_DIR"/*.pkg.tar.zst
else
  repo-add "$REPO_DIR/insomnia.db.tar.gz" "$REPO_DIR"/*.pkg.tar.zst
fi

_ok "Repository updated at: $REPO_DIR"
_ok "Push the insomnia-repo/ directory to GitHub and enable GitHub Pages."
echo ""
echo "  Add to pacman.conf:"
echo "  [insomnia]"
echo "  Server = https://ProgrammerKrot.github.io/insomnia-repo/x86_64"
