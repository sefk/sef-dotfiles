# vim:expandtab ts=4 sw=4 filetype=sh

if [ $(uname -s) == "Darwin" ]; then
    alias eject='hdiutil eject'
    alias mtr="sudo mtr --curses"   # by default Mac doesn't have 
    alias flushdns="dscacheutil -flushcache"
    alias top="top -o cpu"

    # vim aliases
    alias vi="vim"

    alias start=open
    alias goog="open http://www.google.com/"

    #    # if you homebrew mysql -- which I don't anymore
    #    function mysql-start {
    #        echo "launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.#plist"
    #        launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    #    }
    #
    #    function mysql-stop {
    #        echo "launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.#plist"
    #        launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    #    }

    # Mongo
    alias mongo-start="launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist"
    alias mongo-stop="launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist"

    # image procesing
    function image-info {
        echo "sips --getProperty pixelHeight --getProperty pixelWidth $@"
        sips --getProperty pixelHeight --getProperty pixelWidth $@
        echo "consider \"sips -Z 400\" or similar"
    }

    # iterm hotkey shouldn't animate down
    defaults write com.googlecode.iterm2 HotkeyTermAnimationDuration -float 0.00001

    # Macs have insanely low FD limits
    # see: http://unix.stackexchange.com/questions/108174/how-to-persist-ulimit-settings-in-osx-mavericks
    ulimit -n 2048


    if [ -e /usr/local/bin/rmtrash ]; then
        alias trash="rmtrash"
        alias del="rmtrash"
    fi

    # nice little doohickey to provide unified interface to clipboard.
    # seen here: https://news.ycombinator.com/item?id=10143143
    function clip() {
        [ -t 0 ] && pbpaste || pbcopy 
    }

fi
