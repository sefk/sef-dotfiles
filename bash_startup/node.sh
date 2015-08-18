export NVM_DIR=~/.nvm

if [ x`which brew` != x ]; then
    source $(brew --prefix nvm)/nvm.sh
else
    source $NVM_DIR/nvm.sh
fi
