#!/bin/bash

DIR=~/logs
echo "Checking and removing logs in $DIR"
find $DIR -type f -mtime +31 -print -delete
echo "Done"
