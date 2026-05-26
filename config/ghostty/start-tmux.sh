#!/bin/sh
# Start (or attach to) a tmux session named after the current directory.
# If that session already has an attached client (e.g. Cmd-N from a window
# already running tmux), skip tmux and drop straight to a plain shell.
# On detach, fall through to a login shell instead of closing the window,
# so you can ssh out without nesting tmux.

TMUX=/opt/homebrew/bin/tmux
name="${PWD##*/}"

if "$TMUX" has-session -t "=$name" 2>/dev/null; then
    attached=$("$TMUX" display-message -p -t "=$name" '#{session_attached}' 2>/dev/null)
    if [ "${attached:-0}" -gt 0 ]; then
        exec $SHELL -l
    fi
fi

"$TMUX" new-session -A -s "$name"
exec $SHELL -l
