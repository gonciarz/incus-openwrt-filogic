#!/bin/sh
set -e

DBUS_VERSION="${DBUS_VERSION:?DBUS_VERSION not set}"

cd /tmp
wget -q "https://dbus.freedesktop.org/releases/dbus/dbus-${DBUS_VERSION}.tar.xz"
tar xf "dbus-${DBUS_VERSION}.tar.xz"
cd "dbus-${DBUS_VERSION}"
CFLAGS="$ARCH_CFLAGS" ./configure \
    --prefix=/usr \
    --disable-shared \
    --enable-static \
    --disable-systemd \
    --disable-selinux \
    --without-x \
    --disable-tests \
    --disable-doxygen-docs \
    --disable-xml-docs
make -j"$(nproc)"
make install
cd /tmp && rm -rf "dbus-${DBUS_VERSION}" "dbus-${DBUS_VERSION}.tar.xz"
