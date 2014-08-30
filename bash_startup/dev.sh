function gg {
    if [[ "x$GIT_DIR" == "x" ]]; then
        echo "gg: not in git repo, staying put"
    else
        cd `dirname $GIT_DIR`
    fi
}

function keys {
    for i in sef-github-20120416 sef-personal-20120426; do
        if (ssh-add -l | grep $i > /dev/null); then
            echo "key found: $i"
        else
            ssh-add ~/.ssh/$i
        fi
    done
}

if [ -e /usr/local/bin/virtualenvwrapper.sh ]; then
    # virtualenvwrapper setup (feel free to change project directories)
    export WORKON_HOME=$HOME/.virtualenv
    export PROJECT_HOME=~/src
    export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
    export VIRTUALENVWRAPPER_VIRTUALENV=`which virtualenv`
    source /usr/local/bin/virtualenvwrapper.sh
fi

export GOPATH=$HOME/gocode
export PATH=$PATH:$GOPATH/bin

