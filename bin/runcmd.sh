#!/bin/bash

# Helper/wrapper script to run any command in the crontab env. This script will
# ensure user profile script is loaded and to log any command output into log
# files. It also ensure not to print anything to STDOUT to avoid crontab system
# mail alert.
#
# NOTE: be sure to pass in absolute path of the command to be run so it can be
# found.
#
# Usage:
#  ./runcmd.sh find $HOME/crontab/test.sh  # Simple use case
#  LOG_NAME=mytest ./runcmd.sh $HOME/crontab/test.sh # Change the log name to
#  something specific
#

# Options
DIR=~
CMD="$@"
CMD_NAME=`basename $1`
LOG_NAME=${LOG_NAME:=$CMD_NAME}
LOG="$DIR/logs/$LOG_NAME.log.`date +%Y%m%d`"

# Ensure logs dir exists
if [[ ! -e $DIR/logs ]]; then
    mkdir -p $DIR/logs
fi

# Run cron command
source $HOME/.bash_profile
echo "`date` Started cron cmd=$CMD, logname=$LOG_NAME" 2>&1 >> $LOG
$CMD 2>&1 >> $LOG
echo "`date` Cron cmd is done." 2>&1 >> $LOG
