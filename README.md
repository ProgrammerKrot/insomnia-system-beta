# Insomnia System (v0.1 beta)

Arch-based live profile for a USB-first install: GNOME desktop or **Extreme Power Mode** (TTY + Zellij + TLP/cpupower), plus Calamares branding and custom package stubs.

This repo is a **working blueprint**, not a finished shipping distro. Scripts and configs are here; a full bootable ISO still needs Arch's official `releng` profile as the base (the build script merges onto it).

## What works in-tree

| Area | Location |
|------|----------|
| Package list | `archiso/packages.x86_64` |
| Live overlay (hostname, zsh, systemd, pacman) | `archiso/airootfs/` |
| Regime switcher + EPM launcher | `usr/local/bin/insomnia-ctl`, `epm-launch` |
| EPM power engine (snapshot/restore) | `usr/local/bin/insomnia-power` |
| Battery telemetry / 12 h budget | `usr/local/bin/insomnia-batt` |
| INSOMNIA//NEON console palette | `usr/local/bin/insomnia-palette` |
| Battery profile (both regimes) | `etc/tlp.d/90-insomnia.conf` |
| Calamares settings + branding | `etc/calamares/` |
| EPM configs (zellij, btop, starship) | `config/epm/` |
| Vim config (copied verbatim into `/etc/skel`, `/root`) | `config/vim/vimrc` |
| GNOME dconf dump + extension list | `config/gnome/` |
| PKGBUILD stubs | `pkgbuilds/` |
| Build / flash / repo scripts | `scripts/` |
| Notes | `docs/` |

## Status

**Present:** airootfs overlay, package list, EPM scripts, Calamares configs, build/flash/repo helpers, three PKGBUILDs, docs.

**Not in this repo yet (planned):** complete Plymouth theme files, Plasma theme bundle, hosted `insomnia` pacman repo, TLP drop-in overrides, signed package pipeline beyond `update-repo.sh`.

Custom packages (`insomnia-core`, etc.) **and `calamares`** (AUR-only on Arch) stay **commented out** in `packages.x86_64` until you host the repo. Until then the ISO has no graphical installer.

## Requirements

- Arch Linux host
- `sudo pacman -S archiso git`

Build merges this tree onto `/usr/share/archiso/configs/releng` (needs `archiso` installed).

## Build ISO

```bash
git clone https://github.com/ProgrammerKrot/insomnia-system-beta.git
cd insomnia-system-beta

sudo ./scripts/build/build-iso.sh --dry-run
sudo ./scripts/build/build-iso.sh
# optional: strip GUI packages
sudo ./scripts/build/build-iso.sh --profile epm-only
# optional: leave out the security toolkit
sudo ./scripts/build/build-iso.sh --no-security

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
sudo insomnia-ctl epm      # stop DM, tune CPU/GPU/buses/backlight, BT off, Wi-Fi power-save
sudo insomnia-ctl dark     # same, every radio off, deeper caps
sudo insomnia-ctl gui      # restore every knob exactly + start display manager
insomnia-ctl status
batt                       # live draw, ETA, battery wear, 12 h power budget
```

Dashboard (zellij, INSOMNIA//NEON theme): `OPS` tab = shell + power panel;
`SYS` (btop), `NET` (nmtui, bandwhich), `FILES` (lf) start suspended so they
cost nothing until opened. Layout: `config/epm/zellij-layout.kdl`.

How it saves power, what each regime touches, and the honest battery math:
[`docs/EPM-INTERNALS.md`](docs/EPM-INTERNALS.md).

## Packages

Besides the base system, the ISO ships a CLI workstation (vim, lf/nnn/mc,
neomutt, weechat, newsboat, calcurse, cmus, mpv…), network tools, and a
**Security Toolkit** of Kali-equivalent tools from the official Arch repos
(nmap, wireshark-cli, aircrack-ng, hcxtools, bettercap, hashcat, john, hydra,
sqlmap, metasploit, radare2, …). Drop that section with
`build-iso.sh --no-security`.

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
