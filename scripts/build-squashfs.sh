#!/bin/sh
set -e

SQUASHFS_VERSION="${SQUASHFS_VERSION:?SQUASHFS_VERSION not set}"
OUT_DIR="${OUT_DIR:-/output}"
mkdir -p "$OUT_DIR"

cd /tmp
wget -q "https://github.com/plougher/squashfs-tools/archive/refs/tags/${SQUASHFS_VERSION}.tar.gz"
tar xf "${SQUASHFS_VERSION}.tar.gz"
cd "squashfs-tools-${SQUASHFS_VERSION}/squashfs-tools"
# Plain `make` (not just the unsquashfs target) also builds mksquashfs
# and the sqfscat/sqfstar symlinks alongside it, all needed for the full
# squashfs-tools-static apk subpackage below.
make -j"$(nproc)" EXTRA_CFLAGS="-static $ARCH_CFLAGS" LDFLAGS="-static"
cp unsquashfs "$OUT_DIR/unsquashfs"

# Full mksquashfs/unsquashfs/sqfscat/sqfstar set, staged for the
# squashfs-tools-static apk subpackage (which replaces the real
# squashfs-tools package - so it should ship everything that package
# does, not just the one binary incus needs). Prebuilt manpages require
# help2man which isn't installed; that's a non-fatal warning, not an error.
make install INSTALL_DIR="$OUT_DIR/stage/squashfs-tools" INSTALL_MANPAGES_DIR="$OUT_DIR/stage/squashfs-tools-man"

cd /tmp && rm -rf "squashfs-tools-${SQUASHFS_VERSION}" "${SQUASHFS_VERSION}.tar.gz"
