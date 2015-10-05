export P4EDITOR=vim

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
       . /etc/bash_completion
    fi
fi

export PATH=$PATH:~/gbin
export AUTH_HOST="daphne.mtv"
