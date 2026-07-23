#!/bin/sh
set -e

INCUS_VERSION="${INCUS_VERSION:?INCUS_VERSION not set}"
INCUS_SIGN_KEY="${INCUS_SIGN_KEY:?INCUS_SIGN_KEY not set}"
OUT_DIR="${OUT_DIR:-/output}"
PKG_DIR="${PKG_DIR:-$OUT_DIR/pkg}"
INCUS_INITD="${INCUS_INITD:-incus.initd}"

VER="${INCUS_VERSION}-r0"

mkdir -p "$PKG_DIR"

chmod +x "$OUT_DIR/stage/attr/usr/bin/setfattr" "$OUT_DIR/stage/xz/usr/bin/xz" "$OUT_DIR/stage/squashfs-tools/unsquashfs"
ATTR_VER="$("$OUT_DIR/stage/attr/usr/bin/setfattr" --version | awk '{print $2}')-r0"
XZ_VER="$("$OUT_DIR/stage/xz/usr/bin/xz" --version | head -1 | awk '{print $NF}')-r0"
SQUASHFS_VER="$("$OUT_DIR/stage/squashfs-tools/unsquashfs" -version | head -1 | awk '{print $3}')-r0"

root="$PKG_DIR/root-incus-static"
mkdir -p "$root/usr/bin" "$root/usr/sbin" "$root/etc/init.d"
cp "$OUT_DIR/incus" "$root/usr/bin/incus"
cp "$OUT_DIR/incusd" "$root/usr/sbin/incusd"
cp "$INCUS_INITD" "$root/etc/init.d/incus"
chmod 755 "$root/usr/bin/incus" "$root/usr/sbin/incusd" "$root/etc/init.d/incus"

root="$PKG_DIR/root-attr-static"
mkdir -p "$root/usr/bin"
cp "$OUT_DIR/stage/attr/usr/bin/"* "$root/usr/bin/"

root="$PKG_DIR/root-xz-static"
mkdir -p "$root/usr/libexec" "$root/usr/bin"
cp "$OUT_DIR/stage/xz/usr/bin/xz" "$root/usr/libexec/xz-lzmautils"
for name in xz lzcat lzma unlzma unxz xzcat; do
    ln -s /usr/libexec/xz-lzmautils "$root/usr/bin/$name"
done

root="$PKG_DIR/root-squashfs-mksquashfs"
mkdir -p "$root/usr/sbin"
cp "$OUT_DIR/stage/squashfs-tools/mksquashfs" "$root/usr/sbin/mksquashfs"
ln -s mksquashfs "$root/usr/sbin/sqfstar"

root="$PKG_DIR/root-squashfs-unsquashfs"
mkdir -p "$root/usr/sbin"
cp "$OUT_DIR/stage/squashfs-tools/unsquashfs" "$root/usr/sbin/unsquashfs"
ln -s unsquashfs "$root/usr/sbin/sqfscat"

mkdir -p /root/.keys
echo "$INCUS_SIGN_KEY" > /root/.keys/incus-openwrt-filogic.pem

cd "$PKG_DIR"

apk mkpkg -F root-incus-static \
    --info name:incus-static --info version:"$VER" --info arch:aarch64_cortex-a53 \
    --info "description:Incus container and VM manager (static build, optimized for Cortex-A73)" \
    --info license:Apache-2.0 --info url:https://linuxcontainers.org/incus/ \
    --info "depends:attr xz squashfs-tools-unsquashfs" \
    -o "incus-static-$VER.apk"

apk mkpkg -F root-attr-static \
    --info name:attr-static --info version:"$ATTR_VER" --info arch:aarch64_cortex-a53 \
    --info "description:Static attr/getfattr/setfattr for Incus, alternative to attr" \
    --info license:LGPL-2.1-or-later \
    --info replaces:attr \
    --info "provides:attr=$ATTR_VER cmd:attr=$ATTR_VER cmd:getfattr=$ATTR_VER cmd:setfattr=$ATTR_VER" \
    -o "attr-static-$ATTR_VER.apk"

apk mkpkg -F root-xz-static \
    --info name:xz-static --info version:"$XZ_VER" --info arch:aarch64_cortex-a53 \
    --info "description:Static xz for Incus, alternative to xz" \
    --info license:0BSD \
    --info "replaces:xz xz-utils" \
    --info "provides:xz=$XZ_VER xz-utils=$XZ_VER cmd:xz=$XZ_VER cmd:lzcat=$XZ_VER cmd:lzma=$XZ_VER cmd:unlzma=$XZ_VER cmd:unxz=$XZ_VER cmd:xzcat=$XZ_VER" \
    -o "xz-static-$XZ_VER.apk"

apk mkpkg -F root-squashfs-mksquashfs \
    --info name:squashfs-tools-mksquashfs-static --info version:"$SQUASHFS_VER" --info arch:aarch64_cortex-a53 \
    --info "description:Static mksquashfs/sqfstar for Incus, alternative to squashfs-tools-mksquashfs" \
    --info license:GPL-2.0-or-later \
    --info replaces:squashfs-tools-mksquashfs \
    --info "provides:squashfs-tools-mksquashfs=$SQUASHFS_VER cmd:mksquashfs=$SQUASHFS_VER cmd:sqfstar=$SQUASHFS_VER" \
    -o "squashfs-tools-mksquashfs-static-$SQUASHFS_VER.apk"

apk mkpkg -F root-squashfs-unsquashfs \
    --info name:squashfs-tools-unsquashfs-static --info version:"$SQUASHFS_VER" --info arch:aarch64_cortex-a53 \
    --info "description:Static unsquashfs/sqfscat for Incus, alternative to squashfs-tools-unsquashfs" \
    --info license:GPL-2.0-or-later \
    --info replaces:squashfs-tools-unsquashfs \
    --info "provides:squashfs-tools-unsquashfs=$SQUASHFS_VER cmd:unsquashfs=$SQUASHFS_VER cmd:sqfscat=$SQUASHFS_VER" \
    -o "squashfs-tools-unsquashfs-static-$SQUASHFS_VER.apk"

apk mkndx --allow-untrusted --sign-key /root/.keys/incus-openwrt-filogic.pem \
    -o packages.adb *.apk

openssl ec -in /root/.keys/incus-openwrt-filogic.pem -pubout \
    -out incus-openwrt-filogic.pem 2>/dev/null
