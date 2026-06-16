#!/bin/sh
set -eu
STATE_DIR="${HOME}/.local/state/ballast"
mkdir -p "${STATE_DIR}"
EVENT_SINK="${STATE_DIR}/guard-events.jsonl"
if command -v ballast-guard >/dev/null 2>&1; then
    exec ballast-guard run --mount / --event-sink "${EVENT_SINK}"
else
    TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    printf '{"ts":"%s","level":"info","msg":"ballast-guard binary not installed — pilot wiring only, skipping run"}\n' "${TS}" >> "${EVENT_SINK}"
fi
