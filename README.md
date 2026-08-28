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
wt 853 [slug]   create/attach ../<repo>-853 on issue-853-<slug>
wt ls           list this repo's worktrees
wt rm 853       remove the worktree, and the branch if merged
wt path 853     print the path, for `cd "$(wt path 853)"`
```

Siblings, not `.worktrees/` or `.claude/worktrees/`: a nested worktree lands in
the Docker build context, pytest's collection root, and every file watcher.

The slug is looked up from the issue title via `gh` when omitted. Per-repo
setup comes from an optional `.wtconfig` at the repo root — which untracked
files to symlink back to the main checkout (`.env`, `.envrc`), which env var
gets a per-worktree port, and a setup command (`uv sync`). Example:

```sh
WT_LINK=".env .envrc"
WT_PORT_VAR=CHAINLIT_PORT   # issue 853 -> CHAINLIT_PORT=8853 in .env.worktree
WT_PORT_BASE=8000
WT_SETUP="uv sync"
```

The worktree needs to load `$WT_PORT_FILE` for the port to take effect — for a
direnv repo, add `dotenv_if_exists .env.worktree` to `.envrc` after `.env`.
Share the one local service stack across worktrees; a distinct app port is
enough, no second database per tree.

`bin/herdr-new-task` (prefix+n) ties into this: name a task with a trailing
number in a GitHub repo and it looks the number up as an issue, offers to build
the worktree, and opens the workspace there.

The matching agent policies — never create a worktree, never close an issue
early — live in `config/agents/GLOBAL.md`.

## Things to set up on new machines

Longer time to use a screenshot

```
defaults write com.apple.screencaptureui "thumbnailExpiration" -float 20 && killall SystemUIServer
```

