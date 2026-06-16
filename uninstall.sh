#!/usr/bin/env bash
# ballast-pilot uninstall.sh — removes the timer/service units and reloads
# Preserves guard.toml and the event log (per AC5).
set -euo pipefail

SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"

echo "[uninstall] Stopping and disabling ballast-guard.timer"
systemctl --user stop ballast-guard.timer 2>/dev/null || true
systemctl --user disable ballast-guard.timer 2>/dev/null || true

echo "[uninstall] Removing unit files"
rm -f "${SYSTEMD_USER_DIR}/ballast-guard.timer"
rm -f "${SYSTEMD_USER_DIR}/ballast-guard.service"

echo "[uninstall] Reloading user daemon"
systemctl --user daemon-reload

echo "[uninstall] Done. guard.toml and event log preserved."
echo "  Config:    ${HOME}/.config/ballast/guard.toml"
echo "  Event log: ${HOME}/.local/state/ballast/guard-events.jsonl"
