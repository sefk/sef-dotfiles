export HISTCONTROL=ignoredups:erasedups
export PROMPT_COMMAND="$PROMPT_COMMAND${PROMPT_COMMAND+;}history -a;history -c;history -r"
export HISTSIZE=100000
export HISTFILESIZE=100000
shopt -s histappend
