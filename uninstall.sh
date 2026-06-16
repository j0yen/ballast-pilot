#!/bin/sh
set -eu
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
systemctl --user disable --now ballast-guard.timer 2>/dev/null || true
rm -f "$UNIT_DIR/ballast-guard.service" "$UNIT_DIR/ballast-guard.timer"
rm -f "${HOME}/.local/bin/ballast-guard-run.sh"
systemctl --user daemon-reload
echo "ballast-guard timer and service removed (guard.toml and event log preserved)"
