# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Ghostty and herdr both render undercurl but advertise TERM=xterm-256color,
# which lacks the Smulx/Setulc caps nvim needs for red-squiggle spell/diagnostic
# highlighting. Promote to Ghostty's terminfo (which has them). herdr is a
# persistent server, so its panes inherit the *server's* TERM_PROGRAM, not the
# current client's — don't rely on TERM_PROGRAM; also accept HERDR_PANE_ID.
# Local only, and only when xterm-ghostty terminfo is actually installed
# (SSH targets may not have it).
if [ "$TERM" = "xterm-256color" ] && [ -z "$SSH_CONNECTION" ] \
   && { [ "$TERM_PROGRAM" = "ghostty" ] || [ -n "$HERDR_PANE_ID" ]; } \
   && infocmp xterm-ghostty >/dev/null 2>&1; then
    export TERM=xterm-ghostty
fi

# SSH agent: maintain a stable symlink so tmux sessions always find the agent
if [ -z "$TMUX" ] && [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/auth_sock" ]; then
    ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/auth_sock"
fi

# SEF (TOP) BEGIN

# Homebrew at the start to override system-supported things
if [[ `uname` == "Darwin" ]]; then
    [[ -d /opt/homebrew/sbin ]] && export PATH="/opt/homebrew/sbin:$PATH"
    [[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
    [[ -d $HOME/homebrew/sbin ]] && export PATH="$HOME/homebrew/sbin:$PATH"
    [[ -d $HOME/homebrew/bin ]] && export PATH="$HOME/homebrew/bin:$PATH"
fi
# OK for my stuff to be at the end of the path
[[ -d $HOME/bin ]] && export PATH="$PATH:$HOME/bin"

function test_and_source {
    if test -e "$1"; then
        source "$1"
    fi
}

if ! [[ -v HOSTNAME ]]; then
  export HOSTNAME=$(uname -n)
fi

# autojump is cool!
# also syntax highligting
# MAC OS X
if [[ `uname` == "Darwin" ]]; then
    if brew --version > /dev/null; then
        test_and_source $(brew --prefix)/etc/autojump.sh
        test_and_source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
fi

# LINUX
test_and_source /usr/share/autojump/autojump.sh
test_and_source /Users/sefk/.autojump/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u

# claude-local: Claude Code against local Ollama (bash gets this via the
# bash_startup loop; zsh doesn't source bash_startup, so pick it up here)
test_and_source ~/.bash_startup/claude.sh

# SEF (TOP) END

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="fishy"
ZSH_THEME="essembeh"
# My custom, basically a union of "fishy" and "essembeh"
ZSH_THEME="sefk"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  macos
  autojump
  python
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

if command -v nvim &>/dev/null; then
    export EDITOR=nvim
    alias vi=nvim
else
    export EDITOR=vim
fi

# less: preserve ANSI colors from piped input (e.g. `ag --color foo | less`)
export LESS=-R

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# SEF

set -o vi
bindkey -v
bindkey "^R" history-incremental-search-backward
bindkey "^[/" history-incremental-search-backward

# fzf: fuzzy history search (overrides ^R above), file/dir pickers (^T, Alt-C)
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

test_and_source ~/.bash_secret
test_and_source ~/.zsh_secret

# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST 

# This gives you better history searching
export HISTSIZE=1000000
export SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Create an alias for searching history
alias hg='history | grep'

# directory correction, prompts [ynae] 
setopt CORRECT
setopt CORRECT_ALL

PYTHON_BIN_PATH="$(python3 -m site --user-base)/bin"
PATH="$PATH:$PYTHON_BIN_PATH"
PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
PATH="$PATH:/usr/local/sbin"

# llmster / lms CLI (headless LM Studio)
PATH="$PATH:$HOME/.lmstudio/bin"

case $(uname -n) in
  *google.com) test_and_source ~/.zshrc-google;;
esac

if [[ `uname` == "Darwin" ]]; then
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
fi

PATH="${PATH:+${PATH}:}$HOME/perl5/bin"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

# Created by `pipx` on 2025-05-12 00:26:02
export PATH="$PATH:/Users/sefk/.local/bin"

# Link for direnv, automatic python virtual environments by directory
if command -v direnv >/dev/null 2>&1
then
    eval "$(direnv hook zsh)"
else
    echo "warning: consider installing direnv, skipping for now"
fi

# from here, Oct 2025
# https://marvelousmlops.substack.com/p/the-right-way-to-install-python-on
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv virtualenv-init -)";
fi

if [[ `uname` == "Darwin" ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# Added by Antigravity -- but it's rude to put first. end is fine.
export PATH="$PATH:/Users/sefk/.antigravity/antigravity/bin"

# best practice for installing things not as root. First I did this:
#         npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH

eval "$(zoxide init zsh)"

export GOG_ACCOUNT=sefklon@gmail.com

export PATH="$PATH:/opt/homebrew/opt/postgresql@18/bin"

# pnpm -- I modified to put at the end, thank you very much
export PNPM_HOME="/Users/sefk/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PATH:$PNPM_HOME" ;;
esac
# pnpm end

# the gh command doesn't play nicely with some escape sequences.
# https://github.com/cli/cli/issues/544
export GH_EDITOR=${EDITOR:-vim}

# Show or set the current tmux window's color (the single @wincolor setting;
# see ~/bin/tmux-border-color). No arg prints the current color; a value sets
# it (red green blue …, a #rrggbb, or `auto` to go back to the name-derived
# default). NB: Claude's /color can't be set from outside, so this changes the
# tmux side only — the reverse (Claude /color -> tmux) is handled by the
# statusline.
color() {
    if [ -z "$TMUX" ]; then
        echo "color: not in a tmux session" >&2
        return 1
    fi
    if [ $# -eq 0 ]; then
        local info; info=$(tmux-border-color get)
        echo "window color: ${info%% *} (${info##* })"
    else
        tmux-border-color set "$1"
    fi
}

# `brew upgrade` swaps the agentsview binary on disk but the launchd daemon
# keeps running the old one in memory (stale cost estimates etc). Kick it after
# any upgrade so it re-execs the new binary. Idempotent + near-instant.
brew() {
    command brew "$@"
    local rc=$?
    [[ "$1" == upgrade ]] && \
        launchctl kickstart -k "gui/$(id -u)/com.sefk.agentsview" 2>/dev/null
    return $rc
}

# Use Homebrew sqlite (readline-enabled, Tab completion) ahead of system sqlite
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sefk/.lmstudio/bin"
# End of LM Studio CLI section

alias jpp=json_pp

# studio-mosh: attach to studio's herdr over mosh (roaming + local echo, the
# tmux-over-mosh feel). herdr runs server-side on studio; mosh ships the TUI.
# The login shell (-lc) makes sure herdr is on PATH under mosh-server.
#
# Bare `herdr` attaches the *default* persistent session — the same one the
# `studio` alias (herdr --remote studio) reaches. `--session studio` would be a
# *separate* named session, so it'd never reattach to your real work.
alias studio="herdr --remote studio"
alias studio-mosh='mosh studio -- zsh -lc "herdr"'
