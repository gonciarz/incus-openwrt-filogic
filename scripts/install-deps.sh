#!/bin/sh
set -e

apk add --no-cache \
    acl-dev autoconf automake gettext-tiny-dev go libcap-dev libtool libuv-dev \
    linux-headers lz4-dev tcl-dev sqlite-dev lxc-dev libseccomp-dev make xz musl-dev \
    expat-dev expat-static gperf util-linux-dev util-linux-static \
    acl-static libcap-static lz4-static sqlite-static lxc-static libuv-static \
    libseccomp-static zlib-static \
    acl attr ca-certificates dbus dnsmasq lxc libintl iproute2 nftables netcat-openbsd \
    rsync squashfs-tools shadow-uidmap tar git file
