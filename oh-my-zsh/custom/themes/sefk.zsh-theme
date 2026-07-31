# Custom theme that's a fork of essembeh theme with a few changes
# https://github.com/haad/oh-my-zsh/blob/master/themes/essembeh.zsh-theme
#   - single line
#   - quite simple by default: user@host:$PWD
#   - green for local shell as non root
#   - red for ssh shell as non root
#   - magenta for root sessions
#   - prefix with remote address for ssh shells
#   - prefix to detect docker containers or chroot
#   - git plugin to display current branch and status
#
# Main changes
#   - Prefer > to $
#   - stole fishy collapsed directories

# git plugin
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=") %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED="~"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_UNMERGED="?"


# Longest the final (non-squashed) path component is allowed to be before
# its middle gets truncated. Only the last component needs this: every
# earlier one is already squashed to a letter or two by the loop below.
typeset -g PROMPT_MAX_LAST_SEGMENT_LEN=${PROMPT_MAX_LAST_SEGMENT_LEN:-30}

function _truncate_middle {
  local s=$1 maxlen=$2 keep
  (( ${#s} <= maxlen )) && { echo "$s"; return }
  keep=$(( (maxlen - 1) / 2 ))
  echo "${s[1,$keep]}…${s[-$keep,-1]}"
}

function _fishy_collapsed_wd {
  local i pwd
  pwd=("${(s:/:)PWD/#$HOME/~}")
  if (( $#pwd > 1 )); then
    for i in {1..$(($#pwd-1))}; do
      if [[ "$pwd[$i]" = .* ]]; then
        pwd[$i]="${${pwd[$i]}[1,2]}"
      else
        pwd[$i]="${${pwd[$i]}[1]}"
      fi
    done
  fi
  pwd[-1]=$(_truncate_middle "$pwd[-1]" "$PROMPT_MAX_LAST_SEGMENT_LEN")
  echo "${(j:/:)pwd}"
}

function zsh_essembeh_gitstatus {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	local branch="${ref#refs/heads/}"
	GIT_STATUS=$(git_prompt_status)
	if [[ -n $GIT_STATUS ]]; then
		GIT_STATUS=" $GIT_STATUS"
	fi
	# _fishy_collapsed_wd only ever squashes segments *before* the last one
	# (down to a letter or two); the last segment is always shown in full
	# (or middle-truncated), never squashed. So comparing against the real
	# last segment tells us whether the branch name is actually visible in
	# the path as printed. If so, the branch name would just be repeating
	# what's already on screen (e.g. a git worktree dir named after its
	# branch) - collapse it to "()" instead of printing it twice.
	if [[ "$branch" == "${PWD:t}" ]]; then
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
	else
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX$branch$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}

# by default, use green for user@host and no prefix
local ZSH_ESSEMBEH_COLOR="green"
local ZSH_ESSEMBEH_PREFIX=""
if [[ -n "$SSH_CONNECTION" ]]; then
	# use red color to highlight a remote connection
	ZSH_ESSEMBEH_COLOR="red"
elif [[ -r /etc/debian_chroot ]]; then
	# prefix prompt in case of chroot
	ZSH_ESSEMBEH_PREFIX="%{$fg[yellow]%}[chroot:$(cat /etc/debian_chroot)]%{$reset_color%} "
elif [[ -r /.dockerenv ]]; then
	# also prefix prompt inside a docker container
	ZSH_ESSEMBEH_PREFIX="%{$fg[yellow]%}[docker]%{$reset_color%} "
fi
if [[ $UID = 0 ]]; then
	# always use magenta for root sessions, even in ssh
	ZSH_ESSEMBEH_COLOR="magenta"
fi
function _prompt_char {
	if [[ $UID == 0 ]]; then
		echo "#"
	elif [[ -n "$TMUX" ]]; then
		echo "%{$fg[green]%}>%{$reset_color%}"
	else
		echo "%{$fg[white]%}>%{$reset_color%}"
	fi
}

# Inline (not RPROMPT) so copy/paste of a terminal selection never grabs a
# right-side status code floating past the end of the visible line.
#
# Ctrl-Z stops the foreground job with SIGTSTP, which the shell reports as
# exit status 128+SIGTSTP (146 on macOS). That's not a real command failure —
# it's a suspend — and it's already conveyed by the jobs segment below, so
# suppress the red status bracket in exactly that case to avoid double
# (and misleading) signaling.
typeset -g _PROMPT_TSTP_STATUS=$(( 128 + $(kill -l TSTP 2>/dev/null || echo -1000) ))

function _prompt_precmd {
	_PROMPT_LAST_STATUS=$?

	local -a stopped running
	local j
	for j in "${(@v)jobstates}"; do
		case $j in
			suspended:*) stopped+=(1) ;;
			running:*)   running+=(1) ;;
		esac
	done

	_PROMPT_STATUS_SEG=""
	if [[ $_PROMPT_LAST_STATUS -ne 0 ]]; then
		if [[ $_PROMPT_LAST_STATUS -ne $_PROMPT_TSTP_STATUS || ${#stopped} -eq 0 ]]; then
			_PROMPT_STATUS_SEG="%{$fg[red]%}[$_PROMPT_LAST_STATUS]%{$reset_color%} "
		fi
	fi

	# Same color as the git branch segment (ZSH_THEME_GIT_PROMPT_PREFIX) so
	# the two read as one family of "shell state" info.
	_PROMPT_JOBS_SEG=""
	if (( ${#stopped} > 0 || ${#running} > 0 )); then
		local -a parts
		(( ${#stopped} > 0 )) && parts+=("${#stopped}z")
		(( ${#running} > 0 )) && parts+=("${#running}&")
		_PROMPT_JOBS_SEG="%{$fg[cyan]%}[${(j:,:)parts}]%{$reset_color%} "
	fi
}
precmd_functions+=(_prompt_precmd)

PROMPT='${ZSH_ESSEMBEH_PREFIX}%{$fg[$ZSH_ESSEMBEH_COLOR]%}%n@%M%{$reset_color%}:%{$fg[yellow]%}$(_fishy_collapsed_wd)%{$reset_color%} ${_PROMPT_STATUS_SEG}${_PROMPT_JOBS_SEG}$(zsh_essembeh_gitstatus)$(_prompt_char) '
