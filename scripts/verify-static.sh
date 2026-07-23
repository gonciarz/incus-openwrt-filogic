#!/bin/sh
set -e

OUT_DIR="${OUT_DIR:-/output}"

for bin in incusd incus setfattr unsquashfs xz; do
    echo -n "$bin: "
    file "$OUT_DIR/$bin" | grep -Eo 'statically linked|static-pie linked' || echo "WARN: not static"
done
