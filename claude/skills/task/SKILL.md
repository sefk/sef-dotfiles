---
name: task
description: Manage the lifecycle of a unit of work across git worktrees, branches, GitHub issues/PRs, herdr workspaces, and agent sessions. Use when asked to set up, find, fork/split, rename, adopt, or wrap up a task, or to report what work is where, e.g. "set up a project for bug 931", "what's stale?", "split this into two tasks", "wrap up 927", "make a workspace to review PR 930", "task status".
---

# Task lifecycle

A *task* is one unit of work. Its state lives in five places that don't know
about each other: a git worktree, a branch, a GitHub issue, a GitHub PR, and a
herdr workspace with an agent in it. `task status` joins them; this skill does
the judgment-laden part: deciding what to create, reuse, rename, or remove,
by composing plain primitives (`git`, `gh`, `wt`, `herdr`). Nothing here is
Claude-specific; the same steps apply from pi, codex, or a shell.

Start every request by reading the state:

```bash
task status            # this repo; add --all for every repo herdr is sitting in
task status --json     # the same, for programmatic use (includes hidden branches)
task here              # the task for the current directory
```

Read the FLAGS column first; it names the drift (`merged`, `closed`, `no-ws`,
`no-pr`, `name?`, `dirty`, `unpushed N`, `adhoc`). The full legend is in
`task --help`.

## One key, one name

The join key is the **issue number** when the work has one, otherwise a
**slug**. Everything about a task carries the same name, so any one of them
identifies the rest:

| thing            | issue work                  | ad-hoc work          |
|------------------|-----------------------------|----------------------|
| branch           | `issue-<N>-<slug>`          | `<slug>`             |
| worktree dir     | `../<repo>-<N>-<slug>`      | `../<repo>-<slug>`   |
| herdr workspace  | `<N>-<slug>`                | `<slug>`             |
| agent name       | `<slug>` (herdr names can't start with a digit) | `<slug>` |

The slug is short (`wt slug <N>` derives one from the issue title, capped at
18 chars), lowercase, dash-separated. **Branch and directory names are the
hard ones to change later** (the PR pins the branch; open shells and agents
pin the directory), so when there is no issue, ask for the slug before
creating anything and say so. When the repo isn't organized around issues
(this dotfiles repo, or one with no GitHub at all), the slug is the only key;
skip everything GitHub-specific below and don't invent an issue.

## Verbs

Each verb starts with `task status`, states a plan (what will be created,
reused, moved, or deleted), and **waits for a yes before anything destructive
or hard to rename**: deleting a branch or worktree, closing a workspace,
renaming a branch that has been pushed. Creating things is not destructive;
do it after a one-line statement of intent.

### new — "set up a project for bug 931" / "set up somewhere to explore X"

1. Determine the key: an issue number (`gh issue view N` for the title), a
   PR number when reviewing someone else's work (`gh pr view N` for its head
   branch), or a slug the user gives or approves.
2. Check `task status --json` for anything already carrying that key: an
   existing branch (local or `origin/`), worktree, or workspace. Reuse what
   exists; never create a second worktree or branch for the same key. `wt`
   already handles "branch exists locally / on origin / not at all" for issue
   work.
3. Worktree and branch:
   - issue: `wt <N> [slug]` (interactive; it shows its plan and assigns the
     dev port). From an agent session, ask the user to run it, or run
     `wt -y <N> <slug>` when they've told you to go ahead.
   - PR review: `gh pr checkout <N>` in a sibling worktree
     (`git worktree add ../<repo>-pr<N> <head-branch>`), workspace label `pr<N>-<slug>`.
   - ad-hoc: `git worktree add -b <slug> ../<repo>-<slug> origin/<default>`.
     Skip the worktree entirely when the repo doesn't use them (dotfiles,
     small repos): a branch in the main checkout is fine, say so.
4. herdr workspace, only when running inside herdr (`HERDR_ENV=1`):
   `herdr workspace create --label <label> --cwd <dir> --focus`, split a
   shell pane to the right, wait for the shell's prompt (direnv output on a
   fresh worktree takes a second), then `herdr agent start <slug> --kind
   <kind> --pane <root>`. Agent names must start with a letter, so the name
   is the slug, not the `<N>-<slug>` label. The `herdr-new-task` popup
   (prefix+n) does the same interactively when the user prefers.
5. Report the key, branch, directory, port (`task here`), and workspace.

### adopt — "put this branch in a workspace" / "I already have a checkout for this"

Same as *new* but starting from whatever exists: attach a worktree to an
existing branch, create a workspace on an existing worktree, or rename a
workspace to match. Report `name?` drift and offer *rename* for it.

### fork / split — "this turned into two things"

The current task is A. The user wants some of its work to become task B.

1. Settle B's key and slug (issue or ad-hoc; file the issue first if the user
   wants one, `gh issue create`).
2. Decide what moves: whole commits (`git cherry-pick` onto B), uncommitted
   hunks (`git stash push -p` / `git add -p` then commit on B), or nothing
   yet (B starts from main). Show the list.
3. Create B with *new*, branching from A's branch when B depends on A's
   commits, otherwise from the default branch. Say which and why: a PR for B
   branched from A carries A's commits until A merges.
4. Remove the moved work from A (`git revert`/`git reset` for commits that
   were cherry-picked, drop stashed hunks), leaving both trees clean.
5. `task status` to confirm both rows look right.

*Rename* is the degenerate fork: nothing moves, only names change. For a
branch that is not yet pushed: `git branch -m`, `git worktree move`,
`herdr workspace rename`, `herdr agent rename`, and rewrite `.env.worktree`
if the number changed. For a pushed branch, keep the branch name (the PR
pins it) and rename only the directory and workspace, or leave everything and
accept the `name?` flag; ask which.

### wrap up — "wrap up 927" / "clean up everything that's merged"

Only for rows flagged `merged`, or `closed` with no unpushed commits, or
ones the user explicitly abandons.

1. `task status --branches` and list the candidates with their flags. Anything
   `dirty` or `unpushed N` is not a candidate until the user says the work is
   disposable; quote the commit subjects (`git log <base>..<branch>`).
2. Show the plan per task: remove worktree, delete local branch, close herdr
   workspace (`herdr workspace close <id>`; the agent inside exits), and
   whether the remote branch is already gone. Wait for a yes.
3. `wt rm <N>` does worktree plus merged-branch removal for issue work; for
   the rest, `git worktree remove <dir>` then `git branch -d <branch>`
   (`-D` only when the user said abandon). Then close the workspace.
4. Never close the GitHub issue; the merge does that. If a merged PR left its
   issue open, say so rather than closing it.
5. `task status` after, to show what's left.

### status — "what's where?" / "what's stale?"

`task status` (or `--all`), then a short reading of it in prose: what's in
flight, what's stranded (`merged`, `closed`, `no-pr` with commits), what's
drifted (`name?`), and what's contending for a port. Offer *wrap up* for the
stranded rows. Don't act.

## Dev stacks

Each worktree owns one app port, written by `wt` into `.env.worktree`
(`8000 + N`). The `PORT` column shows it and whether something is listening;
`up` means live. A worktree pointed at a cloud database shows `STAGING` or
`PROD` there. Two tasks on one port, or a `PROD` you didn't expect, are
worth mentioning before starting a server. One local Postgres serves every
worktree; never stand up a second database per task.

`task herdr-sync` pushes pr/issue/port/drift tokens onto the herdr
workspaces so the sidebar carries the same answers.
