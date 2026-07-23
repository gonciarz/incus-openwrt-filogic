#!/bin/sh
set -e

# Run from a directory to build in (e.g. /build). Fetches Incus, builds its
# raft/cowsql deps, then builds incusd/incus statically.
INCUS_VERSION="${INCUS_VERSION:?INCUS_VERSION not set}"
OUT_DIR="${OUT_DIR:-/output}"
mkdir -p "$OUT_DIR"

wget -q "https://github.com/lxc/incus/archive/refs/tags/v${INCUS_VERSION}.tar.gz"
tar zxf "v${INCUS_VERSION}.tar.gz"
mv "incus-${INCUS_VERSION}" incus
cd incus

export CFLAGS="$ARCH_CFLAGS"
make deps

export GOARCH=arm64
# v8.0: Go has no -mtune equivalent, only an ISA-level gate like -march, and
# Cortex-A73 (BPI R4's MT7988A) doesn't implement ARMv8.1+ LSE atomics - so
# v8.1/v8.2 would risk illegal-instruction crashes on the actual target.
export GOARM64=v8.0
export CGO_ENABLED=1
export CGO_CFLAGS="-I/root/go/deps/raft/include/ -I/root/go/deps/cowsql/include/ $ARCH_CFLAGS"
export CGO_CPPFLAGS="-I/usr/include"
# --allow-multiple-definition: liblxc (static) and Incus both define
# lxc_abstract_unix_send_fds/lxc_abstract_unix_recv_fds - Incus carries its
# own copy in internal/netutils/unixfd.c. Linking dynamically hides this;
# linking statically pulls both .o files into the binary and the linker
# refuses. This flag makes it take the first definition (Incus's, linked
# first) and ignore the duplicate - safe since both implement the same
# function, not a real conflict.
export CGO_LDFLAGS="-L/root/go/deps/raft/.libs -L/root/go/deps/cowsql/.libs/ -L/usr/lib -static -Wl,--allow-multiple-definition -lcowsql -lraft -luv -llz4 -lintl -lseccomp -ldbus-1 -lexpat -lcap -ludev"
export LD_LIBRARY_PATH="/root/go/deps/raft/.libs/:/root/go/deps/cowsql/.libs/"
export CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)"

go build -buildvcs=false -trimpath -tags libsqlite3 -ldflags="-s -w -extldflags=-static" -o "$OUT_DIR/incusd" ./cmd/incusd
go build -buildvcs=false -trimpath -tags libsqlite3 -ldflags="-s -w -extldflags=-static" -o "$OUT_DIR/incus" ./cmd/incus
