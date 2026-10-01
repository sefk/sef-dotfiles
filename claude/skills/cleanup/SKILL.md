---
name: cleanup
description: Tear down a finished unit of work — remove its worktree, delete its branch, close its issue if the repo expects that, and hand the herdr tab back for you to close. Use when work is merged, landed, or abandoned and the space should be reclaimed, e.g. "/cleanup", "/cleanup 931", "clean up everything that's merged", "I'm done with this worktree".
---

# Clean up a finished unit of work

`/cleanup [<issue> | <slug> | all]`

The bookend to `space new`. That builds a worktree, a branch, and a herdr
tab; this one takes them away once the work has landed. With no argument it
means the work you're standing in (the branch of the current directory, and
the worktree if it's one); with `all` (or "everything that's merged") it
means every worktree of this project whose branch is merged.

Deleting a branch is the only irreversible step in the whole lifecycle — a
commit that exists nowhere else is gone once its branch is. So this skill is
deliberately reluctant: it enumerates what would be lost, waits for a yes,
and never reaches for `-D` or `--force` on its own judgment.

(The `commit-commands:clean_gone` plugin command also deletes `[gone]`
branches, with `git branch -D` and `git worktree remove --force` on every
one. It knows nothing about herdr, issues, or unpushed work. Don't use it
here.)

## Steps

1. **Read the state.** `space ls` for the project's worktrees, tabs, and
   open PRs in one view (`--json` when you need ids). The project itself is
   `project for .`; its workflow (`project get <p> workflow`) is `worktrees`
   or `main`. For each worktree you're considering, is its branch merged?

   ```bash
   gh pr list --repo <owner/name> --head <branch> --state merged --json number,mergedAt
   git -C $MAIN merge-base --is-ancestor <branch> origin/<default>   # main projects: local merge/rebase
   ```

   Candidates are merged branches, or closed-without-merge ones with no
   unpushed commits, or ones the user explicitly abandons. Nothing else is a
   candidate until they say so.

2. **Look for work that would die with the branch.** Per task, before writing
   any plan:

   ```bash
   git -C <dir> status --porcelain        # dirty
   git -C <dir> stash list                # forgotten hunks
   git -C $MAIN log --oneline <base>..<branch>   # commits not on the base
   gh pr view <N> --json state,mergedAt   # worktrees project: merged, or just closed?
   ```

   Quote what you find — commit subjects, not a count — and stop there. A
   `dirty` or `ahead N` row is not a candidate until the user has seen the
   list and called it disposable. `closed` without `merged` means the PR was
   rejected: its commits exist nowhere else.

3. **State the plan and wait for a yes.** Per task: worktree to remove,
   branch to delete and whether it's merged, issue to close or leave, the
   tab that will be left open, and anything being abandoned. This is
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
   - **`worktrees` project**: never close the issue — the PR merge did that.
     If a merged PR left its issue open, say so and leave it.
   - **`main` project**: nothing closed it automatically. `gh issue close
     <N>` with a comment naming the commits, marked as authored by Claude.

6. **Remove.**
   - issue work in a worktree: `wt rm -y <N>` from the main checkout — it
     removes the worktree and deletes the branch when it's merged, keeps it
     when it isn't, and says which.
   - anything else: `git -C $MAIN worktree remove <dir>` then
     `git -C $MAIN branch -d <branch>`. `-D` only when the user said abandon,
     in those words.
   - the remote branch stays. Deleting it is a push, and you never push —
     mention it's still on origin if it is, and leave it to the user.
   - other work's herdr tabs (batch mode, tabs you are not sitting in)
     close cleanly: `space close <project> <tab-label>`, with the label from
     `space ls`. The agent inside goes with them, so name them in the plan.
     Closing a workspace's last tab closes the workspace too -- fine, `space
     new` recreates it from the registry next time.

7. **Report, then hand back your own tab.** What was removed, what was
   kept and why, what's left on origin. Then end with the handoff line:

   > all done — close the herdr tab with Ctrl-A Shift-X

   Do **not** run `herdr tab close` on the tab you're in. It
   takes this agent, this report, and the shell pane beside it with it, and
   the confirmation vanishes before it's read. Closing it is one keystroke
   for the user and nothing for them to verify afterwards.

## Related

`space new` (driven by the `control` skill from the control session) builds
what this removes. The one-key-one-name convention — branch
`issue-<N>-<slug>`, directory `<repo>-<N>-<slug>`, tab `<N>-<slug>`, agent
`<slug>` — is what lets `space ls` line them up.
