#!/bin/bash
# Claude Code status line
# Line 1: user@host:path [session]
# Line 2: Model ▓▓▓░░░░░░░ pct% | duration | (branch status) | +add/-rm

input=$(cat)

# ── Extract JSON fields ──────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "?"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
session_name=$(echo "$input" | jq -r '.session_name // empty')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
lines_add=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_rm=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# ── Colors ────────────────────────────────────────────────────────
reset="\033[0m"
bold="\033[1m"
dim="\033[2m"
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
cyan="\033[36m"
blue="\033[34m"
magenta="\033[35m"

# ── user@host color (green local, red ssh, magenta root) ─────────
if [ "${UID:-$(id -u)}" -eq 0 ]; then
    uc="$magenta"
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    uc="$red"
else
    uc="$green"
fi

# ── Collapse working directory (fish-style) ──────────────────────
collapse_wd() {
    local wd="$1"
    [[ "$wd" == "$HOME"* ]] && wd="~${wd#$HOME}"
    if [[ "$wd" == */* ]]; then
        local IFS='/'
        local parts=($wd) result=""
        for ((i=0; i<${#parts[@]}-1; i++)); do
            local p="${parts[$i]}"
            if [[ "$p" == .* && ${#p} -gt 1 ]]; then result+="${p:0:2}/"
            elif [[ -n "$p" ]]; then result+="${p:0:1}/"
            fi
        done
        echo "${result}${parts[${#parts[@]}-1]}"
    else
        echo "$wd"
    fi
}
short_wd=$(collapse_wd "$cwd")

# ── Git info (green clean parens, red dirty braces — matches PS1) ─
git_info=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
          || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
        flags=""
        echo "$status" | grep -q "^??" && flags+="%"
        echo "$status" | grep -q "^A"  && flags+="+"
        echo "$status" | grep -q "^ M\|^M" && flags+="*"
        echo "$status" | grep -q "^R"  && flags+="~"
        echo "$status" | grep -q "^ D\|^D" && flags+="!"

        if [ -n "$flags" ]; then
            git_info=" ${red}{${branch} ${flags}}${reset}"
        else
            git_info=" ${green}(${branch})${reset}"
        fi
    fi
fi

# ── Tmux prefix ──────────────────────────────────────────────────
tmux_prefix=""
#if [ -n "$TMUX" ]; then
#    ts=$(tmux display-message -p '#S' 2>/dev/null)
#    [ -n "$ts" ] && tmux_prefix="${dim}${blue}[${ts}]${reset} "
#fi

# ── Session name ─────────────────────────────────────────────────
#session_info=""
#[ -n "$session_name" ] && session_info=" ${dim}[${session_name}]${reset}"

# ── Context bar ──────────────────────────────────────────────────
[ -z "$ctx_pct" ] || [ "$ctx_pct" = "null" ] && ctx_pct=0
bar_width=10
filled=$((ctx_pct * bar_width / 100))
empty=$((bar_width - filled))

if [ "$ctx_pct" -ge 90 ]; then bar_color="$red"
elif [ "$ctx_pct" -ge 70 ]; then bar_color="$yellow"
else bar_color="$green"
fi

bar=""
[ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
[ "$empty" -gt 0 ] && printf -v e "%${empty}s" && bar="${bar}${e// /░}"

# ── Lines changed ────────────────────────────────────────────────
lines_info="${green}+${lines_add}${reset}/${red}-${lines_rm}${reset}"

# ── Duration ─────────────────────────────────────────────────────
dur_sec=$((duration_ms / 1000))
dur_min=$((dur_sec / 60))
dur_hr=$((dur_min / 60))
if [ "$dur_hr" -gt 0 ]; then
    dur_fmt="${dur_hr}h$((dur_min % 60))m"
elif [ "$dur_min" -gt 0 ]; then
    dur_fmt="${dur_min}m$((dur_sec % 60))s"
else
    dur_fmt="${dur_sec}s"
fi

# ── Rate limit (if available) ────────────────────────────────────
rate_info=""
#if [ -n "$rate_5h" ]; then
#    rate_pct=$(printf '%.0f' "$rate_5h")
#    if [ "$rate_pct" -ge 80 ]; then rate_c="$red"
#    elif [ "$rate_pct" -ge 50 ]; then rate_c="$yellow"
#    else rate_c="$dim"
#    fi
#    rate_info=" ${dim}|${reset} ${rate_c}5h:${rate_pct}%%${reset}"
#fi

# ── Line 1: identity + location ───────────────────────────────────
printf "%b${uc}%s${reset}@${uc}%s${reset}:${yellow}%s${reset}\n" \
    "$tmux_prefix" "$(whoami)" "$(hostname -s)" "$short_wd"

# ── Line 2: model + context bar + duration + git + lines ─────────
printf "${cyan}${bold}%s${reset} %b%b${reset} %s%% ${dim}|${reset} %s ${dim}|${reset}%b %b\n" \
    "$model" "$bar_color" "$bar" "$ctx_pct" "$dur_fmt" "$git_info" "$lines_info"
