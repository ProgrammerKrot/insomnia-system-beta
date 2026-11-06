# EPM Internals — Extreme Power Mode

## The math first

Battery life is just `capacity (Wh) ÷ average draw (W)`. Everything in EPM
exists to push the average draw down.

| Battery capacity | 4 h means | 12 h needs | 
|------------------|-----------|------------|
| 20 Wh            | ~5.0 W    | **≤ 1.7 W** |
| 40 Wh            | ~10 W     | **≤ 3.3 W** |
| 55 Wh            | ~14 W     | **≤ 4.6 W** |

`insomnia-batt` shows your battery's real capacity, its wear (% of design),
and the live "12H" budget for *your* pack, so you always know whether the
target is reachable.

> **Reference machine (Dell Vostro 5502, i7‑1165G7):** the battery has worn
> to **51 % of design (≈20 Wh of 40 Wh)**. A Tiger Lake laptop with the panel
> lit bottoms out around 2.5–4 W, so on this pack EPM realistically gives
> **~5–8 h**, not 12. With a fresh 40 Wh battery, `dark` EPM at ~3 W gets to
> **~12–13 h**. Replacing the battery is the single biggest win available.

## Where the watts go (TTY, idle-ish)

| Component | GNOME on battery | EPM | EPM `dark` |
|-----------|------------------|-----|------------|
| Panel backlight | 2–4 W | 0.6–1 W (15 %) | 0.3–0.5 W (5 %) |
| CPU package | 1.5–4 W | 0.6–1.2 W | 0.5–1 W |
| iGPU / compositor | 0.5–2 W | ~0 (no compositor) | ~0 |
| Wi-Fi | 0.3–1.5 W | 0.2–0.5 W (power-save) | 0 |
| Bluetooth, webcam, USB | 0.2–0.8 W | ~0 | ~0 |
| Platform (RAM, SSD, EC) | 1–2 W | 0.8–1.5 W | 0.8–1.5 W |
| **Total** | **~6–14 W** | **~2.5–4.5 W** | **~2–3.5 W** |

Ranges are typical for 11th–13th gen Intel / Ryzen 5000+ ultrabooks; measure
your own with `insomnia-batt` (avg column) or `sudo powertop`.

## Regimes

```bash
sudo insomnia-ctl epm    # Wi-Fi on with power-save, Bluetooth/WWAN/NFC off
sudo insomnia-ctl dark   # every radio off, deeper CPU + backlight caps
sudo insomnia-ctl gui    # exact restore + display manager
insomnia-ctl status
```

Shell aliases: `epm`, `dark`, `gui`, `regime`, `batt`, `drain` (powertop).

## What `insomnia-power` does

Every write is recorded (original value, first write wins) in
`/run/insomnia/snapshot`; `gui` replays it in reverse. Nothing is guessed on
the way back, so the GUI returns to whatever TLP/firmware had set.

| Area | `epm` | `dark` | Knob |
|------|-------|--------|------|
| CPU governor | powersave | powersave | `cpufreq/policy*/scaling_governor` |
| CPU EPP | power | power | `energy_performance_preference` |
| Turbo | off | off | `intel_pstate/no_turbo`, `cpufreq/boost` |
| Max freq | 60 % | 40 % | `scaling_max_freq` (`EPM_CPU_CAP`, `EPM_CPU_CAP_DARK`) |
| Platform profile | low-power | low-power | `/sys/firmware/acpi/platform_profile` |
| Intel iGPU | no boost, max = RP1 | same | `gt_boost_freq_mhz`, `gt_max_freq_mhz` |
| AMD GPU | low | low | `power_dpm_force_performance_level` |
| PCI runtime PM | auto | auto | `power/control` |
| USB autosuspend | on, **HID excluded** | same | keyboards/mice never suspend |
| SATA link | med_power_with_dipm | same | `link_power_management_policy` |
| PCIe ASPM | powersave | powersupersave | firmware may refuse — harmless |
| HDA audio | power_save=1 | same | `snd_hda_intel` |
| NMI watchdog | off | off | `kernel.nmi_watchdog` |
| Disk writeback | 15 s | 15 s | `vm.dirty_writeback_centisecs` |
| Backlight | 15 % | 5 % | `EPM_BRIGHTNESS`, `EPM_BRIGHTNESS_DARK` |
| Keyboard backlight | off | off | `leds/*kbd_backlight*` |
| Radios | BT/NFC/WWAN off, Wi-Fi power-save | all off | rfkill + `iw` |
| Idle services | stopped | stopped | bluetooth, cups, avahi, ModemManager, geoclue, packagekit, fwupd, colord, switcheroo-control |

Plus, from `epm-launch` on the console: screen blanks after 3 idle minutes and
DPMS powers the panel down after 5 (`setterm`).

Tune the caps without editing code, e.g. in `/etc/environment`:

```bash
EPM_CPU_CAP=50
EPM_BRIGHTNESS=10
```

### AC ↔ battery

`/etc/udev/rules.d/90-insomnia-power.rules` fires on a charger change. TLP
re-applies its own profile on the same event, so `insomnia-power reapply` runs
5 s later and puts the EPM caps back (only while on battery and in EPM).

## Always-on battery profile (TLP)

`/etc/tlp.d/90-insomnia.conf` applies on battery in **both** regimes, so GNOME
also gets: powersave + EPP `power`, no turbo, `low-power` platform profile,
runtime PM, ASPM `powersupersave`, Wi-Fi power-save, Bluetooth/WWAN off when
unused, audio power-save, no NMI watchdog. `power-profiles-daemon` and
`systemd-rfkill` are masked because they fight TLP.

## Dashboard design (why it's cheap)

- Only **one** always-running pane: `insomnia-batt`, 10 s refresh, bash
  builtins only.
- `btop`, `nmtui`, `bandwhich`, `lf` live in other tabs and are
  **start_suspended** — they cost nothing until you press Enter.
- `session_serialization false` stops zellij writing session state to disk.
- Raw Linux console, no compositor, no GPU work beyond scanout.

Things deliberately **not** running in EPM: `cava`, `cmatrix`, animated
splash loops (the eye animates for 2 s only), anything with sub-second refresh.

## Kernel parameters (optional, test first)

Add to the installed system's bootloader entry once you've confirmed the
machine is stable with them:

```
nmi_watchdog=0 pcie_aspm.policy=powersupersave i915.enable_psr=1 i915.enable_fbc=1 consoleblank=180
```

Avoid `pcie_aspm=force` unless you've tested it — on some boards it hangs
NVMe or Wi-Fi.

## Measuring

```bash
batt                                     # live: draw, avg, ETA, 12h budget, wear
sudo powertop                            # per-device / per-process wake-ups
sudo powertop --auto-tune                # one-off: see what TLP missed
sudo powertop --time=60 --html=/tmp/epm.html
```

Measure for at least 10 minutes on battery after entering EPM; the first
minute after a mode switch is always noisy.
