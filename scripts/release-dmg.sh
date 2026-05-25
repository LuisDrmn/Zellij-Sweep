#!/usr/bin/env bash
set -euo pipefail

APP_DISPLAY_NAME="Zellij-Sweep"
APP_BUNDLE_NAME="ZellijSweep"
SCHEME="Zellij-Sweep"
CONFIGURATION="Release"
BUNDLE_ID="dev.jldrmn.Zellij-Sweep"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-${VERSION:-}}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 1.0.0" >&2
  exit 64
fi

if [[ -z "${DEVELOPMENT_TEAM:-}" ]]; then
  echo "DEVELOPMENT_TEAM is required." >&2
  exit 64
fi

SIGNING_IDENTITY="${SIGNING_IDENTITY:-Developer ID Application}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-$DEVELOPMENT_TEAM}"

if [[ -z "${NOTARYTOOL_PROFILE:-}" ]]; then
  if [[ -z "${APPLE_ID:-}" || -z "${APPLE_APP_SPECIFIC_PASSWORD:-}" || -z "$APPLE_TEAM_ID" ]]; then
    echo "Provide NOTARYTOOL_PROFILE, or APPLE_ID + APPLE_APP_SPECIFIC_PASSWORD + APPLE_TEAM_ID." >&2
    exit 64
  fi
fi

RELEASE_DIR="$ROOT_DIR/build/release/$VERSION"
DERIVED_DATA_PATH="$RELEASE_DIR/DerivedData"
ARCHIVE_PATH="$RELEASE_DIR/$APP_DISPLAY_NAME.xcarchive"
APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_BUNDLE_NAME.app"
DMG_STAGING_DIR="$RELEASE_DIR/dmg-staging"
DMG_PATH="$RELEASE_DIR/$APP_DISPLAY_NAME-$VERSION.dmg"
SHA_PATH="$DMG_PATH.sha256"

rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

cd "$ROOT_DIR"

TUIST_SKIP_UPDATE_CHECK=1 tuist generate --no-open

TUIST_SKIP_UPDATE_CHECK=1 tuist xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  ENABLE_HARDENED_RUNTIME=YES \
  OTHER_CODE_SIGN_FLAGS="--timestamp"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app not found at $APP_PATH" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

mkdir -p "$DMG_STAGING_DIR"
cp -R "$APP_PATH" "$DMG_STAGING_DIR/"
ln -s /Applications "$DMG_STAGING_DIR/Applications"

hdiutil create \
  -volname "$APP_DISPLAY_NAME" \
  -srcfolder "$DMG_STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

codesign --force --timestamp --sign "$SIGNING_IDENTITY" "$DMG_PATH"

if [[ -n "${NOTARYTOOL_PROFILE:-}" ]]; then
  xcrun notarytool submit "$DMG_PATH" \
    --keychain-profile "$NOTARYTOOL_PROFILE" \
    --wait
else
  xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait
fi

xcrun stapler staple "$DMG_PATH"
spctl -a -vvv -t open --context context:primary-signature "$DMG_PATH"
shasum -a 256 "$DMG_PATH" > "$SHA_PATH"

echo "Created $DMG_PATH"
echo "Created $SHA_PATH"
