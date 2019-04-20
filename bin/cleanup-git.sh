#!/bin/bash

for depot in $*; do
  echo "`date` $depot gc"
  cd $depot
  git gc 2>&1
done


