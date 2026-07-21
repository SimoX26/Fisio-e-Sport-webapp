#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
PID_FILE="$SCRIPT_DIR/baileys-service.pid"

if [ -f "$PID_FILE" ]; then
  EXISTING_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "${EXISTING_PID}" ] && kill -0 "$EXISTING_PID" 2>/dev/null; then
    exit 0
  fi
  rm -f "$PID_FILE"
fi

if [ "${BAILEYS_RESET_SESSION:-0}" = "1" ]; then
  rm -rf auth-session
fi

if [ ! -d node_modules ]; then
  npm install
fi

echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT
exec npm start
