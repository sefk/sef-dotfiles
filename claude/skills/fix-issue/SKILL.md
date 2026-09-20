---
name: fix-issue
description: Fix a GitHub issue end-to-end — read it, plan, implement, test, commit on a branch, comment on the issue. Use when asked to fix, resolve, or handle a numbered GitHub issue in the current repo, e.g. "/fix-issue 42", "fix issue #42", or "fix #42".
---

# Fix a GitHub issue end-to-end

The argument is an issue number, optionally followed by extra guidance. Work
in the current repo. Global git policies apply throughout (autonomous
commits, working branch for multi-step work, never push).

1. **Read** — `gh issue view <N> --comments`. Understand the actual ask;
   follow links to related issues/PRs when they matter.

2. **Plan** — restate the problem in one line to the user. If the approach
   is non-obvious or a design choice matters, post the brief plan as an
   issue comment (marked as authored by Claude Code) before coding, so the
   decision is on the record. Trivial fixes skip the comment.

3. **Branch / worktree** — depends on the repo's workflow (global Version
   Control policy; `.wtconfig`'s `TASK_TEAM=1` marks a team repo):
   - **Team repo**: work happens on `issue-<N>-<short-slug>` in a sibling
     worktree (`../<repo>-<N>-<slug>`), never in the main checkout. Check
     where you are first (`task here`). If this directory isn't issue N's
     worktree — the main checkout, or another issue's tree — **stop and
     hand off**: invoke the `new-space` skill with the issue number. It
     builds the worktree and a herdr workspace with a claude agent waiting
     in it; you report where it is and that `/fix-issue <N>` is the user's
     to type there, and go no further. Don't prompt that agent yourself. Two agents in two trees on one issue is the collision the
     worktree exists to prevent. Without herdr, `new-space` still makes the
     worktree; name the directory and stop. Only continue here when you're
     already on issue N's branch — or when the fix is a one-liner and the
     current branch is already a working branch. Never `git worktree add`,
     never `isolation: "worktree"`, never start work on the default branch.
   - **Individual repo (default)**: work happens in the main checkout.
     Small fixes commit straight onto the current branch (usually `main`);
     anything that needs to stay reviewable or reversible on its own gets a
     local feature branch (`issue-<N>-<short-slug>`) that you merge or
     rebase back into `main` yourself when done — never open a PR for it.
   - **Never pick the slug silently.** Wherever a slug is about to become a
     branch name — the feature branch here, or the worktree `new-space`
     builds — and it came from the issue title rather than from the user,
     stop and ask which one they want (`AskUserQuestion` when you have it;
     `wt slug <N>` for the suggestion, plus an alternative or two, and
     *Other* for their own words). A branch and a directory are the hardest
     things to rename afterwards, so the question is cheap by comparison.
     A slug the user typed needs no question.
   - **Name the space to match.** Once you're settled in issue N's worktree
     and herdr is running (`HERDR_ENV=1`), the workspace should carry the
     same key as everything else: label `<N>-<slug>`, agent `<slug>`, both
     read off the branch (`issue-<N>-<slug>`), which is the authority — it's
     the name the PR pins. A space that `/new-space` built is already right;
     one adopted from a shell, a `wt` run, or a renamed branch often isn't,
     and that drift is what `task status` flags as `name?`.

     ```bash
     herdr workspace get "$HERDR_WORKSPACE_ID" | jq -r '.result.workspace.label'
     herdr workspace rename "$HERDR_WORKSPACE_ID" <N>-<slug>
     herdr agent rename "$HERDR_PANE_ID" <slug>   # herdr names can't start with a digit
     ```

     Both renames are display-only and reversible, so don't ask — do it and
     say so in a clause. Leave it alone when you're working in the main
     checkout (individual repos, or a one-liner on an existing branch): that
     workspace belongs to the repo, not to this task, and `<N>-<slug>` would
     be wrong the moment the issue is done.

4. **Implement** — directly, or delegated:
   - **Delegate when well-scoped**: if after Read/Plan the fix has a clear
     acceptance test, known target files, and no open design decisions,
     farm implementation off to a subagent — the project's `dev` agent if
     one is listed, otherwise `general-purpose`. Always pass
     `model: "sonnet"` explicitly (implementer agents without model
     frontmatter inherit the expensive session model). The prompt must be
     self-contained: issue number and summary, the agreed approach, target
     files, branch to work on, test commands, and project constraints from
     CLAUDE.md (e.g. formatting before `git add`). Have it implement, run
     tests, and commit; you review the diff afterward.
   - **Do it yourself** when scoping is fuzzy, the fix spans design
     decisions, or a delegated attempt misses twice — don't loop.
   - Either way: add or update tests per the engineering rules; update any
     README/docs the change affects in the same commit.

5. **Codex must concur too.** Once your own tests pass, commit the fix so
   far, then get a second opinion from Codex: invoke the `codex-review`
   skill with no explicit scope (`/codex-review`) and let it auto-detect —
   whole-branch diff on a feature branch, or commits-ahead-of-origin when
   the fix landed on the default branch.

   Then loop:
   - triage its findings against the diff (clear-cut / judgment-call /
     rejected)
   - address the clear-cut ones, plus any judgment call that bear on
     whether the issue is solved, adding/adjusting tests for behavioural
     fixes
   - re-run the tests
   - amend the round's changes into the fix commit (do not amend pushed
     commits)
   - have Codex re-review

   Repeat until Codex raises no clear-cut findings and concurs the issue
   is resolved, or ~2–3 rounds pass without converging.

   **Escape hatch — escalate, don't override.** If after a couple of rounds
   Codex still won't agree the problem is solved (or its remaining
   objection is a judgment call you disagree with), stop and escalate to
   the user with both positions. Don't quietly declare the issue resolved
   over Codex's objection, and don't loop indefinitely — overriding Codex is
   the user's call, not yours.

6. **Verify** — run the project's test suite (fast loop while iterating,
   full suite at the end; check the project CLAUDE.md for the commands).
   For visible changes, look at the result (screenshot / capture-pane)
   before calling it fixed. If implementation was delegated, verify in the
   main session anyway — don't take the subagent's word that tests pass.

7. **Commit** — one commit per logical change; append (`#<N>)` at the end of the
   message subject line and in the body.

8. **Close the loop.**
   - **Team repo**: do not close the issue. Comment with what changed,
     files touched, branch name, and test results, marked as authored by
     Claude Code. If commits are on an unpushed local branch, say so.
     **Never `gh issue close`** — it stays open through review and GitHub
     closes it when the PR merges. To make that happen, the PR body must
     carry `Closes #<N>`; if a PR already exists, verify the line is there
     and add it if not, and if the PR is opened later, state in your report
     that its body needs `Closes #<N>`.
   - **Individual repo**: nothing closes the issue automatically. If the fix
     already landed on `main` (merged or rebased locally), close it yourself
     (`gh issue close <N>`) with a comment — marked as authored by Claude
     Code — naming the commit(s). If it's still sitting on an unmerged local
     feature branch, leave the issue open and say so; comment with progress
     instead.

9. **Report** — tell the user branch, commits, and test status in a couple
   of lines. No long recap.
