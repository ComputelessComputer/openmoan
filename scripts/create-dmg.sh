#!/usr/bin/env bash

set -euo pipefail

TAG="${1:?tag is required}"
APP_PATH="${2:?app path is required}"
OUTPUT_DIR="${3:?output dir is required}"

APP_NAME="$(basename "$APP_PATH" .app)"
DMG_PATH="$OUTPUT_DIR/${APP_NAME}-${TAG}-macos.dmg"
CHECKSUM_PATH="${DMG_PATH}.sha256"

mkdir -p "$OUTPUT_DIR"

DMG_STAGING="$(mktemp -d)"
cleanup() {
  rm -rf "$DMG_STAGING"
}
trap cleanup EXIT

cp -R "$APP_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

rm -f "$DMG_PATH" "$CHECKSUM_PATH"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

shasum -a 256 "$DMG_PATH" > "$CHECKSUM_PATH"

echo "DMG: $DMG_PATH"
echo "Checksum: $CHECKSUM_PATH"
