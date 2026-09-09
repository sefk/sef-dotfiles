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
dropped, capped at `WT_SLUG_MAX` (18) on a word boundary. One slug serves all
three names, so they read as the same thing:

```
issue #861 "Write up some coding guidelines starting with comments"

  directory  ../datatalk-861-write-coding
  branch     issue-861-write-coding
  workspace  861-write-coding
```

Per-repo setup comes from an optional `.wtconfig` at the repo root — which untracked
files to symlink back to the main checkout (`.env`, `.envrc`), which env vars
get a per-worktree port (one line each, `NAME=base`; the older
`WT_PORT_VAR=NAME` plus `WT_PORT_BASE` still works), and a setup command
(`uv sync`). Example:

```sh
WT_LINK=".env .envrc"
WT_PORT_VARS="CHAINLIT_PORT=8000 EVAL_PORT=9000"  # issue 853 -> CHAINLIT_PORT=8853
                                                  # and EVAL_PORT=9853 in .env.worktree
WT_SETUP="uv sync"
```

A new worktree with an `.envrc` gets `direnv allow` run in it — a new path is a
new direnv block even when `.envrc` is the same file the main checkout already
approved. The worktree still needs to load `$WT_PORT_FILE` for the port to take
effect: in a direnv repo, add `dotenv_if_exists .env.worktree` to `.envrc`
after `.env`.
Share the one local service stack across worktrees; a distinct app port is
enough, no second database per tree.

`bin/herdr-new-task` (prefix+n) opens a named herdr workspace on a directory
with a chosen pane layout and starts the agent, named after the workspace. Run
`wt` first and give the workspace the same `<N>-<slug>` name as the directory
and branch, so `task status` can join them (see below).

The zsh prompt (`oh-my-zsh/custom/themes/sefk.zsh-theme`) squashes the last
path component to a letter when it would just repeat the branch — a worktree
directory is its branch with the project name in front. Ordinary checkouts
keep their name, since there the branch says nothing about the project:

```
~/s/b/d (issue-861-write-coding) >     worktree
~/s/b/datatalk (main) >                main checkout
```

The matching agent policies — never create a worktree, never close an issue
early — live in `config/agents/GLOBAL.md`.

## Task lifecycle (`bin/task`, `claude/skills/task`)

A task's state is scattered over five places that don't know about each other:
a git worktree, a branch, a GitHub issue, a GitHub PR, and a herdr workspace
with an agent in it. `task` joins them on one key — the issue number, or a slug
for work without one — and reports the drift between them, which is what
"stranded work" and "which session is this" actually are:

```
task status            one row per task in this repo; --all for every repo
                       herdr is sitting in, --branches to include bare
                       branches, --json for the whole thing
task here [--short]    the row for this directory; --short is the one-liner
                       the prompts use
task herdr-sync        push kind/pri/pr/issue/port/need tokens onto the
                       matching herdr workspaces (display-only metadata)
task brief             where attention belongs (see "Wrangling" below)
```

```
    PRI  KEY  SLUG               TAGS               WT  PR            ISSUE   HERDR              AGENT               PORT     FLAGS
🌳  P3   920  log-lines          ops                ✓   #925 open     open    920-log-lines      claude idle (done)  8920 up  ahead 9
🌳  P2   902  missing-nonauth    loader             ✓   #904 merged   closed  902-loaders        claude idle         8902     merged name?
👀  P2   712  overhead-grouping  sql_agent decision ✓   #882 open     open    882-group-payroll  claude idle         8882     name?
```

The first column is the **kind**, derived rather than declared: 🌳 issue work
of mine, 👀 a worktree sitting on someone else's PR, 🧭 ad-hoc work with no
issue. PRI and TAGS come from the issue's labels and are painted in GitHub's
own label colors on a terminal, so P0/P1 and `sql_agent` vs `ops` read at a
glance without the numbers. `merged` and `closed` mean the worktree/workspace
outlived its work; `name?` means branch, directory, and workspace slugs
disagree (the last row is issue 712's branch in a directory named after its
PR — the classic bug-vs-PR mixup); `no-pr`, `dirty`, `unpushed N` flag work
that hasn't left the machine. The legend is in `task --help`. GitHub state is
cached for ten minutes under `~/.cache/task/`; herdr and `lsof` are queried
live and skipped when absent.

`task` is read-only on purpose. The flexible part — set up, adopt, fork/split
(one piece of work that turned out to be two), rename, wrap up — is the `task`
agent skill in `claude/skills/task/SKILL.md`, written tool-neutrally and
linked into `~/.agents/skills/` for pi/codex. It reads `task status`, states a
plan, and composes `wt`, `git`, `gh`, and `herdr`; anything destructive waits
for a yes. "Set up a project for bug 931" or "split this into two tasks" from
any agent session is the intended interface; `wt` and the herdr popup remain
the primitives underneath.

Both prompts carry the one-liner in a linked worktree (never a main checkout):

```
~/s/b/datatalk-920-log-lines (issue…) [#920 · pr925 open · :8920] >
```

The zsh theme and the Claude statusline call `task here --short`, which prints
a per-directory cached line and refreshes it in the background, so a prompt
costs ~0.1s and never waits on GitHub. The `:8920` appears only while a dev
stack is actually listening there; the port a worktree *would* use is a
`task status` matter.

## Wrangling (`task brief`, `bin/wrangle-tick`, `claude/skills/wrangle`)

With a dozen agents running, green/yellow/red per pane doesn't say what each
one *needs*. `task brief` does: for every task row it reads the agent's last
words (herdr knows the Claude session id; the transcript is the jsonl under
`~/.claude/projects/`), the PR's review state (requested reviewers,
unresolved threads by author, CI, conflicts, whether the last push came after
your last look), and the issue's priority — and it adds open P0/P1 issues and
review requests that have no worktree at all. The result is a ranked list with
a reason per line:

```
 96 P1 datatalk  cand-list: the agent's last message asks you something (31h ago)
 94 P1 datatalk  #862 … by newsroomdev: your review is requested; pushed 6h ago, after your agent's findings (6d ago)
 92 P0 datatalk  #715 Memo rows get one rule …: P0, assigned to newsroomdev, no branch or agent on it
```

Bands: 90+ someone or something is waiting on you now (or a P0 is unowned);
70s something of yours is stuck; 50s finished work that hasn't left the
machine; 30s hygiene. `--since-last` prints only items that are new or rose a
band (exit 3 when nothing did), which is what makes the rest cheap:

- `bin/wrangle-tick`, run by launchd every five minutes
  (`launchd/com.sefk.wrangle-tick.plist`), refreshes the brief, paints
  kind/pri/need tokens onto the herdr sidebar, and nudges a Claude agent named
  `wrangler` only when something new appeared (any band while you're active;
  band 4 only, hourly at most, while you're away) or as a 30-minute heartbeat
  while you're active. It reads the keyboard idle time and backs off to hourly
  after an hour idle and four-hourly after eight, so overnight it costs
  nothing but a few `gh` calls.
- The `wrangle` skill is the judgment half: the wrangler agent reads the brief
  and answers "what are the one or two things worth my attention, and why",
  in under 150 words, by slug not number. It is read-only toward other agents
  (never prompts them or answers their dialogs) and toward GitHub.

Set-up is one herdr workspace on the project's main checkout with an agent
named `wrangler` (the skill has the commands), then
`launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.sefk.wrangle-tick.plist`.
Log: `~/.cache/task/wrangle-tick.log`.

## Things to set up on new machines

Longer time to use a screenshot

```
defaults write com.apple.screencaptureui "thumbnailExpiration" -float 20 && killall SystemUIServer
```

