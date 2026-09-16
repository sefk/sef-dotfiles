---
name: codex-review
description: Dispatch the current session's work to Codex for a non-interactive code review, then triage and auto-fix the findings. Use when asked to have Codex review the changes, e.g. "/codex-review", "get codex to review this", or "codex-review --base main".
argument-hint: "[--uncommitted | --base <branch> | --commit <sha>] [extra instructions]"
---

# Codex review of the current changes

Hand this session's work to Codex (`gpt-5.5`) for a second-opinion review,
then triage what it says and fix the clear-cut findings. Global git policies
apply throughout (autonomous commits, working branch for multi-step work,
never push).

The heavy lifting is in `bin/codex-review.sh` (on PATH as `codex-review.sh`),
which picks a review scope from git state and runs `codex review`. Your job is
to dispatch it, then judge and act on the results — Codex reviews are useful
but not infallible, so verify before you fix.

## 1. Dispatch (background)

Forward the skill argument straight to the helper; with no argument it
auto-detects the scope:

- uncommitted changes present → `--uncommitted`
- clean tree on a feature branch → `--base <default-branch>`
- clean tree on the default branch, ahead of origin → `--base origin/<default>`

Run it **in the background** so this session isn't blocked:

```
codex-review.sh $ARGUMENTS
```

(via Bash with `run_in_background: true`). Tell the user in one line what
scope is being reviewed, then continue — you'll be notified when it finishes.
A review typically takes 1–2 minutes.

**Scope caveat:** auto-detect prefers uncommitted changes. If the user is on a
feature branch with *committed* work they want reviewed (not just the working
tree), pass `--base <branch>` explicitly. If their intent is ambiguous, ask
before dispatching rather than reviewing the wrong slice.

## 2. Collect

When the background task completes, read its output (also saved to the temp
file whose path it printed). Handle failure first:

- Non-zero exit / no findings / an error (auth, dyld/sandbox, "nothing to
  review") → report the actual error and stop. Don't invent findings. For a
  sandbox/dyld failure, the fix is usually rerunning
  `~/.codex/fix-codex-dyld-sandbox.sh` after a codex upgrade.

## 3. Triage

For each finding Codex reports, **check it against the real diff before
trusting it** — Codex sometimes flags code it misread, things that are correct
in context, or issues outside the reviewed scope. Classify each into:

- **Clear-cut** — a real bug, correctness issue, or obvious defect you can
  confirm from the diff, with an unambiguous fix. → auto-fix in step 4.
- **Judgment call** — style/architecture opinions, risky or wide-reaching
  changes, anything where the "right" answer is a decision or Codex's premise
  is shaky. → list for the user, don't touch.
- **Rejected** — you verified it's wrong or already handled. → mention briefly
  so the user knows you considered and dismissed it.

## 4. Auto-fix the clear-cut findings

Apply the fixes directly. Follow the engineering rules: add/adjust tests for
behavioural fixes, update any docs the change touches, run the project's
tests before calling it done. Commit per the git policy (one commit per
logical change; a working branch if this turns into multi-step work).

## 5. Report

Concise, no filler:

- **Fixed** — each clear-cut finding and what you changed (+ commit / test
  result).
- **Needs your call** — each judgment-call finding with Codex's reasoning and
  your take, so the user can decide fast.
- **Dismissed** — one line each for rejected findings.

If nothing was actionable, say so plainly.
