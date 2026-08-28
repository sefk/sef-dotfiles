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

3. **Branch / worktree** — work happens on `issue-<N>-<short-slug>` in a
   sibling worktree (`../<repo>-<N>`), never in the main checkout and never in
   a worktree you create yourself. If you aren't already in one, ask the user
   to run `wt <N> <slug>` and wait — don't `git worktree add`, don't use
   `isolation: "worktree"`, and don't start work on the default branch. A
   one-line fix may land on the current branch if it's already a working
   branch.

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

8. **Close the loop — but do not close the issue.** Comment on the issue
   with what changed, files touched, branch name, and test results, marked as
   authored by Claude Code. If commits are on an unpushed local branch, say
   so. **Never `gh issue close`** — the issue stays open through review and
   GitHub closes it when the PR merges. To make that happen, the PR body must
   carry `Closes #<N>`; if a PR already exists, verify the line is there and
   add it if not, and if the PR is opened later, state in your report that its
   body needs `Closes #<N>`.

9. **Report** — tell the user branch, commits, and test status in a couple
   of lines. No long recap.
