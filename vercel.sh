#!/bin/bash

set -e

echo "========================================="
echo "  Coffee Machine App — Vercel Build"
echo "========================================="

# ── Flutter version ───────────────────────────────────────────────────────────
FLUTTER_VERSION="3.32.0"
FLUTTER_CHANNEL="stable"

# ── Paths ─────────────────────────────────────────────────────────────────────
FLUTTER_HOME="$HOME/.flutter"
FLUTTER_BIN="$FLUTTER_HOME/bin"
export PATH="$FLUTTER_BIN:$PATH"

# ── Install Flutter SDK if not already cached ─────────────────────────────────
if [ ! -d "$FLUTTER_HOME" ]; then
  echo "[1/4] Downloading Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)..."
  git clone \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git \
    "$FLUTTER_HOME"
else
  echo "[1/4] Flutter SDK already present — skipping download."
fi

# ── Verify installation ───────────────────────────────────────────────────────
echo "[2/4] Flutter version:"
flutter --version

# Disable analytics / update checks so the build doesn't hang
flutter config --no-analytics
flutter precache --web

# ── Fetch dependencies ────────────────────────────────────────────────────────
echo "[3/4] Fetching pub dependencies..."
flutter pub get

# ── Build for web ─────────────────────────────────────────────────────────────
echo "[4/4] Building Flutter Web (release)..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true

echo ""
echo "✅ Build complete! Output is in: build/web"
