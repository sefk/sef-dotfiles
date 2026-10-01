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
dropped, capped at 18 characters on a word boundary. The same slug names the
directory, the branch, the herdr tab, and the agent (see the next section).

Per-repo setup comes from the project registry (next section): which untracked
files to symlink back to the main checkout (`link`), which env vars get a
per-worktree port (`ports`, `NAME=base` pairs; issue 853 gets `base + 853`),
and a setup command (`setup`). The port lands in `.env.worktree`; a direnv repo
loads it with `dotenv_if_exists .env.worktree` after `.env`. A new worktree
with an `.envrc` gets `direnv allow` run in it — a new path is a new direnv
block even when `.envrc` is the same file the main checkout already approved.
Share the one local service stack across worktrees; a distinct app port is
enough, no second database per tree. `WT_DRY_RUN=1` prints the plan and stops.

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

## Control session (`control/AGENTS.md`, `bin/project`, `bin/space`, `bin/control`)

herdr runs one session in one Ghostty window. Each project is a workspace
(`datatalk`, `leafletter`, `sef-dotfiles`, `bench`) and each unit of work is a
tab inside it — claude in the left pane, a shell on the right. The tab row is
always shown; Cmd-Ctrl-[ / ] step between tabs (a Ghostty keybind in
`config/ghostty/config` sends herdr's `prefix+[` / `prefix+]`, since Cmd
chords never reach the pty). The `studio` / `studio-mosh` zsh functions attach
to studio's session in the current terminal.

Tabs are made by talking to the **control session**: a claude session (sonnet,
it's a small problem) sitting in `~/src`, in the first tab of the `control`
workspace. `prefix+n` (`bin/herdr-control`) jumps there, creating the
workspace, tab, and agent if they don't exist. "Fix datatalk 1102", "temp
window on leafletter main", "pick up the 1106 PR followup", "what's open?" —
the `control` skill (`claude/skills/control`, also linked into
`~/.agents/skills/` for pi) turns those into `space` calls and sends you to
the result. It never does the work itself.

- **`~/src/AGENTS.md`** is the project registry — `control/AGENTS.md` here,
  deep-linked by the Makefile; `~/src/CLAUDE.md` just includes it. One `##`
  section per project with `key = value` lines: `path`, `repo`, `workspace`,
  `workflow` (`main`: work in the checkout, no PRs; `worktrees`: a sibling
  worktree and a PR per issue — datatalk), `aliases`, and the `wt` settings
  above. Prose under each section is for whoever's reading. Taking on a new
  project means adding a section. This replaces the per-repo `.wtconfig`,
  which was my metadata in other people's repos.
- **`bin/project`** reads it: `list`, `get <name> <key>`, `resolve <alias>`,
  `for <dir>` (worktrees resolve to their project), `json`.
- **`bin/space`** is the plumbing. `space new <project> --issue N | --branch B
  | --main [--slug S] [--prompt TEXT]` makes the worktree when the workflow
  calls for one (via `wt -y`), the tab in the project's workspace, the
  claude agent named after the slug, sends the prompt once it's idle, and
  focuses the tab. It refuses a bare request in a `worktrees` project and
  won't build a second tab for a live issue. `space ls` is the overview
  (workspaces, tabs, agents and their states, worktrees, open PRs);
  `space focus` and `space close` do what they say.
- **`bin/control`** is what runs in the control pane: `claude --model
  sonnet`, or `pi` on the LM Studio model when a quick claude probe fails
  (`CONTROL_AGENT=pi` forces it, `CONTROL_PROBE=0` skips the probe).

One slug serves all four names, so they read as the same thing:

```
issue #861 "Write up some coding guidelines starting with comments"

  directory  ../datatalk-861-write-coding
  branch     issue-861-write-coding
  tab        861-write-coding
  agent      write-coding
```

`/fix-issue N` from the control session, or from a session in the wrong
tree, hands off with `space new <project> --issue N --prompt "/fix-issue N"`;
`/cleanup` from inside a finished tab removes the worktree and branch and
hands the tab back to close. Status beyond `space ls` is still an open
question — the `task`/`wrangle` tooling that used to live here was too
clunky and is gone; herdr-projects, herdr-radar, or captains-deck are the
candidates.

## Quota history (`claude/statusline-command.sh`)

The status line's `cc 5h/7d cx 5h/7d` group shows how much of each subscription
window is spent, and it is the only place those numbers exist locally: Claude
hands them to the status line on every render but never writes them to the
transcript, and [agentsview] stores no rate-limit data at all — not even
Codex's, which sit in the rollout files it already parses. So the status line
keeps a sidecar. Whenever a window's rounded percentage or reset time moves it
appends one record per window to `~/.agentsview/quota.jsonl`:

```json
{"ts":"2026-09-08T19:45:12Z","agent":"claude","window":"five_hour","used_percent":41,"resets_at":1788940800}
```

Unchanged renders cost one read of `quota.state` and no writes, so the hot path
stays cheap; `CLAUDE_QUOTA_LOG=off` disables it. Sampling only happens while a
session is rendering, which is enough to reconstruct the peak of a window but
not to prove a quiet one stayed quiet. Which window is which comes from
`window_minutes`, not from Codex's `primary`/`secondary` position — Codex moved
its weekly window into `primary` and dropped `secondary` to null.

[agentsview]: https://www.agentsview.io/

## Things to set up on new machines

Longer time to use a screenshot

```
defaults write com.apple.screencaptureui "thumbnailExpiration" -float 20 && killall SystemUIServer
```

