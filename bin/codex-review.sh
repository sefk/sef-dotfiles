#!/bin/bash
# codex-review.sh — dispatch a non-interactive Codex code review of the
# current git changes and print the findings.
#
# Usage:
#   codex-review.sh                       # auto-detect what to review
#   codex-review.sh --uncommitted         # any args are forwarded to `codex review`
#   codex-review.sh --base main
#   codex-review.sh --base main "focus on error handling"
#   codex-review.sh --commit HEAD
#
# With NO args it inspects git state and picks a scope:
#   * uncommitted changes present            -> --uncommitted
#   * clean tree, on a feature branch        -> --base <default-branch>
#   * clean tree, on default branch ahead of -> --base origin/<default>
#     origin
#   * otherwise: nothing to review (exit 3)
#
# Any args are forwarded verbatim to `codex review`, so the auto-detection is
# only a convenience — pass explicit scope flags to override it.
#
# Designed to be launched in the background by Claude Code's /codex-review
# skill, which then reads the output and triages the findings. Also useful
# standalone from a shell. Combined stdout+stderr is tee'd to a temp file whose
# path is printed at the end.
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not in a git repo" >&2; exit 2; }
cd "$root"

default_branch() {
  local d
  d=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null \
        | sed 's@^refs/remotes/origin/@@')
  [ -n "$d" ] && { echo "$d"; return; }
  for c in main master; do
    git show-ref --verify --quiet "refs/heads/$c" && { echo "$c"; return; }
  done
  git branch --show-current
}

if [ "$#" -gt 0 ]; then
  args=("$@")
else
  branch=$(git branch --show-current)
  def=$(default_branch)
  if [ -n "$(git status --porcelain)" ]; then
    args=(--uncommitted)
  elif [ -n "$def" ] && [ "$branch" != "$def" ]; then
    args=(--base "$def")
  elif git rev-parse --verify --quiet "origin/$def" >/dev/null 2>&1 \
       && [ -n "$(git rev-list "origin/$def..HEAD" 2>/dev/null)" ]; then
    args=(--base "origin/$def")
  else
    echo "nothing to review: clean tree with no unpushed commits" >&2
    exit 3
  fi
fi

out=$(mktemp -t codex-review-XXXXXX)
echo ">>> codex review ${args[*]}" >&2
echo ">>> findings -> $out" >&2
# Disable errexit around the pipeline: on a non-zero codex exit, pipefail would
# otherwise abort here and skip the status capture + footer below — exactly the
# failure case the footer is meant to report.
set +e
codex review "${args[@]}" 2>&1 | tee "$out"
status=${PIPESTATUS[0]}
set -e
echo ">>> codex review exit=$status ; findings saved to $out" >&2
exit "$status"
