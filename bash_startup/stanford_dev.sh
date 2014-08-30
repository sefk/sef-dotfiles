#!/bin/bash

export rabbit='launchctl load ~/Library/LaunchAgents/homebrew.mxcl.rabbitmq.plist'

if [ -e ~/.rbenv ]; then
    PATH=$PATH:~/.rbenv/bin
    eval "$(rbenv init -)"
fi

function edxprod {
    multitail -s 2  \
        --config /usr/local/etc/multitail.conf \
        -CS apache \
        -l 'ssh app10.prod.class.stanford.edu "tail -f /logs/nginx/access.log"' \
        -l 'ssh app11.prod.class.stanford.edu "tail -f /logs/nginx/access.log"' \
        -l 'ssh app20.prod.class.stanford.edu "tail -f /logs/nginx/access.log"' \
        -l 'ssh app21.prod.class.stanford.edu "tail -f /logs/nginx/access.log"' \
        -CS apache_error \
        -l 'ssh app10.prod.class.stanford.edu "tail -f /logs/nginx/error.log"' \
        -l 'ssh app11.prod.class.stanford.edu "tail -f /logs/nginx/error.log"' \
        -l 'ssh app20.prod.class.stanford.edu "tail -f /logs/nginx/error.log"' \
        -l 'ssh app21.prod.class.stanford.edu "tail -f /logs/nginx/error.log"' 
}


function watchmongo {
    watch -n 10 'mongo edx --eval "printjson(db.currentOp());"'
}

# not sure if we still need to run postgres
# DYLD_FALLBACK_LIBRARY_PATH=/usr/local/PostgreSQL/9.3/lib:$DYLD_FALLBACK_LIBRARY_PATH

export ANSIBLE_NOCOWS=1

