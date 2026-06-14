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
  Claude Code config.
- `bash_secret` is **not** checked in but is treated as a link target (special
  create/cleanup logic in the Makefile). It defines things like
  `RESUME_ADDRESS`.
- vim plugins are git submodules — run `git submodule init && git submodule
  update` before anything else.
- When setting up a new host, consider adding its hostname to the static list in
  `bash_startup/prompt.sh` to differentiate hosts.
