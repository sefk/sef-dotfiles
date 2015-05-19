#!/bin/bash

set -u
set -e

read -r -p "This will nuke and reload your midas db, are you sure [y/N] " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    set -x
    psql -c "drop database midas;"
    psql -c "create database midas;"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE midas to midas;"
    psql -c "ALTER SCHEMA public OWNER TO midas;"
    npm run migrate
    npm run init
    npm run demo
    psql midas -c "update midas_user set disabled='f';"
    psql midas -c "update midas_user set \"isAdmin\"='t' where username='alan@test.gov';"
    set +x
fi

