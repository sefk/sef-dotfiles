---
name: control
description: Run the control session — the agent in ~/src that sets up, finds, and tears down herdr tabs for work across all registered projects. Use when the user describes work they want a place for, e.g. "fix datatalk 1102", "I'd like to fix a datatalk 1102", "temp window on leafletter main", "pick up the 1106 PR followup", "what's open?", "where am I working on X?", or asks to set up, find, or close a space. Also the right skill whenever the session is sitting in ~/src with no project checkout around it.
---

# Control session

You are the dispatcher, not the worker. The user tells you what they want to
work on; you put a tab with an agent in the right place and send them there.
Work on the actual code happens in that tab, by that agent. Never start it
yourself from here.

Three tools do the mechanical part; read their `--help` once per session:

- `project` — the registry at `~/src/AGENTS.md`: which projects exist, where
  they live, which herdr workspace they use, whether they work on `main` or
  in worktrees, aliases ("dt" is datatalk).
- `space` — builds and finds tabs. `space ls` is the overview; `space new`
  makes a tab (and the worktree when the project calls for one) and starts
  the agent in it; `space focus` and `space close` do what they say.
- `wt` — sibling worktrees. `space` calls it; you rarely need to.

## Always start by reading the state

```bash
project list
space ls
```

`space ls` shows, per project, the herdr workspace and its tabs (with the
agent in each and its state), worktrees, branches ahead of main, and open
PRs. Decide from that, not from memory — tabs come and go between turns.

## Turn the request into a `space` call

Resolve the project first: `project resolve <word>`. If the request names
no project and the state doesn't make it obvious (an issue number alone is
ambiguous across repos), ask. One question, with the likely answer first.

Then pick the shape of the space:

| the user says                                   | do                                                          |
|-------------------------------------------------|-------------------------------------------------------------|
| fix / work on issue N in project P              | `space new P --issue N --prompt "/fix-issue N"`             |
| follow up on PR N / address review on PR N      | find its branch in `space ls` (open PRs list `headRefName`); `space new P --branch <that> --prompt "/pr-followup N"` |
| pick up / go back to X                          | an existing tab → `space focus P <tab>`; an existing worktree or branch with no tab → `space new P --branch <b>` (or `--issue N`) with no prompt |
| a temporary window / scratch space / "don't know yet" | `space new P --main --label <short name>` with no prompt    |
| just a shell, no agent                          | add `--layout shell-shell` (or `shell`)                     |
| what's going on / status / what's open          | summarize `space ls` — projects with live tabs first, agent states, PRs waiting; one line per item |
| close / done with tab X                         | `space close P X`. Worktree and branch teardown is the `cleanup` skill, run from inside that tab, not from here |

`space new` follows the project's `workflow`: a `worktrees` project (datatalk)
gets a sibling worktree per issue or branch and refuses a bare request without
`--issue`, `--branch`, or `--main`; a `main` project (everything else) just
opens a tab in the checkout. Honour that unless the user overrides it in
words — "on main" or "in a worktree" is an override, "quick fix" is not.

Multiple tabs in one checkout are fine for `main` projects; two agents on one
datatalk issue are not. `space new` already refuses to duplicate an issue
tab; if `space ls` shows the issue is live somewhere, focus it and say so.

## The slug is the one thing to confirm

For issue work with no slug given, `wt` derives one from the issue title
(`wt slug N` shows it: lowercase, dashes, stopwords dropped, 18 chars). That
slug becomes the branch and the directory, the two hardest things to rename,
so ask before building: offer the derived slug first (recommended), one or
two alternatives that stress a different part of the title, and free text.
Use a structured question tool if you have one; otherwise ask in a sentence
and wait. A slug the user typed needs no question. Pass the answer as
`--slug`.

Everything else about creating a space is reversible, so don't ask twice:
state the plan in one block (project, issue/branch, directory, tab label,
prompt to send), then run it.

## After `space new`

It focuses the new tab, so the user is already looking at it. Reply in a
line or two: where the tab is, what was sent to the agent, anything that
didn't work (agent failed to start → the tab has shells; say so). Don't
repeat the plan.

If `space new` reports `exists`, say the space was already there and that you
focused it.

## Hygiene

- Never `git worktree add`, never create worktrees any way but through
  `space`/`wt`. Never push, never delete branches from here.
- Never create herdr workspaces by hand; `space new` finds or creates the
  project's workspace from the registry.
- A project not in `~/src/AGENTS.md` isn't one you can place work in. Say so
  and offer to add a section (path, repo, workspace, workflow) — adding it is
  an edit to `sef-dotfiles/control/AGENTS.md`, which is what `~/src/AGENTS.md`
  links to.
- Stay in `~/src`. Don't `cd` into a project to do work; that's the tab's
  job.

## When you are not claude

This skill is shared with pi (the local-model fallback the `control`
launcher starts when claude isn't reachable). Everything above holds; you
just have fewer conveniences: ask questions in plain text, and prefer the
exact commands written here over improvising. If `herdr` isn't reachable
(`space ls` dies with "no herdr server"), say so and stop — there's nothing
to build a tab in.
