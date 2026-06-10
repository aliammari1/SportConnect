#!/usr/bin/env bash
set -e

export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
export PATH="$HOME/.npm-packages/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

echo "Building Cloud Functions..."
(cd functions && npm run build)

echo "Starting Firebase Emulators..."
firebase emulators:start \
  --import=".emulator-data" \
  --export-on-exit=".emulator-data"
