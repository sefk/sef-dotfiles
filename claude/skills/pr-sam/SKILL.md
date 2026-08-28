---
name: pr-sam
description: Squash-and-merge a pull request, after warning about broken tests or open "blocker" review threads, with a hand-written commit message (not GitHub's auto-concatenated one) that you approve before merge. Use when asked to squash and merge a PR, e.g. "/pr-sam", "/pr-sam 42", "squash merge this PR".
argument-hint: "[PR number]"
---

# PR squash-and-merge

The argument is an optional PR number; if omitted, resolve it from the
current branch (`gh pr view --json number --jq .number`). Get `owner`/`repo`
from `gh repo view --json owner,name`. Global git policies apply (never
push, never force anything) — this skill only merges via the GitHub API/CLI,
it doesn't touch local branches.

## 1. Check CI status

Use `pull_request_read` (method `get_status`) or `gh pr checks <n>` to get
the latest check-run results.

- Any check **failing** → warn clearly ("X is failing on this PR") and ask
  before proceeding. Don't merge broken tests silently.
- Checks still **pending/running** → tell the user and ask whether to wait
  or proceed anyway; don't assume.
- All green → note it briefly and continue.

## 2. Check for open blocker threads

Use `pull_request_read` (method `get_review_comments`, paginate until
exhausted) to fetch every review thread.

- Filter to threads where `isResolved` is false.
- Within those, flag any thread where a comment body contains "blocker"
  (case-insensitive) — check literal word and common markers like
  `**Blocker**`, `[blocker]`, `blocking`.
- If any are found, list them (author, file/line, short excerpt) and ask
  the user whether to proceed anyway. Don't merge past an unresolved
  blocker without explicit go-ahead.
- Other unresolved (non-blocker) threads: mention the count in passing, but
  don't block on them.

## 3. Make sure the PR closes its issue

The issue must not have been closed by hand during the fix — GitHub closes it
here, at merge. Confirm the wiring is in place *before* merging:

- Resolve the underlying issue number(s): `pull_request_read` method `get` for
  `closingIssuesReferences`, or `gh pr view <n> --json closingIssuesReferences`.
- If that comes back empty but the head branch is `issue-<N>-*` (or the PR
  body/commits clearly reference an issue), the closing keyword is missing.
  Say so, and offer to append `Closes #<N>` to the PR body via
  `update_pull_request` / `gh pr edit <n> --body ...` before merging. Don't
  merge a linked-issue PR that won't close its issue without saying so.
- If the referenced issue is already **closed**, flag it — something closed it
  early, and it should be reopened so the merge closes it properly.

Carry the resolved issue numbers into step 4.

## 4. Draft the commit message

Pull full PR context: `pull_request_read` (method `get`) for title/body, and
`list_commits` (or `get_diff`) for the individual commit messages that
GitHub would otherwise concatenate.

Write a new squash commit message from scratch — don't just trim GitHub's
default. Since the merge passes an explicit subject/body, GitHub's automatic
`(#N)` PR-number suffix does **not** get appended — add the right number
yourself per below.

- **Title**: PR title, cleaned up (or a better one if the PR title is
  vague), under ~70 chars. Using the underlying issue number(s) from step 3 —
  not the PR's own number:
  - If there's 1–3 such issues, append them to the title:
    `foo bar (#123)` or `foo bar (#123, #124)`.
  - If there are more than 3, or none, leave the title bare — don't force
    it.
- **Body**: short paragraph(s) or bullets covering:
  - What changed from a customer/user-facing angle, if any.
  - Interesting/non-obvious decisions made and why (tradeoffs, things
    someone reading `git log` later would want to know).
  - A final `Closes #123` line (one per underlying issue). The `(#123)` in
    the title is *not* a closing keyword; this line is the belt to the PR
    body's suspenders, and it closes the issue even if the PR link is
    missing.

Explicitly strip out:
- Repeated "Co-Authored-By:" lines — one per commit is fine, but dedupe so
  the same co-author doesn't appear multiple times.
- Claude/Codex/Copilot session links, session IDs, tool-generated
  boilerplate.
- Commit messages that just describe responding to review feedback
  ("address PR comments", "fix Copilot suggestion", "apply Codex review
  fixes", etc.) — that's process noise, not a product change.
- Redundant "fix typo", "wip", "oops" style micro-commits — fold their
  substance into the relevant bullet instead of listing them.

**Show the proposed commit message to the user and wait for explicit
approval before merging.** If they ask for edits, revise and re-show. Don't
proceed to the merge without a clear yes.

## 5. Merge

Once approved, squash-merge via `merge_pull_request` (method `squash`) or
`gh pr merge <n> --squash --subject "<title>" --body "<body>"`, passing the
approved title/body exactly.

Then **verify the issue actually closed**: `gh issue view <N> --json state`
for each underlying issue. If one is still open, close it yourself
(`gh issue close <N>`) with a comment — marked as authored by Claude — naming
the PR and the merge commit SHA.

## 6. Report

Concise:
- CI status at merge time.
- Any blocker threads found and how they were resolved (proceeded anyway /
  addressed first).
- The final commit message used.
- Merge commit SHA / link.
- Which issues closed, and whether GitHub did it or you had to.
