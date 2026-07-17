#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ "${BAILEYS_RESET_SESSION:-0}" = "1" ]; then
  rm -rf auth-session
fi

if [ ! -d node_modules ]; then
  npm install
fi

npm start
