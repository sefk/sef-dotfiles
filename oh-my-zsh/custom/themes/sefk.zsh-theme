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

# Normally every component but the last is squashed to a letter. When a branch
# is on the prompt the last one gets squashed too: an issue worktree directory
# (datatalk-861-write-coding) is its branch (issue-861-write-coding) with the
# project name in front, so spelling both out prints the same thing twice.
function _fishy_collapsed_wd {
  local i pwd squash_through
  pwd=("${(s:/:)PWD/#$HOME/~}")

  squash_through=$(( $#pwd - 1 ))
  [[ -n "$_PROMPT_BRANCH" ]] && squash_through=$#pwd

  if (( squash_through >= 1 )); then
    for i in {1..$squash_through}; do
      if [[ "$pwd[$i]" = .* ]]; then
        pwd[$i]="${${pwd[$i]}[1,2]}"
      else
        pwd[$i]="${${pwd[$i]}[1]}"
      fi
    done
  fi

  (( squash_through < $#pwd )) && \
    pwd[-1]=$(_truncate_middle "$pwd[-1]" "$PROMPT_MAX_LAST_SEGMENT_LEN")
  echo "${(j:/:)pwd}"
}

# The branch is the authoritative name now — _fishy_collapsed_wd squashes the
# directory out of the way whenever this segment prints, so there is nothing
# left to be redundant with.
function zsh_essembeh_gitstatus {
	[[ -n "$_PROMPT_BRANCH" ]] || return
	GIT_STATUS=$(git_prompt_status)
	if [[ -n $GIT_STATUS ]]; then
		GIT_STATUS=" $GIT_STATUS"
	fi
	echo "$ZSH_THEME_GIT_PROMPT_PREFIX$_PROMPT_BRANCH$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
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

	# Resolved once per prompt: the path segment and the git segment both need
	# to agree on whether a branch is being shown. Empty on a detached HEAD or
	# outside a repo, which is also what suppresses the git segment.
	_PROMPT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)

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
