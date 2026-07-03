#!/bin/bash
# Nightly restic backup of Claude Code session data (transcripts, prompt
# history, plans, rewind snapshots) to the Synology Archive share, which
# the NAS mirrors offsite to Backblaze. restic encrypts client-side, so
# the guest-writable share never sees plaintext.
#
# Secrets: RESTIC_PASSWORD comes from ~/.bash_secret. If that password is
# lost the repo is unreadable — keep a copy in a password manager.
#
# Driven by launchd (com.sefk.claude-backup.plist) at 03:30 daily on both
# studio and laptop; missed runs fire on wake. Concurrent runs against the
# shared repo are absorbed by --retry-lock rather than a schedule offset.

set -euo pipefail
PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

SHARE="//GUEST@synology.local/Archive"
REPO_SUBDIR="restic/claude"
OWN_MNT="$HOME/.local/state/claude-backup/mnt"
BACKUP_PATHS=(
    "$HOME/.claude/projects"
    "$HOME/.claude/history.jsonl"
    "$HOME/.claude/plans"
    "$HOME/.claude/file-history"
)

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

source "$HOME/.bash_secret"
if [ -z "${RESTIC_PASSWORD:-}" ]; then
    log "FATAL: RESTIC_PASSWORD not set in ~/.bash_secret"
    exit 1
fi
export RESTIC_PASSWORD

# ── Reuse an existing Archive mount (e.g. Finder's) or make our own ──
we_mounted=""
archive_root=$(mount -t smbfs | sed -n 's|^//[^ ]*/[Aa]rchive on \(.*\) (smbfs.*|\1|p' | head -1)
if [ -z "$archive_root" ]; then
    mkdir -p "$OWN_MNT"
    mount_smbfs -N "$SHARE" "$OWN_MNT"
    we_mounted=1
    archive_root="$OWN_MNT"
    log "mounted $SHARE at $OWN_MNT"
else
    log "using existing mount at $archive_root"
fi
cleanup() {
    if [ -n "$we_mounted" ]; then
        umount "$OWN_MNT" 2>/dev/null || diskutil unmount "$OWN_MNT" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

export RESTIC_REPOSITORY="$archive_root/$REPO_SUBDIR"

# ── First run: initialize the encrypted repo ──
if ! restic cat config >/dev/null 2>&1; then
    log "initializing new restic repo at $RESTIC_REPOSITORY"
    restic init
fi

# ── Back up whatever exists (paths can be absent on a fresh machine) ──
paths=()
for p in "${BACKUP_PATHS[@]}"; do
    [ -e "$p" ] && paths+=("$p")
done
log "backing up: ${paths[*]}"
restic backup --retry-lock 20m --tag claude-code "${paths[@]}"

# ── Sundays on studio: thin old snapshots and reclaim space ──
if [ "$(hostname -s)" = "studio" ] && [ "$(date +%u)" -eq 7 ]; then
    log "weekly forget/prune"
    restic forget --retry-lock 20m \
        --keep-daily 14 --keep-weekly 8 --keep-monthly 36 --prune
fi

log "done"
