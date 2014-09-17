# bash function to start up and shut down a SSH VPN
# Sef Kloninger, 2014
#
# Assumes that you've configured your ~/.ssh/config so that the "vpn"
# host has all the configuraiton you need to log in with, i.e. don't
# wedge into this script.  Consider a stanza like this:
#
#      host vpn
#          Hostname vpn.company.com
#          User username
#          ForwardAgent yes
#          IdentityFile ~/.ssh/sshkey.pem
#

function vpn {
    PORT=7777
    PIDFILE=~/.vpn_pid

    option=$1
    status=`netstat -antu -p tcp | grep 127.0.0.1.$PORT | wc -l `

    if [[ $# -eq 0 || $option == "status" ]]; then
        if [[ $status -gt 0 ]]; then
            echo "vpn open on port $PORT"
        else
            echo "no vpn found"
        fi
        return 0
    fi

    if [[ $option == "up" || $option == "start" ]]; then
        if [[ $status -gt 0 ]]; then
            echo "vpn already open on port $PORT"
            return 1
        fi
        ssh -D $PORT vpn -N &
        echo $! > $PIDFILE
        return 0
    fi

    if [[ $option == "down" || $option == "stop" || $option == "halt" ]]; then
        if [[ $status -eq 0 ]]; then
            echo "no vpn found"
            return 1
        fi
        if [[ ! -e $PIDFILE ]]; then
            echo "no pidfile found at $PIDFILE, bailing out"
            return 1
        fi
        kill `cat $PIDFILE`
        rm $PIDFILE
        return 0
    fi

    echo "usage: vpn {up|down|status}"
    return 1
}

