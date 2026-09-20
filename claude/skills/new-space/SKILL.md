---
name: new-space
description: Create an isolated space for one unit of work — a sibling git worktree on a feature branch plus a herdr workspace with a claude agent waiting in it. Use when asked to start work somewhere new or to move work out of the current worktree, e.g. "/new-space 931", "/new-space 931 masthead-freshness", "/new-space spike-caching", "make me a space for this".
---

# New space for a unit of work

`/new-space [<issue>] [<slug>]`

One command for what `wt` and the `herdr-new-task` popup (prefix+n) do by
hand: a sibling worktree on its own branch, a herdr workspace labelled the
same, a claude agent sitting in it ready for work. The session that runs
this **does not do the work, and does not start it** — it builds the space,
focuses it, and stops. The first instruction is the user's to type.

This is the one place allowed to run `wt` itself (`wt -y`, which prints its
plan and skips the question). The global ban still holds everywhere else and
for every other mechanism: no `git worktree add`, no `isolation: "worktree"`,
no `EnterWorktree`.

## Arguments

Both are optional, but you need one of them:

- **numeric first argument** — a GitHub issue number. A second argument, if
  given, is the slug.
- **non-numeric first argument** — a slug; this is ad-hoc work with no issue
  behind it. Don't invent an issue number for it.
- **neither** — ask for one; don't guess and don't invent an issue number. If
  the user names an issue by its title rather than its number, find it
  (`gh issue list --search '<words>'`) and confirm the number.

### Always confirm a slug you derived

**The slug is the one thing to stop and ask about.** It names the branch and
the directory, which are the two hardest things to change later — the PR
pins the branch, and open shells, agents, and `.env.worktree` pin the
directory. Renaming afterwards is a `task` *rename* with four moving parts;
picking it now costs one question.

So: whenever the slug did not come from the user, **ask before creating
anything** — an explicit question in the session (`AskUserQuestion` when you
have it), not a line in the plan they might skim past. Offer:

- the derived slug first, marked recommended — `wt slug <N>` turns the issue
  title into one (lowercase, dashes, stopwords dropped, 18-char cap);
- one or two genuine alternatives that emphasize a different part of the
  issue, not near-spellings of the same words;
- free text, which the question's *Other* option already gives them.

An interactive `wt` offers the same edit; `wt -y` doesn't, and this skill
runs `wt -y`, so the question is this skill's job. Skip it only when the
user typed the slug on the command line — that was already their answer.

Whatever comes back, `wt` runs it through the same slugify: lowercase,
dashes, stopwords dropped, capped at 18 characters. If that changes what
they chose, say the resulting branch name plainly rather than letting them
find it later.

## Steps

1. **Read the state first.** `task status --json` in the current repo, plus
   `task here`. Everything carrying the key already exists or it doesn't:
   - worktree *and* workspace already there → focus the workspace
     (`herdr workspace focus <id>`), say so, stop. Never a second worktree or
     branch for one key.
   - worktree but no workspace → skip step 4, build the workspace on the
     existing directory.
   - branch on `origin/` but no worktree → fine, `wt` checks it out rather
     than branching afresh.

2. **Check the repo's workflow.** The main checkout is the first entry of
   `git worktree list --porcelain`; team workflow is `TASK_TEAM=1` in its
   `.wtconfig`. If that's absent the repo is individual — work belongs in the
   main checkout and a worktree is against its grain. Say that in one line
   and wait for a yes before continuing; an explicit `/new-space` is a good
   reason to override it, just not silently.

3. **Settle the slug, then state the plan and build it.** Ask about the slug
   first if you derived it (above) — that question comes before the plan,
   because the plan is written in terms of its answer. Then one block:
   issue/slug, branch name, worktree directory, port from `.wtconfig`'s
   `WT_PORT_VARS`, workspace label, agent name. Creating is not destructive —
   with the slug settled, don't wait for a second yes unless step 2 asked for
   one.

4. **Worktree** — `wt -y <N> <slug>` for issue work, `wt -y <slug>` for
   ad-hoc (a non-numeric argument makes `wt` treat it as a branch name:
   branch `<slug>`, directory `../<repo>-<slug>`, no port offset). `wt`
   creates or reuses the branch, symlinks `.env`/`.envrc`, writes
   `.env.worktree`, runs `WT_SETUP`, and `direnv allow`s the new path.

   A script can't cd your shell and it can't cd you either: take the
   directory from `wt path <N>`, or `../<repo>-<slug>` for ad-hoc work. Run
   every later command with `git -C <dir>` or `--cwd <dir>`; don't try to
   move this session into the worktree.

5. **Workspace** — only when herdr is running (`HERDR_ENV=1`); without it,
   report the worktree and stop there.

   ```bash
   ws=$(herdr workspace create --label <label> --cwd <dir> --focus)
   root=$(printf '%s' "$ws" | jq -r '.result.root_pane.pane_id')
   herdr pane split "$root" --direction right --cwd <dir> --no-focus
   herdr agent start <agent-name> --kind claude --pane "$root" --timeout 60000
   ```

   - label is `<N>-<slug>` for issue work, `<slug>` for ad-hoc.
   - agent name is the slug — herdr names can't start with a digit, so a slug
     that does (`2fa-login`) becomes `<repo>-<slug>`.
   - the generous `--timeout`: on a fresh worktree the shell prompt waits on
     direnv and `WT_SETUP`. When a repo needs longer still, wait on the
     prompt yourself with `herdr pane wait-output` before starting the agent.
   - `herdr agent start` has been flaky. If it fails, say so, leave that pane
     as a shell in the worktree, and carry on to the report — one retry at
     most, no loop.

6. **Leave the agent at its prompt.** Don't submit anything to it — no
   `herdr agent prompt`, not even the obvious `/fix-issue <N>`. Starting the
   work is the user's call and the user's first keystroke; the workspace is
   focused, so they're already looking at the cursor. Tell them what to type
   rather than typing it for them.

7. **Report and stop.** Two lines: key, branch, directory, port, workspace,
   and the command to run over there (`/fix-issue <N>` for issue work).
   Anything you learned on the way that the next agent can't easily find —
   a related worktree, a superseded PR, an open question on the issue — goes
   in the report too, since the user is about to brief that agent. Then
   stop — the work belongs to the space you just made, and doing it here as
   well is exactly the collision the worktree was for.

## Related

`cleanup` is the bookend: it removes the worktree and branch this skill
creates, once the work has landed. `task` covers the rest of the lifecycle
(adopt, fork/split, rename) and the reasoning behind the one-key-one-name
convention; `new-space` is its *new* verb with the questions already
answered. `fix-issue` calls this skill when issue work turns up in the wrong
worktree.
