---
name: pr-followup
description: Address every review comment on a pull request end-to-end — fix the code where you agree, explain your reasoning in-thread where you don't, and get Codex's concurrence on the fixes before reporting back. Use when asked to follow up on PR feedback/review comments, e.g. "/pr-followup", "/pr-followup 42", "address the review comments on this PR", "respond to the PR feedback".
argument-hint: "[PR number]"
---

# PR review follow-up

The argument is an optional PR number; if omitted, resolve it from the current
branch (`gh pr view --json number --jq .number`). Get `owner`/`repo` from
`gh repo view --json owner,name`. Work in the current repo, on the PR's
branch (it should already be checked out). Global git policies apply
throughout (autonomous commits, never push) and per the repo's CLAUDE.md,
identify yourself as Claude in every comment you post.

## 1. Gather

Use `pull_request_read` with method `get_review_comments` (paginate with
`perPage`/`after` until exhausted) to fetch every review thread: each has
`isResolved`/`isOutdated` plus its comments (`body`, `author`, `path`,
`line`, and a numeric comment id).

- **Skip threads where `isResolved` is true** — already settled.
- **Skip threads whose latest comment is already your own** (body contains
  a Claude signature) — protects reruns from replying twice.
- Also pull general, non-inline discussion with `get_comments` (method on
  the same tool) for anything that reads as feedback needing a response but
  isn't attached to a code line.

## 2. Triage each remaining thread

For every comment, decide:

- **Agree** → it gets fixed in step 3.
- **Disagree** → no code change; work out the reasoning you'll post.

Judgment calls still get a decision, not a punt — pick a side and explain
why in the reply. Only escalate to the user in the final report, not by
silently skipping the comment.

## 3. Fix the agreed-upon issues

Apply the fixes directly on the PR branch. Follow the engineering rules:
add/adjust tests for behavioral fixes, update any docs the change touches.
Commit per git policy — one commit per logical change; reference the file/
comment topic in the message so the history reads clearly against the
review.

## 4. Codex must concur too

Once your fixes are committed, get a second opinion: invoke the
`codex-review` skill with no explicit scope (`/codex-review`) and let it
auto-detect (it'll pick up the commits-ahead-of-origin / branch diff).

Then loop:
- triage its findings against the diff (clear-cut / judgment-call /
  rejected)
- address the clear-cut ones, plus any judgment call bearing on whether the
  original review comments are actually resolved, adding/adjusting tests
  for behavioral fixes
- re-run the tests
- amend the round's changes into the relevant fix commit (do not amend
  pushed commits)
- have Codex re-review

Repeat until Codex raises no clear-cut findings, or ~2-3 rounds pass without
converging.

**Escape hatch — escalate, don't override.** If Codex still won't concur
after a couple of rounds (or its objection is a judgment call you disagree
with), stop and note both positions in the final report instead of looping
indefinitely or silently overriding it.

## 5. Reply in-context

For every thread from step 2, reply on the specific comment so the thread
carries the resolution, not a general PR comment:

- `add_reply_to_pull_request_comment` — pass the numeric comment id (the
  `#discussion_r...`-style id from step 1's `get_review_comments` output,
  **not** the `PRRT_...` thread node id).
- **Fixed** → state what changed and reference the commit (short SHA).
- **Disagreed** → explain the reasoning plainly enough the reviewer can
  push back if they disagree with you.
- For general (non-inline) comments gathered in step 1, reply with a normal
  PR comment (`gh pr comment` or `issue_write`) instead.

Don't resolve threads (`pull_request_review_write` `resolve_thread`) —
that's the reviewer's call once they've read your reply, not yours.

## 6. Report

Concise, no filler:

- **Fixed** — each thread, what changed, commit.
- **Disagreed** — each thread, your reasoning.
- **Codex** — rounds run, outcome, any escalated disagreement.
- If commits are on an unpushed local branch, say so — you never push.
