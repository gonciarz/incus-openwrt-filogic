#!/bin/sh
set -e

ATTR_VERSION="${ATTR_VERSION:?ATTR_VERSION not set}"
OUT_DIR="${OUT_DIR:-/output}"
mkdir -p "$OUT_DIR"

cd /tmp
git clone --depth 1 --branch "v${ATTR_VERSION}" https://git.savannah.nongnu.org/git/attr.git
cd attr
./autogen.sh
# --disable-nls: attr's po/ dir references en@boldquot.po/en@quot.po,
# which only full GNU gettext's autopoint machinery knows how to
# generate - gettext-tiny (musl-friendly, used for the real incusd/incus
# libintl.a) doesn't ship it. setfattr's own translated messages aren't
# needed here anyway.
CFLAGS="$ARCH_CFLAGS" ./configure \
    --prefix=/usr \
    --disable-shared \
    --enable-static \
    --disable-nls
sed -i '1s/^/#include <libgen.h>\n/' tools/attr.c
make -j"$(nproc)" LDFLAGS="-all-static"
cp "$(find . -name setfattr -type f | head -1)" "$OUT_DIR/setfattr"

# Full attr/getfattr/setfattr set, staged for the attr-static apk
# subpackage (which replaces the real attr package - so it should ship
# everything that package does, not just the one binary incus needs).
make install DESTDIR="$OUT_DIR/stage/attr"

cd /tmp && rm -rf attr
