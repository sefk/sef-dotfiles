#!/bin/bash
if [ ! -r "$1" ]; then
    echo "Please provide a valid file."
    exit 0
fi

file="$(<$1)"
length="${#file}"
speed=4
char_count=0

for (( i=0; i<$length; i++ )) do
    if [ $char_count -eq 0 ]; then
        char_count=$speed

        old_tty_setting=$(stty -g)
        stty -icanon -echo
        key=$(dd bs=1 count=1 2> /dev/null)
        stty "$old_tty_setting"
    fi
    ((char_count--))

    printf "${file:i:1}"
done

exit 0
