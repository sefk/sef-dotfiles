# sef-dotfiles

My environment/config files. A `Makefile` symlinks them into place. This file
is the Codex counterpart to `CLAUDE.md` — Codex reads it from the repo root when
working here; keep the two in sync. My global Codex instructions live at
`~/.codex/AGENTS.md` (not tracked in this repo). This file holds only what's
specific to this repo.

## Repo conventions

- Files here must **not** begin with a leading dot. The Makefile adds the dot
  when creating the link (e.g. `vimrc` → `~/.vimrc`).
- The Makefile auto-links every checked-in file/directory. Link targets must
  live under `$HOME` — relative-path munging depends on it. Repo-root
  `CLAUDE.md` and `AGENTS.md` are excluded from linking: they are project-scoped
  instructions read from the repo, not linked into `$HOME`.
- `claude/*` is deep-linked file-by-file into `~/.claude/` (see
  `CLAUDE_DEEP_LINKS` in the Makefile); `pi/*` and `herdr/*` follow the same
  pattern (`~/.pi/agent/` and `~/.config/herdr/`). Only checked-in files are
  linked — runtime state (sockets, logs, sessions) stays out of the repo.
  Codex config under `~/.codex/` is not deep-linked here yet.
- `bash_secret` is **not** checked in but is treated as a link target (special
  create/cleanup logic in the Makefile). It defines things like
  `RESUME_ADDRESS` and `RESTIC_PASSWORD` (encrypts the nightly
  `bin/claude-backup.sh` restic repo — also keep a copy in a password
  manager; without it the backups are unreadable).
- vim plugins are git submodules — run `git submodule init && git submodule
  update` before anything else.
- When setting up a new host, consider adding its hostname to the static list in
  `bash_startup/prompt.sh` to differentiate hosts.
