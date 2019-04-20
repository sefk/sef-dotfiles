# if we have a session (has-session returns 0 = OK) but not in the TMUX
# window (variable TMUX is empty) then warn

# only do this if an interactive shell.  Without this test this screws
# up things that use ssh as transport, eg. rsync over ssh
case $- in
*i*)
    tmux has-session 2>/dev/null
    if [[ $? -eq 0 && -z $TMUX  ]]; then
        echo
        echo "------------------------"
        echo "TMUX session(s) open, consider \"tmux attach\".  Listing:"
        tmx2 ls
        echo "------------------------"
    fi
;;
esac
