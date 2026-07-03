#!/bin/bash
# Overnight datatalk test run + triage, timed for the idle overnight
# rate-limit window so results are waiting at the ~07:00 workday start.
#
# Cheap by design: the full pytest suite runs with zero LLM involvement.
# Claude (sonnet, headless) is invoked only when tests fail, to triage the
# failures and file/update a GitHub issue. It never edits files or fixes
# anything — mornings start with a diagnosis, not a surprise refactor.
#
# Driven by launchd (com.sefk.claude-nightly.plist) at 04:30; the hostname
# guard makes it a no-op if the plist ever gets loaded on the laptop.
# DRY_RUN=1 runs the suite but prints the triage prompt instead of
# invoking claude.

set -uo pipefail
PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

REPO="$HOME/src/biglocalnews/datatalk"
PYTEST_LOG="$REPO/.tmp/nightly-pytest.log"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

[ "$(hostname -s)" = "studio" ] || { log "not studio; skipping"; exit 0; }
[ -d "$REPO" ] || { log "repo missing; skipping"; exit 0; }

cd "$REPO"
mkdir -p "$(dirname "$PYTEST_LOG")"

head_sha=$(git rev-parse --short HEAD)
dirty=$(git status --porcelain | head -20)

log "full suite at $head_sha${dirty:+ (dirty tree)}"
uv run pytest 2>&1 | tee "$PYTEST_LOG" >/dev/null
status=${PIPESTATUS[0]}

if [ "$status" -eq 0 ]; then
    log "all tests passed"
    exit 0
fi

log "pytest exit $status — triaging"

PROMPT="You are running unattended (nightly test triage, no user present).
The datatalk full test suite just failed on studio at commit $head_sha.
${dirty:+NOTE: the working tree had uncommitted changes, so failures may not
reflect committed code. Dirty files (first 20):
$dirty
}
The tail of the pytest output is on stdin; the full log is at
.tmp/nightly-pytest.log.

1. Group the failures by likely root cause (read the full log and code as
   needed; 'git log --since=yesterday' may point at the culprit change).
   Distinguish real regressions from environment problems (DB down, docker
   not running, network) and say which is which.
2. File it: if an open issue whose title starts with 'Nightly:' exists
   (gh issue list --state open --search \"Nightly: in:title\"), add a
   comment; otherwise create one titled 'Nightly: <one-line summary>'.
   Include commit sha, the dirty-tree note if any, failure groups with
   suspected causes, and exact failing test ids. State clearly the issue
   was filed automatically by Claude Code from an unattended nightly run.
3. Do NOT modify files, do NOT attempt fixes, do NOT close issues.

Reply with the issue URL and a one-line summary."

if [ "${DRY_RUN:-0}" = "1" ]; then
    log "DRY_RUN: would invoke claude with prompt:"
    printf '%s\n' "$PROMPT"
    exit 0
fi

tail -150 "$PYTEST_LOG" \
    | timeout 1800 claude -p --model sonnet \
        --disallowedTools "Edit,Write,NotebookEdit" \
        "$PROMPT"
log "triage done (claude exit $?)"
