#!/bin/bash

alias top10="(du -smx * | sort -k 1 -n -r | head -10 ) 2>/dev/null"
alias ll="ls -ltrh"
alias ssh="ssh -A"    # agent forwarding

alias gl="git log --oneline --decorate"

function vin {
    d="~/notes"
    pushd $d
    vi $1
    echo "---> that was just stored in $d"
    popd
}


function source_if_exists {
    if [ -f $1 ]; then
        source $1
    fi
}


# Class2Go Project
source_if_exists ~/src/class2go/tools/bash_aliases
source_if_exists ~/src/class2go/tools/bash_aliases.sh
source_if_exists ~/src/class2go/tools/bash_bug_reports
source_if_exists ~/src/class2go/tools/bash_bug_reports.sh
alias tests="REUSE_DB=1 ./manage.py test -v 2 --attr='!selenium'"
alias tests-full="./manage.py test -v 2 --attr='!selenium'"

function server() {
	local port="${1:-9000}"
	open "http://localhost:${port}/"
	python -m SimpleHTTPServer "$port"
}

function mdview() {
    if [ $# != 1 ]; then
        echo "usage: mdview file.md"
        return 1
    fi

    input=$1
    base=${input%.md}
    if [ $input == $base ]; then
        echo "error, \"${input}\" needs to have .md extension"
        return 1
    fi
    new=/tmp/${base}.html
    if [ -f $new ]; then
        read -p "Careful, \"${new}\" already exists, clobber? (y/n): " confirm
        if [[ ! $confirm =~ ^[Yy] ]]; then
            return 1
        fi
        rm $new
    fi
    markdown $input > $new
    open $new       # not portable, works on Mac
    return 0
}


function e2date() {
    perl -le 'print scalar localtime $ARGV[0]' $1
}

function lt() { ls -ltrsa "$@" | tail; }
function psgrep() { ps -er | grep -v grep | grep "$@" -i --color=auto; }
function ffind() { find . -iname "*$@*"; }

# from this thread on HN
# https://news.ycombinator.com/item?id=6309639
function bd () {
    OLDPWD=`pwd`
    NEWPWD=`echo $OLDPWD | sed 's|\(.*/'$1'[^/]*/\).*|\1|'`
    index=`echo $NEWPWD | awk '{ print index($1,"/'$1'"); }'`
    if [ $index -eq 0 ] ; then
        echo "No such occurrence."
    else
        echo $NEWPWD
        cd "$NEWPWD"
    fi
}

# no longer works
# export GREP_OPTIONS="--color=auto"
