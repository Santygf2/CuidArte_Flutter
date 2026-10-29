#!/usr/bin/env bash
# Compila la app Flutter Web para desplegarla en Vercel.
# La URL del backend se puede sobreescribir con la variable de entorno API_URL
# definida en el proyecto de Vercel.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.8}"
FLUTTER_SDK_DIR="${FLUTTER_SDK_DIR:-/tmp/flutter-sdk}"
API_URL="${API_URL:-https://cuid-arte-gamma.vercel.app/api/v1}"

if [ ! -x "$FLUTTER_SDK_DIR/flutter/bin/flutter" ]; then
  echo "==> Descargando Flutter ${FLUTTER_VERSION}"
  mkdir -p "$FLUTTER_SDK_DIR"

  ARCHIVE="/tmp/flutter-${FLUTTER_VERSION}.tar.xz"
  URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

  if curl -fsSL "$URL" -o "$ARCHIVE"; then
    tar -xJf "$ARCHIVE" -C "$FLUTTER_SDK_DIR"
    rm -f "$ARCHIVE"
  else
    echo "==> Descarga directa fallo, usando git"
    rm -rf "$FLUTTER_SDK_DIR/flutter"
    git clone --depth 1 --branch "$FLUTTER_VERSION" \
      https://github.com/flutter/flutter.git "$FLUTTER_SDK_DIR/flutter"
  fi
fi

export PATH="$FLUTTER_SDK_DIR/flutter/bin:$PATH"
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"

git config --global --add safe.directory "$FLUTTER_SDK_DIR/flutter" || true
flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version

echo "==> Compilando con API_URL=${API_URL}"
flutter pub get
flutter build web --release --dart-define=API_URL="$API_URL"

echo "==> Listo: build/web"
