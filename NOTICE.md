# Licensing

This repository has two license scopes:

- **[`LICENSE`](LICENSE) (Apache-2.0)** — applies to the repository as a
  whole and to the main artifact it produces: a compiled build of
  [Incus](https://github.com/lxc/incus), which is itself Apache-2.0. This
  matches the license of the upstream project being distributed.

- **[`LICENSE-MIT`](LICENSE-MIT) (MIT)** — applies specifically to the
  build tooling authored in this repo: `Dockerfile`, `build.sh`,
  `.github/workflows/build.yml`, `APKBUILD`, and `incus.initd`. This code
  doesn't contain or derive from Incus source, so it's licensed
  independently and more permissively.

If in doubt about which license covers a given file, MIT covers the build
tooling listed above; Apache-2.0 covers everything else, including the
compiled release binaries.

## Third-party components in the compiled binaries

`incusd`/`incus` are statically linked against several libraries pulled in
via Alpine packages or built from source in the Docker image. Their
licenses apply to the resulting binary independently of this repo's own
license:

| Component | License | Notes |
|---|---|---|
| Incus (`incusd`, `incus`) | Apache-2.0 | Source fetched at build time from upstream tag |
| liblxc | LGPL-2.1+ | Statically linked |
| libacl / libattr | LGPL-2.1+ | Statically linked |
| libseccomp | LGPL-2.1 | Statically linked |
| dbus (libdbus-1) | AFL-2.1 (used; also dual-licensed under GPL-2.0-or-later) | Built from source, statically linked |
| libcap | BSD-3-Clause / GPL-2.0 (dual) | Statically linked |
| lz4 | BSD-2-Clause | Statically linked |
| sqlite3 | Public domain | Statically linked |
| libuv | MIT | Statically linked |
| expat | MIT | Statically linked |
| cowsql / raft | Apache-2.0 | Built from source via `make deps` |
| musl libc | MIT | Alpine base toolchain |

**dbus licensing choice:** dbus is dual-licensed (AFL-2.1 / GPL-2.0-or-later).
This build is used under the **AFL-2.1** option. Apache-2.0 and GPLv2 are
treated as license-incompatible by the FSF, so combining a GPL-2.0-only
component into an Apache-2.0-licensed aggregate would be problematic;
AFL-2.1 has no such conflict with Apache-2.0. Keep this choice in mind if
`dbus` is ever swapped for a component that is GPL-only.

**LGPL note:** static-linking LGPL-licensed libraries (liblxc, libacl,
libattr, libseccomp) normally requires giving recipients the means to
relink the binary against a modified version of those libraries. This
repo satisfies that by fully reproducing the build from source via
`Dockerfile` / `build.sh` / the GitHub Actions workflow — keep that build
path working and reproducible rather than switching to a prebuilt or
vendored binary blob.

**Verify before wider redistribution:** the table above reflects licenses
as commonly published by each upstream project at the time of writing.
Double-check the exact license/version actually pulled by `apk add` and
`make deps` against each project's own `LICENSE` file before any
production or public release, since license terms can change between
versions.
