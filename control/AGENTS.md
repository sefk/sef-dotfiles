# Projects

The registry of what I'm working on, read by the control session (tab 1 of the
`control` herdr workspace) and by `project`, `wt`, and `space` in
`sef-dotfiles/bin`. This file lives in sef-dotfiles as `control/AGENTS.md` and
is linked here; `CLAUDE.md` beside it just includes it.

Each project is a `## <name>` section. Lines of the form `key = value` directly
under the heading are machine-readable (`project get <name> <key>`); anything
else is prose for whoever is reading. Keys:

| key         | meaning                                                            |
|-------------|--------------------------------------------------------------------|
| `path`      | main checkout (worktrees are siblings of it)                       |
| `repo`      | GitHub `owner/name`                                                |
| `workspace` | herdr workspace label this project's tabs live in                  |
| `workflow`  | `main` (work in the checkout, no PRs) or `worktrees` (PRs, sibling worktree per issue) |
| `aliases`   | other words I use for it, comma-separated                          |
| `link`      | untracked files `wt` symlinks from the main checkout into a worktree |
| `ports`     | `VAR=base` pairs; a worktree for issue N gets `VAR=base + N % 1000` in `.env.worktree` |
| `setup`     | shell run inside a fresh worktree                                  |
| `layout`    | tab layout for new work (default `claude-shell`: claude left, shell right) |

Add a section when I take on something new; drop it when it's shelved.

## datatalk

path = ~/src/biglocalnews/datatalk
repo = biglocalnews/datatalk
workspace = datatalk
workflow = worktrees
aliases = dt
link = .env
ports = CHAINLIT_PORT=8000
setup = uv sync

Team project, the only one. Every issue gets its own sibling worktree and a
PR; the main checkout stays parked on `main`. One shared Postgres for all
worktrees; only the Chainlit port differs.

## leafletter

path = ~/src/leafletter-app
repo = sefk/leafletter-app
workspace = leafletter
workflow = main

Solo project. Work straight on `main` in the checkout; several tabs may sit in
the same directory.

## sef-dotfiles

path = ~/src/sef-dotfiles
repo = sefk/sef-dotfiles
workspace = sef-dotfiles
workflow = main
aliases = dotfiles, config

My environment and tooling, including the control session itself. `make`
relinks after changes.

## bench

path = ~/src/bench
repo = sefk/bench
workspace = bench
workflow = main

Local LLM investigations (LM Studio, ollama, fm).
