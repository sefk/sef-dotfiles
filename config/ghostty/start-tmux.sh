#!/bin/sh
# Start (or attach to) a tmux session named after the current directory.
# On detach, fall through to a login shell instead of closing the window,
# so you can ssh out without nesting tmux.

TMUX=/opt/homebrew/bin/tmux
name="${PWD##*/}"

"$TMUX" new-session -A -s "$name"
exec $SHELL -l
