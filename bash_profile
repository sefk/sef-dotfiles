#!/bin/bash

export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:$PATH:~/bin

set -o vi
export EDITOR=/usr/bin/vim

function test_and_source {
    if [ -e $1 ]; then
        . $1
    fi
}

test_and_source ~/.bash_alias
test_and_source ~/.bash_secret

# Prompt handling -- start with basic green, and then if we can do something 
# fancier (ie in bash_prompt) use that instead.
export PS1="\[\e[32;1m\]\u@\h:\W> \[\e[0m\]"
test_and_source ~/.bash_commandprompt

test_and_source ~/.django_bash_completion
test_and_source /usr/local/etc/bash_completion

# Make directory listings perty
# this is useful for getting the lscolors stuff right: http://geoff.greer.fm/lscolors/
LSOPTIONS="-FC"
OS=`uname`
if [ x"$OS" == x"Darwin" ]; then LSOPTIONS=$LSOPTIONS" -G"; fi
if [ x"$OS" == x"Linux" ]; then LSOPTIONS=$LSOPTIONS" --color"; fi
alias ls="ls $LSOPTIONS"

export CLICOLOR='true'
export LSCOLORS="excxfxdxbxegedabagacad"
export LS_COLORS="di=34;40:ln=32;40:so=35;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"

# autojump is cool!
which brew 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
    if [ -f `brew --prefix`/etc/autojump.bash ]; then
        source `brew --prefix`/etc/autojump.bash
    fi
fi

# Java Dev
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
export MAVEN_OPTS='-Xmx1024m -XX:MaxPermSize=256m'

# Ruby Version Manager
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
# PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Need jodoc (and markdown, and nokogiri, and json) for generating cordova docs
export PATH=$PATH:~/src/joDoc

# Setup Amazon EC2 Command-Line Tools
# PEM=(~/.ec2/*.pem)
# if [ -e ${PEM[0]} ]; then
#    export EC2_HOME=~/.ec2
#    export PATH=$PATH:$EC2_HOME/bin
#    export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
#    export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
#    export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
#    export EC2_REGION='us-west-2'
#fi

export PATH=$PATH:/usr/local/bin/aws

export GPG_TTY=`tty`

# Display host and title in menu bar
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
        PROMPT_COMMAND=${PROMPT_COMMAND}${PROMPT_COMMAND+;}'echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        use_color=true
    ;;
    screen)
        PROMPT_COMMAND=${PROMPT_COMMAND}${PROMPT_COMMAND+;}' echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        use_color=true
        ;;
esac

export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
# export GIT_PS1_SHOWUPSTREAM="auto"
# export GIT_PS1_SHOWUPSTREAM="verbose"
