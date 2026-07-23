#!/bin/sh
set -e

INCUS_VERSION=${1:-7.0.0}
PLATFORM=${2:-linux/arm64}
OUTPUT_DIR="$(dirname "$0")/output"

mkdir -p "$OUTPUT_DIR"

docker build \
    --build-arg INCUS_VERSION="$INCUS_VERSION" \
    -t incus-builder \
    "$(dirname "$0")"

docker run --rm -v "$OUTPUT_DIR:/mnt" incus-builder sh -c "cp -a /output/. /mnt/"

echo "Binaries in $OUTPUT_DIR:"
ls -lh "$OUTPUT_DIR"
