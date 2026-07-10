# sef-dotfiles

My environment/config files. A `Makefile` symlinks them into place. General
instructions live in the global `claude/CLAUDE.md` (deep-linked to
`~/.claude/CLAUDE.md`); this file holds only what's specific to this repo.

## Repo conventions

- Files here must **not** begin with a leading dot. The Makefile adds the dot
  when creating the link (e.g. `vimrc` → `~/.vimrc`).
- The Makefile auto-links every checked-in file/directory. Link targets must
  live under `$HOME` — relative-path munging depends on it.
- `claude/*` is deep-linked file-by-file into `~/.claude/` (see
  `CLAUDE_DEEP_LINKS` in the Makefile). So `claude/CLAUDE.md` becomes the global
  instructions and `claude/settings.json` / `claude/hooks/` become the global
  Claude Code config. `pi/*` and `herdr/*` follow the same file-by-file
  deep-link pattern (`~/.pi/agent/` and `~/.config/herdr/`). File-level linking
  is deliberate: those dirs also hold runtime state (sockets, logs, sessions)
  that must **not** land in the repo, so only the checked-in files are linked —
  for herdr that's just `config.toml`.
- `bash_secret` is **not** checked in but is treated as a link target (special
  create/cleanup logic in the Makefile). It defines things like
  `RESUME_ADDRESS` and `RESTIC_PASSWORD` (encrypts the nightly
  `bin/claude-backup.sh` restic repo — also keep a copy in a password
  manager; without it the backups are unreadable).
- vim plugins are git submodules — run `git submodule init && git submodule
  update` before anything else.
- When setting up a new host, consider adding its hostname to the static list in
  `bash_startup/prompt.sh` to differentiate hosts.
