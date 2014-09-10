if [ $(uname -s) == "Darwin" ]; then
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_67.jdk/Contents/Home/

    # recommended by IntelliJ IdeaVIM plugin
    defaults write -g ApplePressAndHoldEnabled 0
fi
