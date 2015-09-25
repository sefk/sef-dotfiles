export NVM_DIR=~/.nvm

if [ x`which brew` != x ] && [[ -e $(brew --prefix nvm)/nvm.sh ]]; then
    source $(brew --prefix nvm)/nvm.sh
else
    if [[ -e $NVM_DIR ]] && [[ -e $NVM_DIR/nvm.sh ]]; then
        source $NVM_DIR/nvm.sh
    fi
fi
