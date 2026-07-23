#!/bin/sh
set -e

# incusd links against libudev for device management, but Alpine's
# eudev-dev only ships the shared library - no eudev-static package
# exists - so a static libudev.a isn't otherwise available.
EUDEV_VERSION="${EUDEV_VERSION:?EUDEV_VERSION not set}"

cd /tmp
wget -q "https://github.com/eudev-project/eudev/releases/download/v${EUDEV_VERSION}/eudev-${EUDEV_VERSION}.tar.gz"
tar xf "eudev-${EUDEV_VERSION}.tar.gz"
cd "eudev-${EUDEV_VERSION}"
CFLAGS="$ARCH_CFLAGS" ./configure \
    --prefix=/usr \
    --disable-shared \
    --enable-static \
    --disable-manpages \
    --disable-hwdb \
    --disable-introspection \
    --disable-gudev \
    --disable-programs
make -j"$(nproc)"
make install
cd /tmp && rm -rf "eudev-${EUDEV_VERSION}" "eudev-${EUDEV_VERSION}.tar.gz"
