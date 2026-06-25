#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="CodexUsageBar"
SOURCE_APP="$ROOT_DIR/dist/$APP_NAME.app"
TARGET_APP="/Applications/$APP_NAME.app"
ADD_LOGIN_ITEM="${1:-}"

cd "$ROOT_DIR"
CONFIGURATION=release "$ROOT_DIR/script/build_and_run.sh" --build-only

pkill -x "$APP_NAME" >/dev/null 2>&1 || true
codesign --force --deep --sign - "$SOURCE_APP" >/dev/null 2>&1 || true
rm -rf "$TARGET_APP"
ditto "$SOURCE_APP" "$TARGET_APP"
open -n "$TARGET_APP"

if [[ "$ADD_LOGIN_ITEM" == "--login" ]]; then
  osascript -e 'tell application "System Events" to if not (exists login item "CodexUsageBar") then make login item at end with properties {path:"/Applications/CodexUsageBar.app", hidden:false}'
fi

printf '%s\n' "$TARGET_APP"
