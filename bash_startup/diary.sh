function vitoday {

    loc=~/diary
    today=`date +"%Y-%m-%d"`
    extension=.txt
    editor=vi

    function test_and_link () {
        cand=$1
        echo "testing $cand"
        if [[ -d $cand ]]; then
            echo "creating $loc as symlink to $cand"
            ln -s "$cand" "$loc"
            return 0
        fi
        return 1
    }
    if [[ ! -e $loc ]]; then
        test_and_link ~/Google\ Drive/Personal/diary
        if [[ $? -ne 0 ]]; then
            test_and_link ~/Dropbox/Personal/diary
            if [[ $? -ne 0 ]]; then
                echo "creating $loc" && mkdir $loc
            fi
        fi
    fi

    diary_file=${loc}/${today}${extension}
    echo "editing $diary_file"
    $editor $diary_file
}

alias diary=vitoday
