---
name: fix-issue
description: Fix a GitHub issue end-to-end — read it, plan, implement, test, commit on a branch, comment and close. Use when asked to fix, resolve, or handle a numbered GitHub issue in the current repo, e.g. "/fix-issue 42", "fix issue #42", or "fix #42 and close it".
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
3. **Branch** — multi-step work goes on `issue-<N>-<short-slug>`; a small
   self-contained fix may land on the current branch.
4. **Implement** — make the change. Add or update tests per the engineering
   rules; update any README/docs the change affects in the same commit.
5. **Verify** — run the project's test suite (fast loop while iterating,
   full suite at the end; check the project CLAUDE.md for the commands).
   For visible changes, look at the result (screenshot / capture-pane)
   before calling it fixed.
6. **Commit** — one commit per logical change; reference `#<N>` in the
   message body.
7. **Close the loop** — comment on the issue with what changed, files
   touched, branch name, and test results, marked as authored by Claude
   Code. If commits are on an unpushed local branch, say so. Close the
   issue (`gh issue close`) only when it is fully resolved; otherwise
   leave it open and state what remains.
8. **Report** — tell the user branch, commits, and test status in a couple
   of lines. No long recap.
