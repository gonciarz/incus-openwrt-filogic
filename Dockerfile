FROM alpine:3.24

ARG INCUS_VERSION=7.0.1
ARG EUDEV_VERSION=3.2.14
ARG DBUS_VERSION=1.14.10
ARG ATTR_VERSION=2.5.2
ARG SQUASHFS_VERSION=4.6.1
ARG XZ_VERSION=5.6.3

# -mcpu=cortex-a73 tunes scheduling for BPI R4's MT7988A (Cortex-A73)
# without emitting ARMv8.2-A-only instructions Cortex-A73 doesn't actually
# implement (verified: it lacks LSE atomics/QRDMX that -march=armv8.2-a
# would enable - that was a real correctness bug, not just an incompatibility
# with other Filogic boards). Cortex-A73's only extra feature over plain
# armv8-a is CRC32, which Cortex-A53 (also used across the Filogic family)
# has too, so this is safe across the whole family, not just this one board.
ARG ARCH_CFLAGS="-mcpu=cortex-a73 -O2"

ENV INCUS_VERSION=${INCUS_VERSION} \
    EUDEV_VERSION=${EUDEV_VERSION} \
    DBUS_VERSION=${DBUS_VERSION} \
    ATTR_VERSION=${ATTR_VERSION} \
    SQUASHFS_VERSION=${SQUASHFS_VERSION} \
    XZ_VERSION=${XZ_VERSION} \
    ARCH_CFLAGS=${ARCH_CFLAGS} \
    OUT_DIR=/output

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

RUN /scripts/install-deps.sh
RUN /scripts/build-eudev.sh
RUN /scripts/build-dbus.sh

RUN mkdir -p /usr/local/include

WORKDIR /build
RUN /scripts/build-incus.sh

RUN /scripts/build-attr.sh
RUN /scripts/build-squashfs.sh
RUN /scripts/build-xz.sh

RUN /scripts/verify-static.sh
