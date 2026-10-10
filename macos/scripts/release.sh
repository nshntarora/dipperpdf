#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scripts/release.sh VERSION [--build-only]

Build a universal macOS Release app, package a DMG, and publish a GitHub release.
VERSION must be three numbers, e.g. 1.0.0 (the Git tag is v1.0.0).
--build-only creates local artifacts without contacting GitHub or publishing.

Optional environment:
  DIPPER_BUILD_NUMBER       Positive integer bundle build number (default: 1)
  DIPPER_SIGNING_IDENTITY   Developer ID Application certificate name
  DIPPER_NOTARY_PROFILE     notarytool Keychain profile (required with identity)

Without signing credentials, the app is ad hoc signed and not notarized.
Downloads will require a manual Gatekeeper override to open.
EOF
}

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

if [[ "${1:-}" == '--help' || "${1:-}" == '-h' ]]; then
  usage
  exit 0
fi
[[ $# -ge 1 && $# -le 2 ]] || { usage >&2; exit 1; }
version="$1"
[[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || fail 'Use a version such as 1.0.0.'
build_only=false
if [[ $# -eq 2 ]]; then
  [[ "$2" == '--build-only' ]] || fail "Unknown option: $2"
  build_only=true
fi

cd "$(dirname "$0")/.."
app_root="$PWD"
repo='nshntarora/dipperpdf'
tag="v$version"
build_number="${DIPPER_BUILD_NUMBER:-1}"
[[ "$build_number" =~ ^[1-9][0-9]*$ ]] || fail 'DIPPER_BUILD_NUMBER must be a positive integer.'
identity="${DIPPER_SIGNING_IDENTITY:--}"
notary_profile="${DIPPER_NOTARY_PROFILE:-}"
if [[ "$identity" != '-' ]]; then
  [[ "$identity" == 'Developer ID Application: '* ]] || fail 'Use a Developer ID Application signing identity.'
  [[ -n "$notary_profile" ]] || fail 'Set DIPPER_NOTARY_PROFILE for Developer ID distribution.'
elif [[ -n "$notary_profile" ]]; then
  fail 'Set DIPPER_SIGNING_IDENTITY when using notarization.'
fi

[[ "$(uname -s)" == Darwin ]] || fail 'Run this script on a Mac with full Xcode installed.'
for command in xcodebuild xcrun hdiutil codesign ditto shasum git; do
  command -v "$command" >/dev/null || fail "Missing required command: $command"
done
xcodebuild -version >/dev/null
commit="$(git rev-parse HEAD)"
if [[ "$build_only" == false ]]; then
  command -v gh >/dev/null || fail 'Install GitHub CLI and run gh auth login first.'
  [[ -z "$(git status --porcelain --untracked-files=normal)" ]] || fail 'Commit your changes and push them before publishing (or use --build-only).'
  gh auth status
  # A release must describe the exact source that was built, already on GitHub.
  gh api "repos/$repo/commits/$commit" --silent
  existing_tag="$(gh api "repos/$repo/git/matching-refs/tags/$tag" --jq ".[] | select(.ref == \"refs/tags/$tag\") | .ref")"
  [[ -z "$existing_tag" ]] || fail "$tag already exists. Choose a new version; releases are never overwritten."
fi

# Isolated output prevents stale products and never overwrites previous builds.
mkdir -p build/releases
release_dir="$(mktemp -d "$app_root/build/releases/$tag.XXXXXX")"
derived_data="$release_dir/DerivedData"
staging="$release_dir/installer"
app="$derived_data/Build/Products/Release/DipperPDF.app"
dmg="$release_dir/DipperPDF.dmg"
printf 'Building DipperPDF %s (%s) into %s\n' "$version" "$build_number" "$release_dir"

signing_settings=("CODE_SIGN_IDENTITY=$identity")
if [[ "$identity" != '-' ]]; then
  signing_settings+=("OTHER_CODE_SIGN_FLAGS=--timestamp")
fi
xcodebuild -project DipperPDF.xcodeproj -scheme DipperPDF \
  -configuration Release -destination 'generic/platform=macOS' \
  -derivedDataPath "$derived_data" \
  'ARCHS=arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  "MARKETING_VERSION=$version" "CURRENT_PROJECT_VERSION=$build_number" \
  "${signing_settings[@]}" build

plist="$app/Contents/Info.plist"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")" == "$version" ]] || fail 'Built app version does not match the release.'
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")" == "$build_number" ]] || fail 'Built app build number does not match the release.'
for architecture in arm64 x86_64; do
  xcrun lipo "$app/Contents/MacOS/DipperPDF" -verify_arch "$architecture"
done
codesign --verify --deep --strict "$app"

if [[ "$identity" != '-' ]]; then
  # Staple the app before packaging so its ticket survives copying out of the DMG.
  ditto -c -k --keepParent "$app" "$release_dir/DipperPDF-notarization.zip"
  xcrun notarytool submit "$release_dir/DipperPDF-notarization.zip" \
    --keychain-profile "$notary_profile" --wait
  xcrun stapler staple "$app"
  xcrun stapler validate "$app"
fi

mkdir -p "$staging"
ditto "$app" "$staging/DipperPDF.app"
ln -s /Applications "$staging/Applications"
hdiutil create -volname "DipperPDF $version" -srcfolder "$staging" \
  -format UDZO "$dmg"
if [[ "$identity" != '-' ]]; then
  codesign --sign "$identity" --timestamp "$dmg"
  xcrun notarytool submit "$dmg" --keychain-profile "$notary_profile" --wait
  xcrun stapler staple "$dmg"
  xcrun stapler validate "$dmg"
fi
hdiutil verify "$dmg"
(cd "$release_dir" && shasum -a 256 DipperPDF.dmg > DipperPDF.dmg.sha256)

notes="$release_dir/release-notes.md"
cat > "$notes" <<EOF
DipperPDF $version (build $build_number)

- Requires macOS 14 or later. Supports Apple silicon and Intel Macs.
- Download DipperPDF.dmg, open it, and drag DipperPDF into Applications.
- SHA-256 checksum: DipperPDF.dmg.sha256.
- Source commit: $commit.
EOF
if [[ "$identity" == '-' ]]; then
  cat >> "$notes" <<'EOF'

This build is ad hoc signed and has not been notarized by Apple. macOS may block
its first launch. After attempting to open it, use System Settings > Privacy &
Security > Open Anyway if you trust this download.
EOF
else
  printf '\nSigned with Developer ID and notarized by Apple.\n' >> "$notes"
fi

printf '\nDMG: %s\nChecksum: %s\n' "$dmg" "$dmg.sha256"
if [[ "$build_only" == true ]]; then
  exit 0
fi

# Upload completely before making the release available to the website.
gh release create "$tag" "$dmg" "$dmg.sha256" --repo "$repo" \
  --target "$commit" --title "DipperPDF $version" --notes-file "$notes" --draft
gh release edit "$tag" --repo "$repo" --draft=false --latest
printf '\nDownload: https://github.com/%s/releases/latest/download/DipperPDF.dmg\n' "$repo"
