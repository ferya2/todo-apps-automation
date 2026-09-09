#!/usr/bin/env bash
# Called by semantic-release (@semantic-release/exec) during the "prepare" step.
# Arg $1 = the next semantic version (e.g. 1.2.0), computed from commit history.
#
# It bumps the version in pubspec.yaml and builds the release APK. semantic-release
# then commits the pubspec bump and attaches the APK to the GitHub Release.
set -euo pipefail

VERSION="$1"
# Flutter needs "X.Y.Z+build". Use the CI run number as an ever-increasing build.
BUILD="${GITHUB_RUN_NUMBER:-1}"

echo "==> Setting pubspec.yaml version to ${VERSION}+${BUILD}"
sed -i -E "s/^version:.*/version: ${VERSION}+${BUILD}/" pubspec.yaml

echo "==> Building release APK"
flutter pub get
flutter build apk --release

echo "==> Collecting APK into dist/"
mkdir -p dist
cp build/app/outputs/flutter-apk/app-release.apk "dist/todo-app-v${VERSION}.apk"

echo "==> Done: dist/todo-app-v${VERSION}.apk"
