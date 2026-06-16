#!/usr/bin/env bash
# ballast-pilot install.sh — idempotent wiring of ballast-guard to a systemd user timer
# Safe to re-run: never overwrites existing guard.toml or unit files unless forced.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
BALLAST_CFG_DIR="${HOME}/.config/ballast"
STATE_DIR="${HOME}/.local/state/ballast"

# ── 1. Create directories ─────────────────────────────────────────────────────
mkdir -p "${SYSTEMD_USER_DIR}" "${BALLAST_CFG_DIR}" "${STATE_DIR}"

# ── 2. Default guard.toml — never clobber an existing tuned config ─────────
if [[ ! -f "${BALLAST_CFG_DIR}/guard.toml" ]]; then
    echo "[install] Writing default guard.toml (mode=report)"
    cp "${SCRIPT_DIR}/guard.toml" "${BALLAST_CFG_DIR}/guard.toml"
else
    echo "[install] guard.toml already exists — skipping (preserving user config)"
fi

# ── 3. Install systemd unit files ─────────────────────────────────────────────
changed=0
for unit in ballast-guard.service ballast-guard.timer; do
    src="${SCRIPT_DIR}/${unit}"
    dst="${SYSTEMD_USER_DIR}/${unit}"
    if [[ ! -f "${dst}" ]] || ! cmp -s "${src}" "${dst}"; then
        echo "[install] Installing ${unit}"
        cp "${src}" "${dst}"
        changed=1
    else
        echo "[install] ${unit} already up to date"
    fi
done

# ── 4. Reload daemon if anything changed ──────────────────────────────────────
if [[ "${changed}" -eq 1 ]]; then
    echo "[install] Running systemctl --user daemon-reload"
    systemctl --user daemon-reload
fi

# ── 5. Enable and start the timer ─────────────────────────────────────────────
if ! systemctl --user is-enabled ballast-guard.timer &>/dev/null; then
    echo "[install] Enabling ballast-guard.timer"
    systemctl --user enable ballast-guard.timer
else
    echo "[install] ballast-guard.timer already enabled"
fi

if ! systemctl --user is-active ballast-guard.timer &>/dev/null; then
    echo "[install] Starting ballast-guard.timer"
    systemctl --user start ballast-guard.timer
else
    echo "[install] ballast-guard.timer already active"
fi

# ── 6. Show next-fire time ────────────────────────────────────────────────────
echo ""
echo "[install] Done. Next timer fires:"
systemctl --user list-timers ballast-guard.timer --no-pager 2>/dev/null || true
