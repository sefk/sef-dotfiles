#!/bin/bash

export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

set -o vi
export EDITOR=vim
bind '"jk":"\e"'

function test_and_source {
    if [ -e "$1" ]; then
        source "$1"
    fi
}

# Prompt handling -- start with basic green, and then if we can do something 
# fancier (ie in bash_prompt) use that instead.
# export PS1="\[\e[32;1m\]\u@\h:\W> \[\e[0m\]"

# add brew location to the path on osx. Need to use brew in this file (hacky)
if [ `uname` == "Darwin" ]; then
    export PATH=~/homebrew/bin:$PATH
fi

# Make directory listings perty
# this is useful for getting the lscolors stuff right: http://geoff.greer.fm/lscolors/
LSOPTIONS="-FC"
OS=`uname`
if [ x"$OS" == x"Darwin" ]; then LSOPTIONS=$LSOPTIONS" -G"; fi
if [ x"$OS" == x"Linux" ]; then LSOPTIONS=$LSOPTIONS" --color"; fi
alias ls="ls $LSOPTIONS"

export CLICOLOR='true'
# export LSCOLORS="excxfxdxbxegedabagacad"
# export LS_COLORS="di=34;40:ln=32;40:so=35;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"

# autojump is cool!
# MAC OS X
which brew 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
    test_and_source `brew --prefix`/etc/autojump.sh
    test_and_source `brew --prefix`/etc/autojump.bash
fi
# LINUX
[ -e /usr/share/autojump/autojump.sh ] && . /usr/share/autojump/autojump.sh

# Java Dev
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
export MAVEN_OPTS='-Xmx1024m -XX:MaxPermSize=256m'

# Ruby Version Manager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Need jodoc (and markdown, and nokogiri, and json) for generating cordova docs
export PATH=$PATH:~/src/joDoc

export GPG_TTY=`tty`

# export GIT_PS1_SHOWUNTRACKEDFILES=1
# export GIT_PS1_SHOWDIRTYSTATE=1
# export GIT_PS1_SHOWSTASHSTATE=1
# export GIT_PS1_SHOWUPSTREAM="auto"
# export GIT_PS1_SHOWUPSTREAM="verbose"

# Now source everything else we need 
# put after prodaccess because it's up on a shared drive now
for dir in `/bin/ls -1ad ~/bash_startup ~/.bash_startup 2>/dev/null`; do
    for scr in `cd $dir; /bin/ls -1 | grep -v README | grep -v '_skip' | sort`; do
        test_and_source $dir/$scr
    done
done

ssh_sock=~/.ssh/ssh_auth_sock
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $ssh_sock ]; then
    rm -f $ssh_sock
    ln -sf $SSH_AUTH_SOCK $ssh_sock
    export SSH_AUTH_SOCK=$ssh_sock
fi

test_and_source /usr/local/etc/bash_completion

