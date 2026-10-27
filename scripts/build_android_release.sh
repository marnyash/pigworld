#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_format="${1:-appbundle}"

if [[ "$build_format" != "appbundle" && "$build_format" != "apk" ]]; then
  echo "Usage: bash scripts/build_android_release.sh [appbundle|apk]" >&2
  exit 2
fi

cd "$project_root"
flutter build "$build_format" \
  --release \
  --obfuscate \
  --split-debug-info=build/obfuscation/android
