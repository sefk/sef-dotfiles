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

3. **Branch / worktree** — depends on the project's workflow in the
   registry (`project for .` names the project, `project get <p> workflow`
   is `worktrees` or `main`; the global Version Control policy explains both).
   - **`worktrees` project** (datatalk): work happens on `issue-<N>-<slug>` in
     a sibling worktree (`../<repo>-<N>-<slug>`), never in the main checkout.
     Check where you are first: `git rev-parse --abbrev-ref HEAD` and
     `git worktree list`. If this directory isn't issue N's worktree — the
     main checkout, another issue's tree, or the control session in `~/src`
     — **hand off instead of implementing here**:

     ```bash
     space new <project> --issue <N> --slug <slug> --model <model> --prompt "/fix-issue <N>"
     ```

     `--model` is required on a hand-off. Pick it with the rule under
     "Choosing the model for a hand-off" below, and say which one you chose.

     That builds the worktree (via `wt`), a tab in the project's herdr
     workspace with a claude agent in it, sends it this same command, and
     focuses it. Settle the slug first (next bullet) and pass it with
     `--slug`. Then report where the space is and that `/fix-issue <N>` was
     kicked off there, and go no further. Two agents in two trees on one
     issue is the collision the worktree exists to prevent — that's why this
     session hands off, not a reason to leave the new one idle. If `space`
     dies because herdr isn't running, `wt -y <N> <slug>` still makes the
     worktree; name the directory and stop.

     Only continue here when you're already on issue N's branch — or when the
     fix is a one-liner and the current branch is already a working branch.
     Never `git worktree add`, never `isolation: "worktree"`, never start work
     on the default branch.
   - **`main` project (default)**: work happens in the main checkout.
     Small fixes commit straight onto the current branch (usually `main`);
     anything that needs to stay reviewable or reversible on its own gets a
     local feature branch (`issue-<N>-<short-slug>`) that you merge or
     rebase back into `main` yourself when done — never open a PR for it.
     If you're in the control session rather than the project, hand off the
     same way: `space new <project> --main --model <model> --prompt "/fix-issue <N>"`.
   - **Never pick the slug silently.** Wherever a slug is about to become a
     branch name — the feature branch here, or the worktree `space new`
     builds — and it came from the issue title rather than from the user,
     stop and ask which one they want (`AskUserQuestion` when you have it;
     `wt slug <N>` for the suggestion, plus an alternative or two, and
     *Other* for their own words). A branch and a directory are the hardest
     things to rename afterwards, so the question is cheap by comparison.
     A slug the user typed needs no question.
   - **Choosing the model for a hand-off.** The session doing the reading
     and planning is usually the expensive one (Fable); the space it hands
     off to should not inherit that by default. Pick from the issue, not
     from habit, and pass it as `--model`:
     - `sonnet` — the work is well-scoped once read: the issue names the
       files or the acceptance test, the fix is mechanical, investigative
       (pull numbers, compare, write them down), config or Terraform with a
       known shape, copy changes, or a test-and-doc follow-up.
     - `opus` — the fix needs design judgment inside the code: choosing
       between stores or mechanisms, touching concurrency or cancellation,
       changing a shared interface, anything where a wrong first cut is
       expensive to unwind.
     - `fable` — only when the user asks for it, or the task is itself
       planning or orchestration (an epic to break down, a design to spar
       over). Never the default for an implementer.
     When in doubt between two, take the cheaper one; the agent can escalate
     by asking, and the review loop catches a weak fix. An epic is split
     into one space per sub-issue, each with its own model choice.
   - **Name the space to match.** Once you're settled in issue N's worktree
     and herdr is running (`HERDR_ENV=1`), the tab and agent should carry the
     same key as everything else: tab label `<N>-<slug>`, agent `<slug>`,
     both read off the branch (`issue-<N>-<slug>`), which is the authority —
     it's the name the PR pins. A space that `space new` built is already
     right; one adopted from a shell or a `wt` run often isn't.

     ```bash
     herdr tab rename "$HERDR_TAB_ID" <N>-<slug>
     herdr agent rename "$HERDR_PANE_ID" <slug>   # herdr names can't start with a digit
     ```

     Both renames are display-only and reversible, so don't ask — do it and
     say so in a clause. Leave it alone when you're working in the main
     checkout: that tab belongs to the repo, not to this task.

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
   - **`worktrees` project**: do not close the issue. Comment with what changed,
     files touched, branch name, and test results, marked as authored by
     Claude Code. Don't mention push state ("not pushed", "local only") —
     it goes stale as soon as the user pushes.
     **Never `gh issue close`** — it stays open through review and GitHub
     closes it when the PR merges. To make that happen, the PR body must
     carry `Closes #<N>`; if a PR already exists, verify the line is there
     and add it if not, and if the PR is opened later, state in your report
     that its body needs `Closes #<N>`.
   - **`main` project**: nothing closes the issue automatically. If the fix
     already landed on `main` (merged or rebased locally), close it yourself
     (`gh issue close <N>`) with a comment — marked as authored by Claude
     Code — naming the commit(s). If it's still sitting on an unmerged local
     feature branch, leave the issue open and say so; comment with progress
     instead.

9. **Report** — tell the user branch, commits, and test status in a couple
   of lines. No long recap.
