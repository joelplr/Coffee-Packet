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
export CI=true                            # suppresses interactive prompts
export FLUTTER_SUPPRESS_ANALYTICS=1      # no analytics ping
export FLUTTER_ALLOW_ENV_UPDATE=1        # allow running as root (CI env)
export DART_FLAGS=""

# Allow git to trust any directory (needed when running as root)
git config --global --add safe.directory "*" 2>/dev/null || true

# ── Download Flutter SDK (binary archive — no git, no root issues) ─────────────
ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [ ! -f "$FLUTTER_BIN/flutter" ]; then
  echo "[1/5] Downloading Flutter $FLUTTER_VERSION binary archive..."
  mkdir -p /opt
  curl -fsSL "$ARCHIVE_URL" | tar xJ -C /opt
  echo "      ✓ Flutter SDK extracted to $FLUTTER_HOME"
else
  echo "[1/5] Flutter SDK already cached at $FLUTTER_HOME"
fi

# ── Verify ────────────────────────────────────────────────────────────────────
echo "[2/5] Flutter version:"
flutter --version --suppress-analytics 2>/dev/null || flutter --version

# ── Disable analytics & pre-cache web artifacts ───────────────────────────────
echo "[3/5] Configuring Flutter..."
flutter config --no-analytics 2>/dev/null || true
flutter precache --web \
  --no-android --no-ios \
  --no-linux --no-macos --no-windows \
  --suppress-analytics 2>/dev/null || \
flutter precache --web 2>/dev/null || true

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
