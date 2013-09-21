
function gitr() {
  git for-each-ref --format="%(committerdate:short): %(refname)" --sort=committerdate refs/remotes/$1;
}

# There are two forms here, which one you want depends on your version of git. Try both and see:
alias gitd='git for-each-ref --format="%(committerdate:short): %(refname)" --sort=committerdate refs/heads/'  # old form
# aliae gitd='git for-each-ref --format="%(committerdate:shortdate): %(refname)" --sort=committerdate refs/heads/' # new form

function pyclean() {
    echo -ne "cleaning "
    find . -name \*.pyc | wc -l
    find . -name \*.pyc -print0 | xargs -0 rm
}
