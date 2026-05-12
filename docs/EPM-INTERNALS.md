# EPM Internals — Extreme Power Mode Deep Dive

## Power Budget Targets

| Component | Normal (GUI) | EPM Target |
|-----------|-------------|------------|
| CPU (idle) | ~4–8W | ~1–2W |
| Display | ~3–6W | ~0.5–1W (min brightness) |
| WiFi | ~0.5–2W | 0W (blocked in strict mode) |
| RAM | ~1–3W | ~1–2W (no change) |
| **Total** | **~10–20W** | **< 5W** |

## CPU Frequency Scaling

EPM uses the `powersave` governor which caps CPU at the lowest P-state.
For fine-grained control, use `cpupower`:

```bash
# View current status
cpupower frequency-info

# Set max frequency cap (e.g., 800MHz on battery)
cpupower frequency-set -u 800MHz

# Or use TLP's automatic per-policy settings in /etc/tlp.conf:
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_MAX_PERF_ON_BAT=30
CPU_BOOST_ON_BAT=0
```

## TLP Configuration

TLP provides the deepest power savings with minimal configuration.
Key settings for Insomnia EPM (`/etc/tlp.conf`):

```ini
TLP_ENABLE=1
TLP_DEFAULT_MODE=BAT

CPU_SCALING_GOVERNOR_ON_AC=schedutil
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
CPU_MAX_PERF_ON_AC=100
CPU_MAX_PERF_ON_BAT=30

RUNTIME_PM_ON_AC=auto
RUNTIME_PM_ON_BAT=auto

WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

NMI_WATCHDOG=0
DISK_APM_LEVEL_ON_BAT=1
SATA_LINKPWR_ON_BAT=min_power

USB_AUTOSUSPEND=1
USB_EXCLUDE_AUDIO=1
```

## Kernel Boot Parameters for EPM

Add to bootloader entry for maximum power savings:

```
quiet splash
loglevel=3
vt.global_cursor_default=0
nmi_watchdog=0
pcie_aspm=force
pcie_aspm.policy=powersupersave
i915.enable_psr=1
i915.enable_fbc=1
```

## Services Disabled in EPM

`insomnia-ctl epm` additionally masks these units (optional, aggressive):

```bash
systemctl mask \
  ModemManager.service \
  bluetooth.service \
  avahi-daemon.service \
  cups.service \
  geoclue.service
```

Re-enable all with: `insomnia-ctl gui` (unmasks automatically).

## Measuring Real Power Draw

```bash
# After entering EPM, measure actual consumption:
sudo powertop --time=10 --csv=/tmp/epm-power.csv

# Or watch live:
sudo powertop

# Check battery discharge rate directly:
watch -n1 "cat /sys/class/power_supply/BAT0/power_now && \
           echo 'µW discharge'"
```
