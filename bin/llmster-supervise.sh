#!/bin/bash
# Keep the LM Studio headless daemon (llmster) and its OpenAI-compatible HTTP
# server alive. Anything pointed at localhost:1234 — ssrename, for one — gets
# connection refused the moment either one goes away.
#
# `lms daemon up` starts llmster in the background and exits immediately, and
# the daemon does NOT open the HTTP server on its own, so `lms server start`
# has to follow it. Because both commands exit, there is no process for launchd
# to supervise; that is what this wrapper provides. It starts the pair, then
# blocks, health-checking until something breaks.
#
# On failure it exits non-zero rather than repairing in place: launchd's
# KeepAlive restarts it, so startup has exactly one code path and launchd owns
# the throttling and the logging. Before, the agent was RunAtLoad-once with
# KeepAlive false, so a single OOM kill of llmster (its last exit status was
# -9) left the port dead until the next login.
#
# Driven by launchd (com.sefk.llmster.plist), which logs to
# ~/.lmstudio/llmster-launchd.log.

set -uo pipefail
PATH="$HOME/.lmstudio/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

PORT="${LLMSTER_PORT:-1234}"
CHECK_INTERVAL="${LLMSTER_CHECK_INTERVAL:-30}"
# The daemon needs a moment after `server start` before it answers HTTP; don't
# declare failure during that window.
STARTUP_GRACE="${LLMSTER_STARTUP_GRACE:-60}"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

# Ask the daemon for its own PID. Prints nothing and returns non-zero when the
# daemon is down, so callers can test either the output or the status.
daemon_pid() {
    local out
    out="$(lms daemon status 2>/dev/null)" || return 1
    # "llmster v0.0.18+1 is running (PID: 74637)"
    printf '%s' "$out" | sed -n 's/.*(PID: \([0-9]\{1,\}\)).*/\1/p' | head -1
}

server_up() {
    curl --silent --fail --max-time 10 \
        "http://localhost:${PORT}/v1/models" >/dev/null 2>&1
}

# Bring up the daemon and the HTTP server. Both are idempotent, and both can
# lose a race against launchd tearing down the previous run's process group
# (`lms server start` has been seen taking a SIGKILL that way), so retry here
# rather than exiting: bailing out costs a full ThrottleInterval of downtime
# for a fault that clears on the next try a second later.
start_stack() {
    local attempt
    for attempt in 1 2 3 4 5; do
        if lms daemon up && lms server start --port "$PORT"; then
            return 0
        fi
        log "startup attempt ${attempt} failed; retrying"
        sleep 3
    done
    return 1
}

log "starting llmster supervisor (port ${PORT})"

if ! start_stack; then
    log "ERROR: could not start llmster and its server after 5 attempts"
    exit 1
fi

pid="$(daemon_pid)"
if [ -z "$pid" ]; then
    log "ERROR: daemon reported no PID after startup"
    exit 1
fi
log "llmster running (PID: $pid), server on port ${PORT}"

# Wait for the HTTP server to actually answer before entering the watch loop,
# so a slow start isn't mistaken for a failure.
deadline=$((SECONDS + STARTUP_GRACE))
until server_up; do
    if [ "$SECONDS" -ge "$deadline" ]; then
        log "ERROR: server did not answer on port ${PORT} within ${STARTUP_GRACE}s"
        exit 1
    fi
    sleep 2
done
log "server answering on port ${PORT}; supervising"

# Block for the daemon's lifetime. `wait` only works on our own children and
# llmster is not one, so poll instead. Exiting on any fault hands the restart
# back to launchd.
while sleep "$CHECK_INTERVAL"; do
    if ! kill -0 "$pid" 2>/dev/null; then
        log "llmster (PID: $pid) is gone; exiting for launchd to restart"
        exit 1
    fi
    if ! server_up; then
        log "server on port ${PORT} stopped answering; exiting for launchd to restart"
        exit 1
    fi
done
