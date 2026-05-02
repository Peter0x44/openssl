# CMake Bootstrap Build

This repository now includes a no-Perl CMake bootstrap intended first for
mingw-w64 GCC on Windows, with the layout kept close enough to extend toward
Linux later.

## Current scope

- Uses CMake + Ninja + GCC.
- Replaces the Perl-generated headers, provider `.inc` files, DER/OID tables,
  `buildinf.h`, and `progs.c` / `progs.h` with native CMake scripts.
- Supports configurable cache options around a constrained baseline:
  - `OPENSSL_CMAKE_BUILD_APPS=ON|OFF`
  - `OPENSSL_CMAKE_BUILD_SHARED=ON|OFF`
    - `ON` builds the current shared-library layout
    - `OFF` switches the bootstrap to static `libcrypto` / `libssl`
  - `OPENSSL_CMAKE_ENABLE_THREADS=ON|OFF`
  - `OPENSSL_CMAKE_ENABLE_ZLIB=ON|OFF`
  - `OPENSSL_CMAKE_ENABLE_ZLIB_DYNAMIC=ON|OFF`
  - `OPENSSL_CMAKE_DEPS=AUTO|DOWNLOAD|LOCAL`
  - `OPENSSL_CMAKE_CONFIGURE_OPTIONS=<semicolon-separated Configure args>`
  - `OPENSSL_CMAKE_ENABLE_JITTER=ON|OFF` with
    `OPENSSL_CMAKE_JITTER_INCLUDE_DIR` and
    `OPENSSL_CMAKE_JITTER_LIBRARY`
  - `OPENSSL_CMAKE_ENABLE_LEGACY=ON|OFF`
  - `OPENSSL_CMAKE_ENABLE_MODULES=ON|OFF`
    - `ON` currently follows the upstream non-FIPS layout: the legacy
      provider is emitted as a loadable module, while the default, base,
      and null providers remain built in
    - currently requires `OPENSSL_CMAKE_BUILD_SHARED=ON`
  - `OPENSSL_CMAKE_ZLIB_INCLUDE_DIR`
  - `OPENSSL_CMAKE_ZLIB_LIBRARY`
  - `OPENSSL_CMAKE_ENABLE_KTLS=ON|OFF`
  - `OPENSSL_CMAKE_ENABLE_SCTP=ON|OFF`
  - `OPENSSL_CMAKE_INSTALL_OPENSSLDIR`
  - `OPENSSL_CMAKE_INSTALL_MODULESDIR`
- Still intentionally constrains unsupported upstream build paths:
  - `OPENSSL_CMAKE_ENABLE_ASM=OFF`
  - `OPENSSL_CMAKE_ENABLE_FIPS=OFF`

- Current provider layout:
  - default, base, and null remain built in
  - legacy remains built in when modules are disabled, and becomes a loadable
    provider module when modules are enabled

## Windows build

Use the preset:

```text
cmake --preset mingw64-release
cmake --build --preset mingw64-release
```

For a static-library build:

```text
cmake --preset mingw64-static-release
cmake --build --preset mingw64-static-release
```

Or configure manually:

```text
cmake -S . -B build/mingw64-release -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc
cmake --build build/mingw64-release
```

The bootstrap also accepts a Configure-style compatibility entry point through
`OPENSSL_CMAKE_CONFIGURE_OPTIONS`. Example:

```text
cmake -S . -B build/mingw64-release -G Ninja -DCMAKE_C_COMPILER=gcc -DOPENSSL_CMAKE_CONFIGURE_OPTIONS="no-shared;no-apps;no-md5;zlib-dynamic;--with-rand-seed=os"
```

This compatibility layer currently maps the working subset into native CMake
options, supports generic `no-...` disables for upstream protocol and
algorithm options, supports a broad guarded-feature subset such as
`no-err`, `no-ui-console`, `no-autoload-config`, `no-trace`,
`no-ssl-trace`, `no-sock`, `no-dgram`, `no-rdrand`, and `no-legacy`, and
fails fast for recognized Configure options that the bootstrap still does not
implement structurally.

It also normalizes a few deprecated upstream spellings so existing command
lines keep working more often, for example `no-ui` -> `no-ui-console` and
`no-ripemd` -> `no-rmd160`.

The `mingw64-release` and `mingw64-static-release` presets have been validated
with mingw-w64 GCC on Windows through full builds of `libcrypto`, `libssl`,
and `openssl.exe`, followed by:

```text
build\mingw64-release\openssl.exe version
```

Dependency resolution follows the same `AUTO|DOWNLOAD|LOCAL` pattern used in
`dcmake`:

- `AUTO` prefers bundled `deps/` sources when present, otherwise uses
  `FetchContent`, with a disconnected/system fallback where possible.
- `DOWNLOAD` always resolves optional third-party dependencies through
  `FetchContent` unless explicit include/library paths are provided.
- `LOCAL` requires already-installed dependencies or explicit include/library
  paths.

The current optional dependency hooks cover zlib and jitterentropy.

On Windows, leave `OPENSSL_CMAKE_ENABLE_SCTP=OFF`. KTLS is only supported in
this bootstrap on Linux and FreeBSD.

## Linux direction

There is also a `linux-release` preset as a starting point. The bootstrap is
structured so the platform-specific parts live in the CMake target bootstrap
and generator inputs rather than in shell-specific logic.

## Known gaps

- Perlasm and assembly generation are intentionally disabled.
- The FIPS provider path is intentionally disabled.
- This bootstrap currently collects C sources by curated glob patterns rather
  than by a full `build.info` parser.
- Several packaging/exporter details from the upstream Perl build are not
  implemented yet.