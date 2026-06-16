# ballast-pilot

Systemd timer + default config that wires [`ballast-guard`](https://github.com/j0yen/ballast-guard) to run hourly, keeping disk usage within a high/low-water SLO.

## TL;DR

The disk climbed 86% → 92% → 96% over three days while self-review journals printed manual `du` suggestions. ballast-pilot fixes that: it gives `ballast-guard` a config file encoding the vision's water marks and a timer that fires it every hour. The default posture is **report-only** — it observes and logs events but never deletes until you explicitly flip `mode = "enforce"` in `guard.toml`.

## What's included

| File | Purpose |
|------|---------|
| `guard.toml` | Default config: high-water 90%, advisory 85%, low-water 80%, scan `~/wintermute`, `mode = "report"` |
| `ballast-guard.service` | Type=oneshot systemd user service that runs one guard pass |
| `ballast-guard.timer` | Hourly (`OnCalendar=*:00`), `Persistent=true` so missed windows still fire |
| `install.sh` | Idempotent install: copies units, writes default config if absent, enables+starts timer |
| `uninstall.sh` | Disables+removes units; preserves `guard.toml` and event log |

## Install

```bash
git clone https://github.com/j0yen/ballast-pilot ~/wintermute/ballast-pilot
cd ~/wintermute/ballast-pilot
./install.sh
```

Verify:
```bash
systemctl --user is-enabled ballast-guard.timer   # → enabled
systemctl --user list-timers | grep ballast        # shows next fire time
```

## Configuration

Edit `~/.config/ballast/guard.toml` to tune thresholds. The `install.sh` writes a default if absent and never clobbers an existing config.

**To enable autonomous reaping**, change `mode = "report"` to `mode = "enforce"` in `~/.config/ballast/guard.toml`. This is the single, documented opt-in switch.

## Event log

Each guard pass appends JSON lines to `~/.local/state/ballast/guard-events.jsonl` containing the usage percent, SLO band, and exit code.

## Uninstall

```bash
./uninstall.sh
```

Units are removed; `guard.toml` and the event log are preserved.

## Depends on

- [`ballast-guard`](https://github.com/j0yen/ballast-guard) binary at `~/.cargo/bin/ballast-guard`
- systemd user session active (`loginctl enable-linger $USER` if running headless)
