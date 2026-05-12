# INSOMNIA SYSTEM
### *"The machine never sleeps."*

```
              . . . ─────────────── . . .
           .     ╱                   ╲     .
         .      ╱   ╭─────────────╮   ╲      .
        .      ╱   ╱               ╲   ╲      .
       .      │   │   ╭─────────╮   │   │      .
       .      │   │  ╱  ╭─────╮  ╲  │   │      .
       .      │   │ │   │  ●  │   │ │   │      .
       .      │   │  ╲  ╰─────╯  ╱  │   │      .
       .      │   │   ╰─────────╯   │   │      .
        .      ╲   ╲               ╱   ╱      .
         .      ╲   ╰─────────────╯   ╱      .
           .     ╲                   ╱     .
              ' ' ' ─────────────── ' ' '

     ██╗███╗   ██╗███████╗ ██████╗ ███╗   ███╗███╗   ██╗██╗ █████╗
     ██║████╗  ██║██╔════╝██╔═══██╗████╗ ████║████╗  ██║██║██╔══██╗
     ██║██╔██╗ ██║███████╗██║   ██║██╔████╔██║██╔██╗ ██║██║███████║
     ██║██║╚██╗██║╚════██║██║   ██║██║╚██╔╝██║██║╚██╗██║██║██╔══██║
     ██║██║ ╚████║███████║╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██║  ██║
     ╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
                                                      S Y S T E M  v0.1
```

> **Arch Linux derivative** · Portable USB-first · OLED-native dark theme · Extreme Power Mode
>
> *Distro-as-Code. Every byte intentional.*

---

## Table of Contents

1. [Philosophy](#philosophy)
2. [Architecture Overview](#architecture-overview)
3. [Repository Structure](#repository-structure)
4. [Build System](#build-system)
5. [Extreme Power Mode (EPM)](#extreme-power-mode-epm)
   - [insomnia-ctl Script](#insomnia-ctl-script)
   - [EPM Tool Stack](#epm-tool-stack)
6. [Graphical Installer (Calamares)](#graphical-installer-calamares)
7. [Branding & Theming](#branding--theming)
8. [Custom Pacman Repository](#custom-pacman-repository)
9. [USB Persistence](#usb-persistence)
10. [Contributing](#contributing)

---

## Philosophy

Insomnia System is built on three axioms:

| Axiom | Principle |
|-------|-----------|
| **Portability** | The OS lives on USB. The machine is a substrate. |
| **Frugality** | Every milliwatt is a decision. EPM is the default mindset. |
| **Intentionality** | No daemon runs without a reason. No pixel wastes light. |

The OS operates in two **Regimes**:

- **Regime I — GUI Desktop**: GNOME or Plasma with OLED-optimized dark theme. Full compositor, Wayland-native. For when power is available.
- **Regime II — Extreme Power Mode (EPM)**: No X. No Wayland. Pure TTY + Zellij multiplexer dashboard. CPU throttled, radios silenced, screen dimmed. Target: < 3W on modern ultrabooks.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     INSOMNIA SYSTEM                         │
│                                                             │
│  ┌──────────────┐          ┌──────────────────────────────┐ │
│  │  REGIME I    │          │       REGIME II (EPM)        │ │
│  │  GUI Desktop │◄────────►│  TTY · Zellij · No Display  │ │
│  │  GNOME/KDE   │  ctl     │  btop · ranger · micro       │ │
│  └──────────────┘  switch  └──────────────────────────────┘ │
│          │                              │                   │
│          └──────────┬───────────────────┘                   │
│                     │                                       │
│         ┌───────────▼───────────┐                           │
│         │    insomnia-core       │                           │
│         │  systemd · zsh · tlp  │                           │
│         │  archiso · persistence│                           │
│         └───────────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
InsomniaSystem/
│
├── README.md                        # This file
│
├── archiso/                         # Archiso profile (maps to /usr/share/archiso/configs/releng/)
│   ├── airootfs/                    # Files overlaid onto the live root filesystem
│   │   ├── etc/
│   │   │   ├── os-release           # Branding: distro identity
│   │   │   ├── issue                # TTY login banner
│   │   │   ├── hostname             # Default: insomnia
│   │   │   ├── locale.conf
│   │   │   ├── vconsole.conf        # Console font (ter-v18b)
│   │   │   ├── pacman.conf          # Includes insomnia repo
│   │   │   ├── pacman.d/
│   │   │   │   └── insomnia.conf    # Custom repo mirrorlist
│   │   │   ├── systemd/
│   │   │   │   └── system/
│   │   │   │       ├── tlp.service.d/
│   │   │   │       │   └── insomnia.conf    # TLP overrides
│   │   │   │       ├── insomnia-init.service
│   │   │   │       └── getty@tty1.service.d/
│   │   │   │           └── autologin.conf   # Auto-login for live session
│   │   │   ├── zsh/
│   │   │   │   ├── zshrc            # Global zsh config
│   │   │   │   └── zshenv           # Global environment
│   │   │   └── plymouth/
│   │   │       └── themes/
│   │   │           └── insomnia/    # Plymouth boot theme
│   │   └── usr/
│   │       ├── local/
│   │       │   └── bin/
│   │       │       ├── insomnia-ctl # Main regime controller
│   │       │       ├── epm-launch   # EPM session launcher
│   │       │       └── insomnia-persist # Persistence setup helper
│   │       └── share/
│   │           └── plymouth/
│   │               └── themes/
│   │                   └── insomnia/
│   │                       ├── insomnia.plymouth
│   │                       └── insomnia.script
│   ├── efiboot/                     # UEFI boot loader config
│   ├── syslinux/                    # Legacy BIOS boot config
│   └── packages.x86_64              # Package list for the ISO
│
├── pkgbuilds/                       # AUR-style PKGBUILDs for custom packages
│   ├── insomnia-core/
│   │   └── PKGBUILD                 # Meta-package: pulls all insomnia deps
│   ├── insomnia-theme-oled/
│   │   └── PKGBUILD                 # GTK/Qt OLED theme assets
│   └── insomnia-zsh-prompt/
│       └── PKGBUILD                 # Minimalist zsh prompt package
│
├── scripts/
│   ├── build/
│   │   ├── build-iso.sh             # Wrapper around mkarchiso
│   │   └── sign-iso.sh              # GPG sign + checksum generation
│   ├── deploy/
│   │   └── flash-usb.sh             # dd + persistence partition setup
│   └── repo/
│       ├── update-repo.sh           # Build PKGBUILDs and push to repo
│       └── sign-packages.sh         # GPG sign packages for pacman
│
├── config/
│   ├── gnome/
│   │   ├── dconf-insomnia.ini       # GNOME dconf settings dump
│   │   └── extensions.txt           # Required GNOME extensions list
│   ├── plasma/
│   │   └── plasma-theme.tar.gz      # KDE Plasma OLED theme bundle
│   └── epm/
│       ├── zellij-layout.kdl        # Zellij EPM dashboard layout
│       └── btop.conf                # btop configuration
│
└── docs/
    ├── EPM-INTERNALS.md             # Deep dive: EPM power targets
    ├── PERSISTENCE.md               # USB persistence setup guide
    └── REPO-HOSTING.md              # Custom pacman repo instructions
```

---

## Build System

### Prerequisites

```bash
sudo pacman -S archiso git gnupg
```

### `archiso/packages.x86_64` — Core Package Selection

```
# Base
base
base-devel
linux
linux-firmware
systemd
mkinitcpio

# Power management
tlp
tlp-rdw
powertop
cpupower
acpid
thermald

# Shell & TUI stack (EPM)
zsh
zsh-completions
zsh-syntax-highlighting
zsh-autosuggestions
zellij
tmux
btop
htop
micro
ranger
w3m
fzf
ripgrep
fd
bat
eza
zoxide
starship

# Networking (minimal)
networkmanager
iwd
openssh

# Filesystem & persistence tools
e2fsprogs
dosfstools
rsync
squashfs-tools

# GUI (Regime I) — comment out for EPM-only build
wayland
xorg-xwayland
gnome
gdm
noto-fonts
noto-fonts-emoji

# Branding
insomnia-core          # from custom repo
insomnia-theme-oled    # from custom repo
insomnia-zsh-prompt    # from custom repo
```

### Build Commands

```bash
# Clone the profile
git clone https://github.com/ProgrammerKrot/InsomniaSys-beta
cd InsomniaSystem

# Verify archiso profile integrity
./scripts/build/build-iso.sh --dry-run

# Full build (requires root for mkarchiso)
sudo ./scripts/build/build-iso.sh

# Build EPM-only (no GUI packages)
sudo ./scripts/build/build-iso.sh --profile epm-only

# Sign the ISO
./scripts/build/sign-iso.sh insomnia-*.iso
```

### `scripts/build/build-iso.sh`

```bash
#!/usr/bin/env bash
# build-iso.sh — Insomnia System ISO builder
set -euo pipefail

PROFILE_DIR="$(cd "$(dirname "$0")/../../archiso" && pwd)"
OUT_DIR="$(pwd)/output"
WORK_DIR="/tmp/insomnia-work"
ISO_LABEL="INSOMNIA_$(date +%Y%m)"

[[ $EUID -ne 0 ]] && { echo "[!] Must run as root."; exit 1; }

mkdir -p "$OUT_DIR"

echo "[*] Building Insomnia System ISO..."
echo "    Profile : $PROFILE_DIR"
echo "    Output  : $OUT_DIR"
echo "    Label   : $ISO_LABEL"

mkarchiso \
  -v \
  -w "$WORK_DIR" \
  -o "$OUT_DIR" \
  -L "$ISO_LABEL" \
  "$PROFILE_DIR"

echo "[+] Build complete: $(ls -1 "$OUT_DIR"/*.iso)"
```

---

## Extreme Power Mode (EPM)

EPM is **Regime II**. When activated, it:

1. Kills the display manager (GDM/SDDM) and compositor
2. Drops to TTY1 with a Zellij multiplexer dashboard
3. Applies aggressive TLP/cpupower profiles
4. Silences Wi-Fi/Bluetooth radios (optionally)
5. Dims backlight to minimum viable level

### `insomnia-ctl` Script

```bash
#!/usr/bin/env bash
# /usr/local/bin/insomnia-ctl
# Insomnia System — Regime Controller
# Usage: insomnia-ctl [gui|epm|status|toggle]
set -euo pipefail

REGIME_FILE="/run/insomnia-regime"
LOG_FILE="/var/log/insomnia-ctl.log"

_log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
_die() { _log "ERROR: $*"; exit 1; }

_require_root() {
  [[ $EUID -eq 0 ]] || _die "This operation requires root. Use: sudo insomnia-ctl $*"
}

_current_regime() {
  [[ -f "$REGIME_FILE" ]] && cat "$REGIME_FILE" || echo "gui"
}

_status() {
  local regime
  regime=$(_current_regime)
  local cpu_gov
  cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
  local bat_pct
  bat_pct=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
  local bat_status
  bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

  cat <<EOF

  ╔══════════════════════════════════╗
  ║     INSOMNIA SYSTEM — STATUS     ║
  ╠══════════════════════════════════╣
  ║  Regime    : $(printf '%-22s' "${regime^^}")║
  ║  CPU Gov.  : $(printf '%-22s' "$cpu_gov")║
  ║  Battery   : $(printf '%-22s' "${bat_pct}% (${bat_status})")║
  ║  Display   : $(printf '%-22s' "$(systemctl is-active gdm 2>/dev/null || echo inactive)")║
  ╚══════════════════════════════════╝

EOF
}

_enter_epm() {
  _require_root
  _log "Entering Extreme Power Mode..."

  # 1. Stop display manager
  for dm in gdm sddm lightdm; do
    systemctl is-active --quiet "$dm" 2>/dev/null && {
      _log "Stopping $dm..."
      systemctl stop "$dm"
    }
  done

  # 2. Kill Wayland/X compositor processes
  pkill -x "gnome-shell" 2>/dev/null || true
  pkill -x "plasmashell" 2>/dev/null || true
  pkill -x "Xorg"        2>/dev/null || true
  pkill -x "weston"      2>/dev/null || true

  # 3. Apply power governor
  _log "Setting CPU governor: powersave"
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave > "$cpu"
  done

  # 4. Activate TLP manual profile
  systemctl is-active --quiet tlp && tlp bat 2>/dev/null || true

  # 5. Dim backlight
  local backlight_dir
  backlight_dir=$(ls /sys/class/backlight/ 2>/dev/null | head -1)
  if [[ -n "$backlight_dir" ]]; then
    local max_brightness
    max_brightness=$(cat "/sys/class/backlight/${backlight_dir}/max_brightness")
    local target_brightness=$(( max_brightness / 10 ))
    _log "Setting backlight to ${target_brightness}/${max_brightness}"
    echo "$target_brightness" > "/sys/class/backlight/${backlight_dir}/brightness"
  fi

  # 6. Optional: disable Wi-Fi/BT (uncomment to enable)
  # _log "Disabling radios..."
  # rfkill block wifi
  # rfkill block bluetooth

  # 7. Record regime
  echo "epm" > "$REGIME_FILE"
  _log "EPM active."

  # 8. Launch EPM dashboard on TTY1
  if [[ -t 1 ]]; then
    epm-launch
  else
    # Called from GUI — switch to TTY1 and launch
    chvt 1
    runuser -l "$SUDO_USER" -c "epm-launch" &
  fi
}

_enter_gui() {
  _require_root
  _log "Entering GUI mode..."

  # 1. Restore CPU governor
  _log "Setting CPU governor: schedutil"
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > "$cpu"
  done

  # 2. Re-enable radios if they were blocked
  rfkill unblock all 2>/dev/null || true

  # 3. Restore backlight
  local backlight_dir
  backlight_dir=$(ls /sys/class/backlight/ 2>/dev/null | head -1)
  if [[ -n "$backlight_dir" ]]; then
    local max_brightness
    max_brightness=$(cat "/sys/class/backlight/${backlight_dir}/max_brightness")
    local comfortable=$(( max_brightness * 4 / 10 ))
    echo "$comfortable" > "/sys/class/backlight/${backlight_dir}/brightness"
  fi

  # 4. Detect and start display manager
  if command -v gdm &>/dev/null; then
    systemctl start gdm
  elif command -v sddm &>/dev/null; then
    systemctl start sddm
  else
    _log "No display manager found."
  fi

  echo "gui" > "$REGIME_FILE"
  _log "GUI mode active."
}

_toggle() {
  local current
  current=$(_current_regime)
  if [[ "$current" == "epm" ]]; then
    _enter_gui
  else
    _enter_epm
  fi
}

case "${1:-status}" in
  gui)    _enter_gui    ;;
  epm)    _enter_epm    ;;
  status) _status       ;;
  toggle) _toggle       ;;
  *)
    echo "Usage: insomnia-ctl [gui|epm|status|toggle]"
    exit 1
    ;;
esac
```

### `archiso/airootfs/usr/local/bin/epm-launch`

```bash
#!/usr/bin/env bash
# epm-launch — Start the EPM Zellij dashboard session
set -euo pipefail

LAYOUT_FILE="/etc/insomnia/epm/zellij-layout.kdl"
SESSION_NAME="insomnia-epm"

# Clear screen, print banner
clear
cat /etc/issue

# Prevent nested sessions
[[ -n "${ZELLIJ:-}" ]] && { echo "[!] Already inside Zellij."; exit 0; }

# Attach existing or create new session
if zellij list-sessions 2>/dev/null | grep -q "$SESSION_NAME"; then
  exec zellij attach "$SESSION_NAME"
else
  exec zellij --session "$SESSION_NAME" --layout "$LAYOUT_FILE"
fi
```

### EPM Tool Stack

| Tool | Role | Package |
|------|------|---------|
| `zellij` | Terminal multiplexer / EPM dashboard host | `zellij` |
| `btop` | System resource monitor (CPU/RAM/NET/DISK) | `btop` |
| `ranger` | TUI file manager with vi keybindings | `ranger` |
| `micro` | Terminal text editor (nano-compatible UX, better) | `micro` |
| `powertop` | Power consumption analysis and tunables | `powertop` |
| `tlp` | Automatic Linux power management framework | `tlp` |
| `cpupower` | CPU frequency scaling interface | `cpupower` |
| `acpi` | Battery / thermal status CLI | `acpi` |
| `nmtui` | NetworkManager TUI | `networkmanager` |
| `w3m` | Terminal web browser with image support | `w3m` |
| `irssi` / `weechat` | IRC / Matrix client | `irssi` |
| `neomutt` | TUI email client | `neomutt` |
| `fzf` | Fuzzy finder — shell history, file navigation | `fzf` |
| `zoxide` | Smart `cd` with frecency scoring | `zoxide` |
| `bat` | `cat` replacement with syntax highlighting | `bat` |
| `eza` | Modern `ls` replacement | `eza` |
| `ripgrep` | Ultra-fast recursive grep | `ripgrep` |
| `fd` | User-friendly `find` replacement | `fd` |

### Zellij EPM Dashboard Layout — `config/epm/zellij-layout.kdl`

```kdl
// Insomnia System — EPM Zellij Layout
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane split_direction="vertical" {
        pane split_direction="horizontal" size="70%" {
            pane command="btop" {
                args "--utf-force"
            }
            pane {
                // Primary shell
            }
        }
        pane split_direction="horizontal" size="30%" {
            pane command="watch" {
                args "-n2" "acpi -V"
                name "battery"
            }
            pane command="nmtui" {
                name "network"
            }
        }
    }
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

---

## Graphical Installer (Calamares)

Insomnia ships **Calamares** — the same installer framework used by Manjaro, EndeavourOS, and Garuda. It runs during the live session and gives a full GUI install wizard.

### How it Works

```
Live Session
    │
    ├─ GUI (GNOME):  click "Install Insomnia System" icon on desktop
    │                → pkexec calamares  (polkit elevation)
    │
    └─ TTY:          type insomnia-install
                     → sudo calamares
```

### Installer Flow

| Step | Module | What Happens |
|------|--------|--------------|
| 1 | `welcome` | System requirement checks (20GB disk, 2GB RAM) |
| 2 | `locale` | Language and timezone selection |
| 3 | `keyboard` | Keyboard layout |
| 4 | `partition` | Disk layout — erase / alongside / manual. Default: ext4 |
| 5 | `users` | Username, password (zsh is set as default shell) |
| 6 | `summary` | Review screen — last chance before commit |
| — | `unpackfs` | Copies squashfs to target partition |
| — | `bootloader` | Installs GRUB (UEFI + BIOS fallback) |
| — | `packages` | Removes live-only packages; installs `insomnia-core` |
| — | `shellprocess@post` | Enables TLP, NetworkManager, Plymouth; sets zsh for root |
| 7 | `finished` | Done — reboot prompt |

### Slideshow

During the copy phase, a 5-slide QML slideshow plays in the installer window:
`branding/insomnia/show.qml` — pure black background, `◉` eye motif, regime descriptions.

### Config Files

```
archiso/airootfs/etc/calamares/
├── settings.conf                    # Module sequence and branding selector
├── branding/
│   └── insomnia/
│       ├── branding.desc            # Product name, URLs, OLED colour palette
│       └── show.qml                 # Installation slideshow (QML/Qt)
└── modules/
    ├── welcome.conf                 # Requirement thresholds
    ├── partition.conf               # FS types, EFI size, swap options
    ├── users.conf                   # Default shell (zsh), groups, hostname
    ├── unpackfs.conf                # squashfs source path
    ├── displaymanager.conf          # GDM/SDDM detection
    ├── bootloader.conf              # GRUB UEFI + legacy config
    ├── packages.conf                # Post-install package operations
    ├── services-systemd.conf        # Services to enable/disable on install
    └── shellprocess@post.conf       # Final shell commands inside chroot
```

### Launching from TTY (EPM / no GUI)

```bash
# From the live TTY, start GNOME first:
sudo systemctl start gdm

# Or run Calamares directly in framebuffer (text mode — experimental):
sudo calamares --debug
```

---

## Branding & Theming

### 0. The Eye — Animated Logo (`insomnia-eye`)

The blinking eye is the Insomnia System identity mark. It has three animation frames:

```
OPEN                         HALF-CLOSED               CLOSED
. . . ─────────── . . .     . . . ─────────── . . .   . . . ─────────── . . .
   ╱                 ╲          ╱                 ╲        ╱                 ╲
  ╱  ╭─────────────╮  ╲     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─     ═══════════════════════
 │  │  ╭─────────╮  │  │     │ │  ╱  ╭─────╮  ╲ │ │    ═══════════════════════
 │  │ │   │  ●  │   │  │     │ │ │   │  ◉  │   │ │ │    ═══════════════════════
 │  │  ╰─────────╯  │  │     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─        ╲               ╱
  ╲  ╰─────────────╯  ╱          ╲               ╱         ╰─────────────╯
' ' ' ─────────────── ' ' '   ' ' ' ─────────── ' ' '   ' ' ' ─────────── ' ' '
```

Run it directly in any terminal:
```bash
insomnia-eye           # animated loop (Ctrl+C to exit)
insomnia-eye --once    # print one static frame and return
```

It auto-plays for 4 seconds when entering EPM (`insomnia-ctl epm`).

### 1. `archiso/airootfs/etc/os-release`

```ini
NAME="Insomnia System"
PRETTY_NAME="Insomnia System 0.1 (Dark)"
ID=insomnia
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="1;37"
HOME_URL="https://github.com/ProgrammerKrot/InsomniaSys-beta"
DOCUMENTATION_URL="https://github.com/ProgrammerKrot/InsomniaSys-beta/wiki"
SUPPORT_URL="https://github.com/ProgrammerKrot/InsomniaSys-beta/issues"
LOGO=insomnia-logo
```

### 2. `archiso/airootfs/etc/issue` — TTY Banner

```
\e[1;37m
██╗███╗   ██╗███████╗ ██████╗ ███╗   ███╗███╗   ██╗██╗ █████╗
██║████╗  ██║██╔════╝██╔═══██╗████╗ ████║████╗  ██║██║██╔══██╗
██║██╔██╗ ██║███████╗██║   ██║██╔████╔██║██╔██╗ ██║██║███████║
██║██║╚██╗██║╚════██║██║   ██║██║╚██╔╝██║██║╚██╗██║██║██╔══██║
██║██║ ╚████║███████║╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██║  ██║
╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
\e[0m
  S Y S T E M  v0.1  ·  Arch-based  ·  OLED-native  ·  \l
\e[0;37m  \n \r  ·  \d \t\e[0m

```

### 3. Plymouth OLED Boot Theme

Plymouth theme lives in `archiso/airootfs/usr/share/plymouth/themes/insomnia/`.

**`insomnia.plymouth`**:
```ini
[Plymouth Theme]
Name=Insomnia
Description=Insomnia System OLED boot theme
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/insomnia
ScriptFile=/usr/share/plymouth/themes/insomnia/insomnia.script
```

**`insomnia.script`** (minimal OLED spinner):
```javascript
// insomnia.script — Plymouth boot animation
// Pure black background, white minimal spinner

bg_image = Image(1, 1);
bg_pixel = bg_image.GetPixels();
bg_pixel.SetPixel(0, 0, 0, 0, 0, 255);  // #000000 opaque

Window.SetBackgroundTopColor(0, 0, 0);
Window.SetBackgroundBottomColor(0, 0, 0);

spinner.image = Image("spinner.png");
spinner.x = Window.GetWidth()  / 2 - spinner.image.GetWidth()  / 2;
spinner.y = Window.GetHeight() / 2 - spinner.image.GetHeight() / 2;
spinner.angle = 0;

fun refresh_callback() {
    spinner.angle += 5;
    sprite = Sprite(spinner.image.Rotate(spinner.angle * (3.14159 / 180)));
    sprite.SetX(spinner.x);
    sprite.SetY(spinner.y);
    sprite.SetZ(10);
}

Plymouth.SetRefreshFunction(refresh_callback);
```

Enable the theme in `archiso/airootfs/etc/mkinitcpio.conf`:
```
HOOKS=(base udev plymouth autodetect modconf block filesystems keyboard fsck)
```

Set as default in `airootfs/etc/plymouth/plymouthd.conf`:
```ini
[Daemon]
Theme=insomnia
ShowDelay=0
```

### 4. GNOME OLED Dark Configuration

Inject via dconf profile at `archiso/airootfs/etc/dconf/db/insomnia.d/01-oled-dark`:

```ini
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'
icon-theme='Papirus-Dark'
cursor-theme='Adwaita'
font-name='Inter 10'

[org/gnome/desktop/background]
picture-uri=''
picture-uri-dark=''
primary-color='#000000'
secondary-color='#000000'
color-shading-type='solid'

[org/gnome/mutter]
experimental-features=['variable-refresh-rate', 'scale-monitor-framebuffer']

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-battery-timeout=300
sleep-inactive-battery-type='suspend'
power-button-action='suspend'
```

### 5. Zsh Minimalist Prompt — `archiso/airootfs/etc/zsh/zshrc`

```zsh
# Insomnia System — Global Zshrc
autoload -Uz compinit && compinit

# History
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# Plugins (from packages)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Zoxide
eval "$(zoxide init zsh)"

# Starship prompt (OLED-aware: avoids bright colors)
export STARSHIP_CONFIG=/etc/insomnia/starship.toml
eval "$(starship init zsh)"

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias cat='bat --style=plain'
alias grep='rg'
alias find='fd'
alias top='btop'
alias vim='micro'

# Insomnia shortcuts
alias epm='sudo insomnia-ctl epm'
alias gui='sudo insomnia-ctl gui'
alias regime='insomnia-ctl status'

# Path
export PATH="/usr/local/bin:$PATH"
```

**`/etc/insomnia/starship.toml`** — OLED Prompt:

```toml
# Insomnia System — Starship prompt (OLED-safe: no bright backgrounds)
format = """
$directory$git_branch$git_status$cmd_duration
$character"""

[directory]
style = "bold white"
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "
style = "bold dimmed white"

[git_status]
style = "bold red"

[cmd_duration]
min_time = 500
style = "dimmed white"
format = "took [$duration]($style) "

[character]
success_symbol = "[❯](bold white)"
error_symbol = "[❯](bold red)"

[battery]
full_symbol = "█"
charging_symbol = "↑"
discharging_symbol = "↓"

[[battery.display]]
threshold = 20
style = "bold red"

[[battery.display]]
threshold = 50
style = "bold yellow"
```

---

## Custom Pacman Repository

Host your custom packages (insomnia-core, insomnia-theme-oled, etc.) on GitHub/GitLab using a static file repository pattern.

### Repository Layout (GitHub Pages / GitLab Pages / raw hosting)

```
insomnia-repo/
├── x86_64/
│   ├── insomnia-core-0.1-1-x86_64.pkg.tar.zst
│   ├── insomnia-core-0.1-1-x86_64.pkg.tar.zst.sig
│   ├── insomnia-theme-oled-0.1-1-x86_64.pkg.tar.zst
│   ├── insomnia-theme-oled-0.1-1-x86_64.pkg.tar.zst.sig
│   ├── insomnia.db -> insomnia.db.tar.gz
│   ├── insomnia.db.tar.gz
│   ├── insomnia.files -> insomnia.files.tar.gz
│   └── insomnia.files.tar.gz
└── insomnia.pub    # GPG public key for verification
```

### Building and Publishing Packages

```bash
# scripts/repo/update-repo.sh
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(pwd)/insomnia-repo/x86_64"
PKGBUILD_DIR="$(pwd)/pkgbuilds"
GPG_KEY="YOUR_GPG_KEY_FINGERPRINT"

mkdir -p "$REPO_DIR"

for pkg_dir in "$PKGBUILD_DIR"/*/; do
  pkg_name=$(basename "$pkg_dir")
  echo "[*] Building: $pkg_name"
  (
    cd "$pkg_dir"
    makepkg -sf --noconfirm
    built_pkg=$(ls -t ./*.pkg.tar.zst | head -1)
    gpg --detach-sign --use-agent --no-armor \
        -u "$GPG_KEY" "$built_pkg"
    mv "$built_pkg" "$built_pkg.sig" "$REPO_DIR/"
  )
done

echo "[*] Updating repo database..."
repo-add --sign --key "$GPG_KEY" \
  "$REPO_DIR/insomnia.db.tar.gz" \
  "$REPO_DIR"/*.pkg.tar.zst

echo "[+] Repository updated."
echo "    Push $REPO_DIR to GitHub and enable GitHub Pages."
```

### Configuring Pacman to Use the Repo

In `archiso/airootfs/etc/pacman.conf`, prepend:

```ini
[insomnia]
Server = https://ProgrammerKrot.github.io/insomnia-repo/x86_64
SigLevel = Required DatabaseOptional
```

Add the GPG key to the live system's keyring in `airootfs/etc/pacman.d/insomnia-keys/`:

```bash
# In your archiso customize_airootfs.sh or a systemd oneshot service:
pacman-key --add /etc/pacman.d/insomnia-keys/insomnia.pub
pacman-key --lsign-key YOUR_GPG_KEY_FINGERPRINT
```

### `pkgbuilds/insomnia-core/PKGBUILD`

```bash
# Maintainer: You <you@example.com>
pkgname=insomnia-core
pkgver=0.1
pkgrel=1
pkgdesc="Insomnia System core configuration meta-package"
arch=('any')
url="https://github.com/ProgrammerKrot/InsomniaSys-beta"
license=('MIT')
depends=(
  'tlp' 'powertop' 'cpupower'
  'zellij' 'btop' 'ranger' 'micro'
  'zsh' 'starship' 'zoxide'
  'fzf' 'ripgrep' 'fd' 'bat' 'eza'
)
source=(
  "insomnia-ctl::https://raw.githubusercontent.com/ProgrammerKrot/InsomniaSys-beta/main/archiso/airootfs/usr/local/bin/insomnia-ctl"
  "epm-launch::https://raw.githubusercontent.com/ProgrammerKrot/InsomniaSys-beta/main/archiso/airootfs/usr/local/bin/epm-launch"
  "zshrc::https://raw.githubusercontent.com/ProgrammerKrot/InsomniaSys-beta/main/archiso/airootfs/etc/zsh/zshrc"
  "zellij-layout.kdl::https://raw.githubusercontent.com/ProgrammerKrot/InsomniaSys-beta/main/config/epm/zellij-layout.kdl"
  "starship.toml::https://raw.githubusercontent.com/ProgrammerKrot/InsomniaSys-beta/main/config/epm/starship.toml"
)

package() {
  install -Dm755 insomnia-ctl   "$pkgdir/usr/local/bin/insomnia-ctl"
  install -Dm755 epm-launch     "$pkgdir/usr/local/bin/epm-launch"
  install -Dm644 zshrc          "$pkgdir/etc/zsh/zshrc"
  install -Dm644 zellij-layout.kdl "$pkgdir/etc/insomnia/epm/zellij-layout.kdl"
  install -Dm644 starship.toml  "$pkgdir/etc/insomnia/starship.toml"
}
```

---

## USB Persistence

### Partition Layout for Persistence USB

```
┌──────────────────────────────────────────────────────┐
│  USB Drive (e.g., 32GB)                              │
│                                                      │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │ EFI System  │  │  ISO / Live  │  │ persistence │ │
│  │   ~512MB    │  │    ~4GB      │  │  ~27GB      │ │
│  │  FAT32      │  │  SquashFS    │  │  ext4       │ │
│  └─────────────┘  └──────────────┘  └─────────────┘ │
└──────────────────────────────────────────────────────┘
```

### Flash + Persistence Setup — `scripts/deploy/flash-usb.sh`

```bash
#!/usr/bin/env bash
# flash-usb.sh — Write Insomnia ISO and create persistence partition
set -euo pipefail

ISO="${1:?Usage: flash-usb.sh <iso-file> <device>}"
DEVICE="${2:?Usage: flash-usb.sh <iso-file> <device>}"

[[ $EUID -ne 0 ]] && { echo "[!] Needs root."; exit 1; }
[[ -b "$DEVICE" ]]  || { echo "[!] $DEVICE is not a block device."; exit 1; }

echo "[!] WARNING: $DEVICE will be COMPLETELY ERASED."
read -rp "    Type 'yes' to confirm: " confirm
[[ "$confirm" == "yes" ]] || { echo "Aborted."; exit 0; }

echo "[*] Writing ISO..."
dd if="$ISO" of="$DEVICE" bs=4M status=progress oflag=sync

echo "[*] Re-reading partition table..."
partprobe "$DEVICE"
sleep 2

# Find the end of the last ISO partition
last_sector=$(parted "$DEVICE" --script print | awk '/^ [0-9]/{print $3}' | tail -1 | tr -d 'MB')
# Create persistence partition
echo "[*] Creating persistence partition..."
parted "$DEVICE" --script mkpart primary ext4 "${last_sector}MiB" 100%
partprobe "$DEVICE"
sleep 2

PERSIST_PART="${DEVICE}$(parted "$DEVICE" --script print | awk '/^ [0-9]/{print $1}' | tail -1)"
echo "[*] Formatting persistence partition: $PERSIST_PART"
mkfs.ext4 -L persistence "$PERSIST_PART"

MNT=$(mktemp -d)
mount "$PERSIST_PART" "$MNT"
echo "/union" > "$MNT/persistence.conf"
umount "$MNT"

echo "[+] Done. Persistence partition created at $PERSIST_PART"
echo "    Boot the USB and select 'Insomnia (Persistent)' from the bootloader."
```

### Boot Entry for Persistence (syslinux/GRUB)

Add to `archiso/syslinux/syslinux.cfg`:

```
LABEL insomnia-persist
  MENU LABEL Insomnia System (Persistent)
  LINUX boot/x86_64/vmlinuz-linux
  INITRD boot/x86_64/initramfs-linux.img
  APPEND archisobasedir=arch archisolabel=INSOMNIA_YYYYMM cow_spacesize=1G \
         persistence persistence-label=persistence quiet splash \
         vt.global_cursor_default=0 loglevel=3
```

---

## Contributing

```
git clone https://github.com/ProgrammerKrot/InsomniaSys-beta
cd InsomniaSystem

# Build a package locally
cd pkgbuilds/insomnia-core
makepkg -si

# Test in a VM first
sudo ./scripts/build/build-iso.sh
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -cpu host \
  -drive file=output/insomnia-*.iso,media=cdrom \
  -boot d
```

---

*"Stay awake. Stay minimal."*

```
# Insomnia System is Free Software — MIT License
# No telemetry. No bloat. No mercy for battery drain.
```
