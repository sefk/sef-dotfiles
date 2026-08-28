# My Environment Files

Now using submodules for vim plugins, so remember to do a "submodule init" and
"submodule update" before doing anything else.

Consider adding the hostname to the static list in `prompt.sh` to differentiate
between hosts.

My pile of environment files.

Makefile will set up symlinks. Automatically sets up links for all files /
directories checked in here. Files here should **not** begin with a leading dot,
although the link to them well. Has some special creation and cleanup logic to
handle the file `bash_secret`. That file isn't to be checked in, but should
otherwise be treated as a link target.

Restriction: since I do sloppy text munging to create the relative pathnames for
links, the target for these links must be a subdirectory of the user's home.

`git-completion.bash` just copied in here out of laziness. Using version
1.7.11-rc0 from
`http://repo.or.cz/w/git.git/blob/HEAD:/contrib/completion/git-completion.bash`.
I should probably use a submodule or something.

.bash_secret should look like:
```
export RESUME_ADDRESS="street<br>city, state, zip<br>phone<br>"
```

TODO - Maybe all this gitconfig stuff shouldn't be universal? Hm. - Consider
adding submodule stuff to the makefile. That somehow seems wrong though.

## Issue worktrees (`bin/wt`)

Issue work happens in a sibling worktree, never in the main checkout — the main
checkout stays parked on the default branch so concurrent tasks can't collide.

```
wt 853 [slug]   create/attach ../<repo>-853-<slug> on issue-853-<slug>,
                and cd there
wt ls           list this repo's worktrees
wt rm [853]     remove the worktree — default, the one you're in — and the
                branch if merged; leaves you in the main checkout
wt path 853     print the path, for `cd "$(wt path 853)"`
wt slug 853 12  print the slug for an issue number or a string, at that
                length — for callers with a tighter budget than a branch name
```

`bash_startup/wt.sh` defines a `wt` shell function around `bin/wt`; it's what
lets `wt` drop you in the new worktree and `wt rm` move you out of the
directory it just deleted. Bash picks it up from the `bash_startup` loop, zsh
sources it explicitly. Calling `bin/wt` directly still works — it just prints
the `cd` for you to run.

The slug is in the directory name so a listing of siblings says what each tree
is for. Lookups go by branch, so `wt path`/`wt rm` still find a tree you
renamed, or one from the older slugless layout.

Siblings, not `.worktrees/` or `.claude/worktrees/`: a nested worktree lands in
the Docker build context, pytest's collection root, and every file watcher.

The slug is looked up from the issue title via `gh` when omitted — filler words
dropped, capped at `WT_SLUG_MAX` (24) on a word boundary, so "Write up some
coding guidelines starting with comments; take a cleanup pass" becomes
`write-coding-guidelines`. Per-repo setup comes from an optional `.wtconfig` at the repo root — which untracked
files to symlink back to the main checkout (`.env`, `.envrc`), which env var
gets a per-worktree port, and a setup command (`uv sync`). Example:

```sh
WT_LINK=".env .envrc"
WT_PORT_VAR=CHAINLIT_PORT   # issue 853 -> CHAINLIT_PORT=8853 in .env.worktree
WT_PORT_BASE=8000
WT_SETUP="uv sync"
```

A new worktree with an `.envrc` gets `direnv allow` run in it — a new path is a
new direnv block even when `.envrc` is the same file the main checkout already
approved. The worktree still needs to load `$WT_PORT_FILE` for the port to take
effect: in a direnv repo, add `dotenv_if_exists .env.worktree` to `.envrc`
after `.env`.
Share the one local service stack across worktrees; a distinct app port is
enough, no second database per tree.

`bin/herdr-new-task` (prefix+n) ties into this: name a task with a trailing
number in a GitHub repo and it looks the number up as an issue, offers to build
the worktree, and opens the workspace there. A name that is *only* the number
also names the workspace after the issue, at a 12-character slug and without
the project name, which the directory already carries:

```
task name "861"  ->  worktree ../datatalk-861-write-coding-guidelines
                     workspace "861-write-coding"
```

The matching agent policies — never create a worktree, never close an issue
early — live in `config/agents/GLOBAL.md`.

## Things to set up on new machines

Longer time to use a screenshot

```
defaults write com.apple.screencaptureui "thumbnailExpiration" -float 20 && killall SystemUIServer
```

