#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
# Every run gets its own bundle; existing results never need to be deleted.
result_path="${DIPPER_TEST_RESULTS:-build/TestResults/DipperPDF-$(date +%Y%m%d-%H%M%S)-$$.xcresult}"
mkdir -p "$(dirname "$result_path")"
xcodebuild -project DipperPDF.xcodeproj -scheme DipperPDF \
  -configuration Debug -destination 'platform=macOS' \
  -derivedDataPath build -resultBundlePath "$result_path" \
  -enableCodeCoverage YES test "$@"
