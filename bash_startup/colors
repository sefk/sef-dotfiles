# seen on hacker news
# http://www.fizerkhan.com/blog/posts/What-I-learned-from-other-s-shell-scripts.html

# only do this if an interactive shell.  Without this test this screws
# up things that use ssh as transport, eg. rsync over ssh
case $- in
*i*)
    NORMAL=$(tput sgr0)
    # GREEN=$(tput setaf 2; tput bold)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    CYAN=$(tput setaf 4)
    PURPLE=$(tput setaf 5)

    function red() {
        echo -e "$RED$*$NORMAL"
    }

    function green() {
        echo -e "$GREEN$*$NORMAL"
    }

    function yellow() {
        echo -e "$YELLOW$*$NORMAL"
    }

    function cyan() {
        echo -e "$CYAN$*$NORMAL"
    }

    function purple() {
        echo -e "$PURPLE$*$NORMAL"
    }
;;
esac
