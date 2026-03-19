#!/bin/bash

# Read JSON input
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
session_name=$(echo "$input" | jq -r '.session_name // empty')

# Get username and hostname
username=$(whoami)
hostname=$(hostname -s)

# ANSI color codes
reset="\033[0m"
bold="\033[1m"
blue="\033[34m"
cyan="\033[36m"
yellow="\033[33m"

# Determine user@host color: magenta for root, red for SSH, green for local
if [ "${UID:-$(id -u)}" -eq 0 ]; then
    user_color="\033[35m"   # magenta for root
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    user_color="\033[31m"   # red for SSH
else
    user_color="\033[32m"   # green for local
fi

# Collapse working directory (fishy style: abbreviate all but last component)
collapse_wd() {
    local wd="$1"
    # Replace home with ~
    if [[ "$wd" == "$HOME"* ]]; then
        wd="~${wd#$HOME}"
    fi

    # If path has multiple components, collapse all but the last
    if [[ "$wd" == */* ]]; then
        local IFS='/'
        local parts=($wd)
        local result=""

        for ((i=0; i<${#parts[@]}-1; i++)); do
            local part="${parts[$i]}"
            if [[ "$part" == .* ]] && [[ ${#part} -gt 1 ]]; then
                result+="${part:0:2}/"
            elif [[ -n "$part" ]]; then
                result+="${part:0:1}/"
            fi
        done
        result+="${parts[${#parts[@]}-1]}"
        echo "$result"
    else
        echo "$wd"
    fi
}

collapsed_wd=$(collapse_wd "$cwd")

# Get git branch and status (matching sefk theme symbols: % + * ~ ! ?)
git_info=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)

        git_status=""
        if echo "$status" | grep -q "^??"; then git_status+="%"; fi
        if echo "$status" | grep -q "^A"; then git_status+="+"; fi
        if echo "$status" | grep -q "^ M\|^M"; then git_status+="*"; fi
        if echo "$status" | grep -q "^R"; then git_status+="~"; fi
        if echo "$status" | grep -q "^ D\|^D"; then git_status+="!"; fi
        if echo "$status" | grep -q "^U"; then git_status+="?"; fi

        if [ -n "$git_status" ]; then
            git_info=" ${cyan}(${branch} ${git_status})${reset}"
        else
            git_info=" ${cyan}(${branch})${reset}"
        fi
    fi
fi

# Add session name if present
session_info=""
if [ -n "$session_name" ]; then
    session_info=" [${session_name}]"
fi

# Get tmux session name
tmux_prefix=""
if [ -n "$TMUX" ]; then
    tmux_session=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$tmux_session" ]; then
        tmux_prefix="${blue}[${tmux_session}]${reset} "
    fi
fi

# Build the statusline: user@host:path git_info session_info
# Matches sefk theme: green/red/magenta user@host, yellow bold path, cyan git
printf "%b${user_color}${bold}%s${reset}@${user_color}%s${reset}:${yellow}${bold}%s${reset}%b%s" \
    "$tmux_prefix" "$username" "$hostname" "$collapsed_wd" "$git_info" "$session_info"
