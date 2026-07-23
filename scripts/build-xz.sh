#!/bin/sh
set -e

XZ_VERSION="${XZ_VERSION:?XZ_VERSION not set}"
OUT_DIR="${OUT_DIR:-/output}"
mkdir -p "$OUT_DIR"

cd /tmp
wget -q "https://github.com/tukaani-project/xz/releases/download/v${XZ_VERSION}/xz-${XZ_VERSION}.tar.gz"
tar xf "xz-${XZ_VERSION}.tar.gz"
cd "xz-${XZ_VERSION}"
CFLAGS="$ARCH_CFLAGS" ./configure --prefix=/usr --disable-shared --enable-static
make -j"$(nproc)" LDFLAGS="-all-static"
cp "$(find . -name xz -type f | head -1)" "$OUT_DIR/xz"

# Full xz/unxz/xzcat/lzma/... set, staged for the xz-static apk
# subpackage (which replaces the real xz package - so it should ship
# everything that package does, not just the one binary incus needs).
make install DESTDIR="$OUT_DIR/stage/xz"

cd /tmp && rm -rf "xz-${XZ_VERSION}" "xz-${XZ_VERSION}.tar.gz"
