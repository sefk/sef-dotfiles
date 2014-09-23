if [ $(uname -s) == "Darwin" ]; then
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_67.jdk/Contents/Home/

    # recommended by IntelliJ IdeaVIM plugin
    defaults write -g ApplePressAndHoldEnabled 0
fi


sineload () {
    emit () {
        echo "$1"
        echo "$1" | nc localhost 2878
    }
    while [ 1 ]; do
        d=`date +%s`
        s=`echo "s($d*3.14/240)"|bc -l`
        emit "test.sine $s host=localhost"
        sleep 1
    done
}
