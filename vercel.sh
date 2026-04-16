#!/bin/bash

set -eo pipefail

echo "========================================="
echo "  Coffee Machine App — Vercel Build"
echo "========================================="

# ── Config ────────────────────────────────────────────────────────────────────
FLUTTER_VERSION="3.32.0"
FLUTTER_HOME="/opt/flutter"
FLUTTER_BIN="$FLUTTER_HOME/bin"

# ── Environment ───────────────────────────────────────────────────────────────
export PATH="$FLUTTER_BIN:$PATH"
export HOME="${HOME:-/root}"
export PUB_CACHE="$HOME/.pub-cache"
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=1
export FLUTTER_ALLOW_ENV_UPDATE=1

# Allow git in any directory (needed as root)
git config --global --add safe.directory "*" 2>/dev/null || true

# ── Download Flutter SDK (binary archive) ─────────────────────────────────────
ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${ARCHIVE}"

if [ ! -f "$FLUTTER_BIN/flutter" ]; then
  echo "[1/5] Downloading Flutter $FLUTTER_VERSION binary archive..."
  mkdir -p /opt
  curl -fsSL "$ARCHIVE_URL" | tar xJ -C /opt
  echo "      ✓ Extracted to $FLUTTER_HOME"
else
  echo "[1/5] Flutter SDK already cached."
fi

# ── Patch out the root warning in the flutter script ─────────────────────────
# (Vercel runs as root; Flutter just warns but we suppress it for clean logs)
FLUTTER_SCRIPT="$FLUTTER_BIN/flutter"
if [ -f "$FLUTTER_SCRIPT" ]; then
  sed -i '/Woah! You appear to be trying to run flutter as root/d' "$FLUTTER_SCRIPT" 2>/dev/null || true
  sed -i '/strongly recommend running the flutter tool without superuser/d' "$FLUTTER_SCRIPT" 2>/dev/null || true
  sed -i '/without superuser privileges/d' "$FLUTTER_SCRIPT" 2>/dev/null || true
fi

# ── Verify ────────────────────────────────────────────────────────────────────
echo "[2/5] Flutter version:"
flutter --version 2>&1 | grep -v "VersionCheckError\|bad object\|Returning 1970" || true

# ── Disable analytics ─────────────────────────────────────────────────────────
echo "[3/5] Configuring Flutter..."
flutter config --no-analytics 2>/dev/null || true
flutter precache --web \
  --no-android --no-ios \
  --no-linux --no-macos --no-windows 2>/dev/null || true

# ── Fetch pub dependencies ────────────────────────────────────────────────────
echo "[4/5] Fetching pub dependencies..."
flutter pub get

# ── Build for web ─────────────────────────────────────────────────────────────
echo "[5/5] Building Flutter Web (release)..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --no-pub

echo ""
echo "✅ Build complete!"
echo "   Output directory: build/web"
ls -lh build/web/
