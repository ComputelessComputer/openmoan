#!/usr/bin/env bash

set -euo pipefail

REPO="taigrr/spank"
OUTPUT_DIR="${1:-.build/spank}"

mkdir -p "$OUTPUT_DIR"

if [[ -x "$OUTPUT_DIR/spank" ]]; then
  echo "$OUTPUT_DIR/spank"
  exit 0
fi

TAG=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep '"tag_name"' | head -1 | sed 's/.*: *"//;s/".*//')

VERSION="${TAG#v}"
TARBALL="spank_${VERSION}_darwin_arm64.tar.gz"
URL="https://github.com/$REPO/releases/download/$TAG/$TARBALL"

echo "Fetching spank $TAG from $URL..." >&2
curl -sL "$URL" -o "$OUTPUT_DIR/$TARBALL"
tar -xzf "$OUTPUT_DIR/$TARBALL" -C "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR/$TARBALL"

if [[ ! -x "$OUTPUT_DIR/spank" ]]; then
  echo "Error: spank binary not found after extracting $TARBALL" >&2
  exit 1
fi

echo "$OUTPUT_DIR/spank"
