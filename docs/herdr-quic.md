# herdr resumable-QUIC remote (parked)

Status as of 2026-07-23: fetched and evaluated, **not built** — blocked on a
Zig/macOS SDK incompatibility (details below). Nothing needs cleaning up; the
worktree is clean and parked.

## What this is

An experimental replacement for herdr's `--remote` SSH stdio bridge:
`--remote` over QUIC, bootstrapped and authenticated over the existing SSH
path. Gives mosh-style roaming/resume (close laptop, switch networks, session
picks up with the newest complete frame) without mosh's downsides — full
scrollback, images, herdr's own protocol. Mosh itself can't be a herdr
transport: it only syncs terminal screen state and cannot carry an arbitrary
byte stream.

- Upstream discussion: [ogulcancelik/herdr#1640][d1640] (author: ondrejsojka)
- PR [#1641][pr1641] (~7k lines, auto-closed by the contribution bot pending
  maintainer approval; maintainer hadn't responded as of 2026-07-23)
- Code: `ondrejsojka/herdr` branch `feat/resumable-quic`

## Local state

- Worktree: `~/src/herdr-worktrees/resumable-quic`
- Local branch: `quic/resumable-quic` (tracks `ondrejsojka/feat/resumable-quic`;
  remote `ondrejsojka` is added in `~/src/herdr`)
- HEAD `3768bd8`, 8 commits, cleanly based on herdr master `0f161fa` (v0.7.5-ish)
- Design doc: `DESIGNDOC-RESUMABLE-HERDR.md` in the worktree root
- Bumps herdr's wire `PROTOCOL_VERSION` — don't point this binary at a stable
  server once built

## Usage (once built)

Config in `~/.config/herdr/config.toml`:

```toml
[remote]
transport = "auto"              # auto | quic | ssh
quic_port_range = "48000-48100" # UDP, must be reachable on the remote
quic_idle_timeout_seconds = 86400
ssh_fallback = true
```

- `auto`: SSH authenticates + bootstraps, hands the client a capability token
  and pinned TLS cert fingerprint, then traffic flows over QUIC. Remote UDP
  listener binds lazily only after SSH bootstrap succeeds.
- `quic` + `ssh_fallback = false`: fail loudly instead of silently using SSH.
- `ssh`: old stdio bridge only (remote can't take UDP).
- Recovery order on stall: QUIC path migration → fresh QUIC conn → SSH
  rebootstrap → SSH stdio bridge. Remote panes keep running throughout.
- Bootstrap still installs a matching `herdr` to `~/.local/bin/herdr` on the
  remote — it will replace whatever herdr is installed there.

## Why the build is blocked (this Mac, macOS 26.5)

herdr vendors libghostty-vt, built by `build.rs` shelling out to `zig build`
(honors a `ZIG` env var; Zig pinned to exactly 0.15.x by an upstream comptime
gate).

- **Zig 0.15.2** (installed at `~/.local/zig-aarch64-macos-0.15.2/`): cannot
  link *any* native executable against the macOS 26.5 SDK — its Darwin
  version tables don't know the SDK, so every libSystem symbol comes back
  undefined (`__availability_version_check`, `_abort`, ...). Reproducible
  with a plain `zig build-exe hello.zig -lc`. Pinning an explicit target
  version fixes `build-exe` but can't be applied to `zig build`'s in-process
  build-runner compile. `MACOSX_DEPLOYMENT_TARGET` is ignored. No 0.15.3
  exists.
- **Zig 0.16.0** (brew): links fine on this SDK, but libghostty-vt hard-gates
  on 0.15.x, and 0.16's std `Io` interface rewrite would mean porting
  vendored Ghostty build code — not a quick patch.

Rust side is fine: rustup via brew (keg-only,
`/opt/homebrew/opt/rustup/bin`), repo pins 1.96.1 via `rust-toolchain.toml`,
already downloaded.

## How to pick it back up

Any of:

1. **Nix** (upstream's dev path — most reliable): install Nix, then in the
   worktree `nix develop -c cargo build --release`. The flake pins nixpkgs
   `zig_0_15` with Nix's own Apple SDK, sidestepping the system SDK.
2. **Newer Zig 0.15.x** if one ever ships with macOS 26 SDK support.
3. **Upstream moves**: watch [#1640][d1640] — if the maintainer lands a
   version of this (or ports to zig 0.16), just `herdr channel set preview`.
4. **CI build**: push `quic/resumable-quic` to the sefk/herdr fork and run
   `.github/workflows/build-artifacts-manual.yml` for a macOS arm64 binary.

`~/bin/herdr-quic-build` retries the local build with the right environment —
run it after fixing the Zig situation.

To discard everything instead:
`cd ~/src/herdr && git worktree remove ../herdr-worktrees/resumable-quic && git branch -D quic/resumable-quic && git remote remove ondrejsojka`

[d1640]: https://github.com/ogulcancelik/herdr/discussions/1640
[pr1641]: https://github.com/ogulcancelik/herdr/pull/1641
