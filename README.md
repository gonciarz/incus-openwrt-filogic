# incus-openwrt-filogic

[Incus](https://github.com/lxc/incus) is a container and virtual machine
manager. This repo builds it statically - `incusd` (server) and `incus`
(client) - on Alpine.

Optimized for MediaTek Filogic 880 (MT7988A, quad-core Cortex-A73) devices. 

## Install on OpenWrt

`.apk` packages are published to a signed [apk repository](https://gonciarz.github.io/incus-openwrt-filogic/)
via GitHub Pages; raw binaries are published to [GitHub Releases](../../releases).
Add the key and repo once, then install like any other OpenWrt package:

```sh
wget -O /etc/apk/keys/incus-openwrt-filogic.pem \
    https://gonciarz.github.io/incus-openwrt-filogic/incus-openwrt-filogic.pem
echo 'https://gonciarz.github.io/incus-openwrt-filogic/aarch64_cortex-a53/packages.adb' \
    > /etc/apk/repositories.d/incus.list

apk update
apk add incus-static
```

## How to build locally (on arm64)

```sh
./build.sh 7.0.1
```
