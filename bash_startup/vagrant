#!/bin/bash

# export VAGRANT_MOUNT_BASE="/Users/sef/src/edx"

function vv {
    pushd $VAGRANT_MOUNT_BASE
    vagrant ssh -c "sudo su edxapp"
    popd
}

function vd {
    cd ~/src/edx
    vagrant up
    vagrant ssh
}

