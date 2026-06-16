# ballast-pilot

**TL;DR:** systemd timer wiring for `ballast-guard` — runs an hourly disk SLO check and (optionally) autonomously reaps low-value artifacts when disk usage crosses a configurable high-water mark.

Default mode is `report` (dry-run). Set `mode = "enforce"` in `~/.config/ballast/guard.toml` to enable autonomous reaping.

## Install

```sh
bash install.sh
```

The installer is idempotent: running it twice is safe. It will never overwrite an existing `guard.toml`.

### What gets installed

| File | Destination |
|------|-------------|
| `guard.toml` | `~/.config/ballast/guard.toml` (only if absent) |
| `ballast-guard.service` | `~/.config/systemd/user/ballast-guard.service` |
| `ballast-guard.timer` | `~/.config/systemd/user/ballast-guard.timer` |

The timer fires every hour on the hour (`OnCalendar=*:00`) and is enabled immediately on install.

## Usage

### Check timer status

```sh
systemctl --user list-timers ballast-guard.timer
```

### Run the guard manually

```sh
systemctl --user start ballast-guard.service
```

Events are written to `~/.local/state/ballast/guard-events.jsonl` (one JSON object per line).

### Configuration (`~/.config/ballast/guard.toml`)

| Key | Default | Description |
|-----|---------|-------------|
| `mode` | `"report"` | `"report"` = dry-run; `"enforce"` = autonomous reap |
| `high_water_pct` | `90` | Trigger threshold (% disk used) |
| `low_water_pct` | `80` | Target after reaping |
| `advisory_pct` | `85` | Emit advisory events above this threshold |
| `scan_roots` | `["/home/jsy/wintermute"]` | Directories to scan for reap candidates |
| `safety_floor` | `"fossil"` | Never reap artifacts at or above this safety class |
| `event_sink` | `~/.local/state/ballast/guard-events.jsonl` | JSONL event log path |

### Uninstall

```sh
bash uninstall.sh
```

Removes the systemd units only. Your `guard.toml` and the event log at `~/.local/state/ballast/` are preserved.

## License

MIT — Joe Yen
