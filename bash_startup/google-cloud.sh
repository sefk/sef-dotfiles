#!/bin/bash

GOOGLE_CLOUD_DIR=${HOME}/src/google-cloud-sdk

if [ -e $GOOGLE_CLOUD_DIR ]; then
    # The next line updates PATH for the Google Cloud SDK.
    source $GOOGLE_CLOUD_DIR/path.bash.inc

    # The next line enables bash completion for gcloud.
    source $GOOGLE_CLOUD_DIR/completion.bash.inc
fi
