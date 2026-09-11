# Insomnia System (v0.1 beta)

Arch-based live profile for a USB-first install: GNOME desktop or **Extreme Power Mode** (TTY + Zellij + TLP/cpupower), plus Calamares branding and custom package stubs.

This repo is a **working blueprint**, not a finished shipping distro. Scripts and configs are here; a full bootable ISO still needs Arch's official `releng` profile as the base (the build script merges onto it).

## What works in-tree

| Area | Location |
|------|----------|
| Package list | `archiso/packages.x86_64` |
| Live overlay (hostname, zsh, systemd, pacman) | `archiso/airootfs/` |
| Regime switcher + EPM launcher | `usr/local/bin/insomnia-ctl`, `epm-launch` |
| Calamares settings + branding | `etc/calamares/` |
| EPM configs (zellij, btop, starship) | `config/epm/` |
| GNOME dconf dump + extension list | `config/gnome/` |
| PKGBUILD stubs | `pkgbuilds/` |
| Build / flash / repo scripts | `scripts/` |
| Notes | `docs/` |

## Status

**Present:** airootfs overlay, package list, EPM scripts, Calamares configs, build/flash/repo helpers, three PKGBUILDs, docs.

**Not in this repo yet (planned):** complete Plymouth theme files, Plasma theme bundle, hosted `insomnia` pacman repo, TLP drop-in overrides, signed package pipeline beyond `update-repo.sh`.

Custom packages (`insomnia-core`, etc.) stay **commented out** in `packages.x86_64` until you host the repo.

## Requirements

- Arch Linux host
- `sudo pacman -S archiso git`

Build merges this tree onto `/usr/share/archiso/configs/releng` (needs `archiso` installed).

## Build ISO

```bash
git clone https://github.com/ProgrammerKrot/InsomniaSys-beta.git
cd InsomniaSys-beta

sudo ./scripts/build/build-iso.sh --dry-run
sudo ./scripts/build/build-iso.sh
# optional: strip GUI packages
sudo ./scripts/build/build-iso.sh --profile epm-only

./scripts/build/sign-iso.sh output/*.iso
```

ISO and checksums land in `output/`.

## Flash USB (with persistence partition)

```bash
sudo ./scripts/deploy/flash-usb.sh output/insomnia-*.iso /dev/sdX
```

Details: [`docs/PERSISTENCE.md`](docs/PERSISTENCE.md).

## Extreme Power Mode

```bash
sudo insomnia-ctl epm      # stop DM, powersave governor, dim backlight, launch EPM
sudo insomnia-ctl gui     # restore display manager
insomnia-ctl status
sudo insomnia-ctl toggle
```

EPM session layout: `config/epm/zellij-layout.kdl`. Power notes: [`docs/EPM-INTERNALS.md`](docs/EPM-INTERNALS.md).

## Custom packages

```bash
# optional: export INSOMNIA_GPG_KEY=...
./scripts/repo/update-repo.sh
```

Hosting steps: [`docs/REPO-HOSTING.md`](docs/REPO-HOSTING.md). After the Pages repo exists, uncomment the `[insomnia]` block in `archiso/airootfs/etc/pacman.conf` and the three packages in `packages.x86_64`.

## Layout

```
archiso/
  packages.x86_64          # ISO package list
  airootfs/                # overlay merged onto archiso releng
pkgbuilds/                 # insomnia-core, insomnia-theme-oled, insomnia-zsh-prompt
scripts/build|deploy|repo/
config/epm|gnome/
docs/
```

## License

MIT — see [`LICENSE`](LICENSE).
