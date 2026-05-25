#!/usr/bin/env bash
set -euo pipefail

BUNDLE_NAME="ZellijSweep"
SCHEME="Zellij-Sweep"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="${TMPDIR:-/tmp}/zellij-sweep-derived-data"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/$BUNDLE_NAME.app"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

./stop-menubar.sh || true

TUIST_SKIP_UPDATE_CHECK=1 tuist generate --no-open
TUIST_SKIP_UPDATE_CHECK=1 tuist xcodebuild build \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH"

open "$APP_PATH"
