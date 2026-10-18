# Move user launch agents to system LaunchDaemons

Goal: turn off auto-login without losing the services that should survive a
reboot. Daemons live in `/Library/LaunchDaemons`, owned by root, and run as
`sefk` via `UserName`.

Out of scope, decided: Tailscale Funnel (demo only), Docker (unused),
claude-nightly (removed).

## Per-service procedure

For each service below:

- [ ] Copy the plist to `/Library/LaunchDaemons/` as root:wheel, mode 644
- [ ] Add `UserName` = `sefk` and an explicit `HOME` in `EnvironmentVariables`
- [ ] Remove any `LimitLoadToSessionType` that excludes `System`
- [ ] Stop the old agent: `launchctl bootout gui/$(id -u)/<label>`
- [ ] Start the daemon: `sudo launchctl bootstrap system /Library/LaunchDaemons/<label>.plist`
- [ ] Verify: `sudo launchctl print system/<label>` shows running, logs are written, port listens
- [ ] Delete the old plist from `~/Library/LaunchAgents/` so it can't double-start

## Phase 0: Prep

- [ ] Decide which services are really still used (MySQL, Redis, agentsview)
- [ ] Confirm `sudo` works from a terminal you can type into
- [ ] Note log paths; daemons as sefk can still write under `~/Library/Logs`

## Phase 1: Data stores (others depend on these)

- [x] `homebrew.mxcl.postgresql@18` (never via `sudo brew services`; Postgres refuses root)
- [x] `homebrew.mxcl.mysql`: not needed, stopped and agent disabled (data kept)
- [x] `homebrew.mxcl.redis`: not needed, stopped and agent disabled

## Phase 2: Applications

- [x] `com.sefk.wrgpt-buddy.web`
- [x] `com.sefk.wrgpt-buddy.poll`
- [x] `com.sefk.wrgpt-buddy.recommend` (auth is `CLAUDE_CODE_OAUTH_TOKEN` in `.env`, no keychain needed; confirm it runs with no login)
- [ ] `com.sefk.homepower`
- [ ] `com.sefk.grafana` (keep `TZ`)
- [ ] `com.datatalk.cloud-sql-proxy` (ADC is a file in `~/.config/gcloud`)
- [ ] `com.sefk.agentsview` (plist is symlinked from sef-dotfiles; decide where the daemon copy lives)

## Phase 3: Scheduled jobs (credential risk)

- [ ] `com.sefk.claude-backup`: find out how the Synology share is mounted and authenticated; a daemon cannot use a session mount or keychain
- [ ] `com.sefk.homepower-backup`: same share, same answer

## Phase 4: Open questions

- [ ] LM Studio: does 0.4.26 have a headless daemon mode? wrgpt-buddy's local models need it
- [ ] Anything else that listens for outside connections and should stay up

## Phase 5: Repo and tooling cleanup

- [ ] wrgpt-buddy: update `deploy/launchd/*.plist.in` and the `bin/` install scripts, which still target `~/Library/LaunchAgents` and the `gui/` domain
- [ ] homepower: same, for its install scripts and docs
- [ ] sef-dotfiles: update the `make` relink step so it no longer links these agents
- [ ] README and docs that name the agent paths

## Phase 6: Cutover

- [ ] Reboot with auto-login still on; confirm every daemon is up before anyone logs in (check from SSH or another machine)
- [ ] Turn off auto-login (System Settings > Users & Groups)
- [ ] Reboot again; confirm services come up at the login screen
- [ ] Decide on FileVault; if on, a reboot waits at the unlock screen
- [ ] Remove `com.sefk.lock-at-login` once auto-login is off
