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

# Repair this shell's connection to a working ssh-agent without restarting tmux.
# `find-ssh-agent` calls the script in ~/bin and evals the export it prints so the
# new SSH_AUTH_SOCK lands in this shell. See `command find-ssh-agent --help`.
function find-ssh-agent {
    local out
    out=$(command find-ssh-agent "$@") || return $?
    eval "$out"
}

# On shell startup, check whether SSH_AUTH_SOCK is actually reachable and
# repair it via find-ssh-agent if not. Never blocks startup -- any failure
# (missing tool, no working agent found) just prints a short warning.
if command -v find-ssh-agent >/dev/null 2>&1; then
    _ssh_agent_ok=0
    if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        if command -v timeout >/dev/null 2>&1; then
            SSH_AUTH_SOCK="$SSH_AUTH_SOCK" timeout 2 ssh-add -l >/dev/null 2>&1
        else
            SSH_AUTH_SOCK="$SSH_AUTH_SOCK" perl -e 'alarm 2; exec @ARGV' ssh-add -l >/dev/null 2>&1
        fi
        rc=$?
        [ "$rc" -eq 0 ] || [ "$rc" -eq 1 ] && _ssh_agent_ok=1
    fi
    if [ "$_ssh_agent_ok" -eq 0 ]; then
        find-ssh-agent >/dev/null 2>&1 || echo "warning: can't find/attach to ssh agent" >&2
    fi
    unset _ssh_agent_ok rc
fi

