#!/usr/bin/env bash
set -euo pipefail

APP_DISPLAY_NAME="Zellij-Sweep"
EXECUTABLE_NAME="ZellijSweep"

if pgrep -x "$EXECUTABLE_NAME" >/dev/null; then
  osascript -e "tell application \"$APP_DISPLAY_NAME\" to quit" >/dev/null 2>&1 || true
  sleep 0.5
  pkill -x "$EXECUTABLE_NAME" >/dev/null 2>&1 || true
fi
