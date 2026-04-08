#!/bin/sh
# Start a tmux session named after the current directory.
# Falls back to default numbering if the name is taken.

TMUX=/opt/homebrew/bin/tmux
name="${PWD##*/}"

if "$TMUX" has-session -t "$name" 2>/dev/null; then
    exec "$TMUX" new-session
else
    exec "$TMUX" new-session -s "$name"
fi
