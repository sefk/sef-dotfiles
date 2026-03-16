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
  echo "${(j:/:)pwd}"
}

function zsh_essembeh_gitstatus {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	GIT_STATUS=$(git_prompt_status)
	if [[ -n $GIT_STATUS ]]; then
		GIT_STATUS=" $GIT_STATUS"
	fi
	echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# by default, use green for user@host and no prefix
local ZSH_ESSEMBEH_COLOR="green"
local ZSH_ESSEMBEH_PREFIX=""
if [[ -n "$SSH_CONNECTION" ]]; then
	# display the source address if connected via ssh
	ZSH_ESSEMBEH_PREFIX="%{$fg[yellow]%}[$(echo $SSH_CONNECTION | awk '{print $1}')]%{$reset_color%} "
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
function _tmux_session_prefix {
	if [[ -n "$TMUX" ]]; then
		local s=$(tmux display-message -p '#S' 2>/dev/null)
		echo "%{$fg[blue]%}[${s}]%{$reset_color%} "
	fi
}
PROMPT='${ZSH_ESSEMBEH_PREFIX}$(_tmux_session_prefix)%{$fg[$ZSH_ESSEMBEH_COLOR]%}%n@%M%{$reset_color%}:%{%B$fg[yellow]%}$(_fishy_collapsed_wd)%{$reset_color%b%} $(zsh_essembeh_gitstatus)%(!.#.>) '
RPROMPT="%(?..%{$fg[red]%}%?%{$reset_color%})"
