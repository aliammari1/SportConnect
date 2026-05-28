#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-$(pwd)}"
GOOGLE_SERVICE_INFO_PLIST="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"
UPLOAD_SYMBOLS="$ROOT_DIR/ios/Pods/FirebaseCrashlytics/upload-symbols"
ARCHIVE_ROOT="$ROOT_DIR/build/ios/archive"

if [[ ! -f "$GOOGLE_SERVICE_INFO_PLIST" ]]; then
  echo "::error file=ios/Runner/GoogleService-Info.plist::Missing Firebase iOS config"
  exit 1
fi

if [[ ! -x "$UPLOAD_SYMBOLS" ]]; then
  echo "::error file=ios/Pods/FirebaseCrashlytics/upload-symbols::Crashlytics upload-symbols script is missing. Run pod install via flutter build first."
  exit 1
fi

FIREBASE_APP_ID=$(/usr/libexec/PlistBuddy -c "Print :GOOGLE_APP_ID" "$GOOGLE_SERVICE_INFO_PLIST")

ARCHIVE_PATH=""
for archive in "$ARCHIVE_ROOT"/*.xcarchive; do
  if [[ -d "$archive" ]]; then
    ARCHIVE_PATH="$archive"
    break
  fi
done

if [[ -z "${ARCHIVE_PATH:-}" ]]; then
  echo "::error file=build/ios/archive::No .xcarchive found after the iOS build"
  exit 1
fi

DSYM_DIR="$ARCHIVE_PATH/dSYMs"
if [[ ! -d "$DSYM_DIR" ]]; then
  echo "::error file=$ARCHIVE_PATH::Archive does not contain a dSYMs directory"
  exit 1
fi

count=0
while IFS= read -r -d '' dsym; do
  count=$((count + 1))
  echo "Uploading $(basename "$dsym") to Firebase Crashlytics"
  "$UPLOAD_SYMBOLS" -ai "$FIREBASE_APP_ID" -p ios "$dsym"
done < <(find "$DSYM_DIR" -type d -name "*.dSYM" -print0)

if [[ "$count" -eq 0 ]]; then
  echo "::error file=$DSYM_DIR::No dSYM bundles found to upload"
  exit 1
fi

echo "Uploaded $count dSYM bundle(s) to Firebase Crashlytics"
