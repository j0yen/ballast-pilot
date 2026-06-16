#!/bin/sh
set -eu
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ballast"
BIN_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$UNIT_DIR" "$CONFIG_DIR" "$BIN_DIR"
# Never overwrite existing guard.toml
if [ ! -f "$CONFIG_DIR/guard.toml" ]; then
    install -m644 "$SCRIPT_DIR/guard.toml" "$CONFIG_DIR/guard.toml"
    echo "Installed $CONFIG_DIR/guard.toml"
else
    echo "guard.toml already present — skipping (edit manually to tune)"
fi
install -m755 "$SCRIPT_DIR/ballast-guard-run.sh" "$BIN_DIR/ballast-guard-run.sh"
install -m644 "$SCRIPT_DIR/ballast-guard.service" "$UNIT_DIR/ballast-guard.service"
install -m644 "$SCRIPT_DIR/ballast-guard.timer" "$UNIT_DIR/ballast-guard.timer"
systemctl --user daemon-reload
systemctl --user enable --now ballast-guard.timer
echo "Next fire: $(systemctl --user list-timers ballast-guard.timer --no-legend | awk '{print $1, $2}')"
