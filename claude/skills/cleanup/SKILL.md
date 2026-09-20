---
name: cleanup
description: Tear down a finished unit of work — remove its worktree, delete its branch, close its issue if the repo expects that, and hand the herdr workspace back for you to close. Use when work is merged, landed, or abandoned and the space should be reclaimed, e.g. "/cleanup", "/cleanup 931", "clean up everything that's merged", "I'm done with this worktree".
---

# Clean up a finished unit of work

`/cleanup [<issue> | <slug> | all]`

The bookend to `new-space`. That skill makes a worktree, a branch, and a
herdr workspace; this one takes them away once the work has landed. With no
argument it means the task you're standing in (`task here`); with `all` (or
"everything that's merged") it means every row `task status` flags as done.

Deleting a branch is the only irreversible step in the whole lifecycle — a
commit that exists nowhere else is gone once its branch is. So this skill is
deliberately reluctant: it enumerates what would be lost, waits for a yes,
and never reaches for `-D` or `--force` on its own judgment.

(The `commit-commands:clean_gone` plugin command also deletes `[gone]`
branches, with `git branch -D` and `git worktree remove --force` on every
one. It knows nothing about herdr, issues, or unpushed work. Don't use it
here.)

## Steps

1. **Read the state.** `task here` for the current task, `task status
   --branches` for the full picture (`--json` when you need the hidden rows).
   Candidates are rows flagged `merged`, or `closed` with no unpushed
   commits, or ones the user explicitly abandons. Nothing else is a candidate
   until they say so.

2. **Look for work that would die with the branch.** Per task, before writing
   any plan:

   ```bash
   git -C <dir> status --porcelain        # dirty
   git -C <dir> stash list                # forgotten hunks
   git -C $MAIN log --oneline <base>..<branch>   # commits not on the base
   gh pr view <N> --json state,mergedAt   # team repo: merged, or just closed?
   ```

   Quote what you find — commit subjects, not a count — and stop there. A
   `dirty` or `ahead N` row is not a candidate until the user has seen the
   list and called it disposable. `closed` without `merged` means the PR was
   rejected: its commits exist nowhere else.

3. **State the plan and wait for a yes.** Per task: worktree to remove,
   branch to delete and whether it's merged, issue to close or leave, the
   workspace that will be left open, and anything being abandoned. This is
   the destructive verb — the approval is not optional.

4. **Gather everything before you remove anything.** You are usually standing
   *inside* the worktree you're deleting. Once it's gone your own cwd doesn't
   exist and every later shell command fails, so:
   - run git from the main checkout (`git -C $MAIN`; it's the first entry of
     `git worktree list --porcelain`),
   - collect the commit shas, branch name and PR state you'll need for the
     issue comment and the report *first*,
   - make the worktree removal the **last command you run**. After it, only
     talk.

5. **GitHub first, while the tree is still there.**
   - **team repo**: never close the issue — the PR merge did that. If a
     merged PR left its issue open, say so and leave it.
   - **individual repo**: nothing closed it automatically. `gh issue close
     <N>` with a comment naming the commits, marked as authored by Claude.

6. **Remove.**
   - issue work in a team repo: `wt rm -y <N>` from the main checkout — it
     removes the worktree and deletes the branch when it's merged, keeps it
     when it isn't, and says which.
   - anything else: `git -C $MAIN worktree remove <dir>` then
     `git -C $MAIN branch -d <branch>`. `-D` only when the user said abandon,
     in those words.
   - the remote branch stays. Deleting it is a push, and you never push —
     mention it's still on origin if it is, and leave it to the user.
   - other tasks' herdr workspaces (batch mode, workspaces you are not
     sitting in) close cleanly: `herdr workspace close <id>`. The agent
     inside goes with them, so name them in the plan.

7. **Report, then hand back your own workspace.** What was removed, what was
   kept and why, what's left on origin. Then end with the handoff line:

   > all done — close the herdr space with Ctrl-A Shift-D

   Do **not** run `herdr workspace close` on the workspace you're in. It
   takes this agent, this report, and the shell pane beside it with it, and
   the confirmation vanishes before it's read. Closing it is one keystroke
   for the user and nothing for them to verify afterwards.

## Related

`new-space` builds what this removes. `task` holds the rest of the lifecycle
(adopt, fork/split, rename) and the one-key-one-name convention that lets
`task status` join a branch, a worktree, an issue, a PR, and a workspace into
one row.
