# ballast-pilot

The deployment layer for [`ballast-guard`](https://github.com/j0yen/ballast-guard): a default config plus a systemd user timer that runs the guard once an hour, keeping disk usage inside a high/low-water SLO.

## Why it exists

A binary that checks disk usage does nothing until something runs it on a schedule. `ballast-pilot` is that something. It supplies the guard with a config encoding the water marks and a timer that fires it hourly — the difference between a tool you remember to run and a tool that runs itself.

The default posture is deliberately cautious. `mode = "report"` means the guard observes and logs events but never deletes. Autonomous reaping is a single, documented opt-in: flip `mode = "enforce"` in `guard.toml`, and not before.

## What's included

| File | Purpose |
|------|---------|
| `guard.toml` | Default config: high-water 90%, advisory 85%, low-water 80%, scan `~/wintermute`, `mode = "report"` |
| `ballast-guard.service` | `Type=oneshot` systemd user service that runs one guard pass |
| `ballast-guard.timer` | Hourly (`OnCalendar=*:00`), `Persistent=true` so a missed window still fires |
| `install.sh` | Idempotent install: copies units, writes the default config if absent, enables and starts the timer |
| `uninstall.sh` | Disables and removes the units; preserves `guard.toml` and the event log |

## Install

```bash
git clone https://github.com/j0yen/ballast-pilot ~/wintermute/ballast-pilot
cd ~/wintermute/ballast-pilot
./install.sh
```

`install.sh` is safe to re-run. It never clobbers an existing tuned `guard.toml` and only reloads the daemon when a unit file actually changed.

Verify:

```bash
systemctl --user is-enabled ballast-guard.timer   # → enabled
systemctl --user list-timers | grep ballast        # shows the next fire time
```

## Configuration

The thresholds live in `~/.config/ballast/guard.toml`. `install.sh` writes the default there if none exists and leaves an existing one untouched.

To enable autonomous reaping, change `mode = "report"` to `mode = "enforce"`. That is the only switch that lets the guard delete anything.

## Event log

Each pass appends a JSON line to `~/.local/state/ballast/guard-events.jsonl` with the usage percent, SLO band, and exit code. This is the same log [`ballast-digest`](https://github.com/j0yen/ballast-digest) reads for its headline and 24-hour reclaimed total.

## Uninstall

```bash
./uninstall.sh
```

The units are removed; `guard.toml` and the event log are preserved.

## Depends on

- the [`ballast-guard`](https://github.com/j0yen/ballast-guard) binary at `~/.cargo/bin/ballast-guard`
- an active systemd user session (`loginctl enable-linger $USER` if the box is headless)

## Part of the ballast fleet

A family of read-mostly disk-health tools for the wintermute workspace. `ballast-pilot` schedules the guard; the others measure and summarize.

| Tool | Job |
|------|-----|
| [`ballast-survey`](https://github.com/j0yen/ballast-survey) | Measure what is big right now |
| [`ballast-trend`](https://github.com/j0yen/ballast-trend) | Measure what is growing and how fast |
| [`ballast-guard`](https://github.com/j0yen/ballast-guard) | Watch usage against an SLO; log events; reclaim on opt-in |
| **`ballast-pilot`** | Wire the guard to an hourly systemd timer ← you are here |
| [`ballast-digest`](https://github.com/j0yen/ballast-digest) | Synthesize survey + trend + events into one ranked block |
