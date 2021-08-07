# Tests used by multiple repositories

WARNED=0
warning() {
    echo
    echo ^^^ "$1"
    shift
    for LINE in "$@"
    do echo "$LINE"
    done
    echo
    echo
    WARNED=1
}

generic_tests() {

    git log --oneline | grep -i 'fixup!\|squash\!' \
        && warning \
               "git log found squash/fixup commits" \
               "Please do: git rebase -i @{u}"
    git diff --check @{u} \
        || warning \
               "git diff --check found conflict markers or whitespace errors" \
               "Please fix the above issues"

    git diff @{u} | grep -i '^\+.*todo' \
        && warning \
               "git diff found 'TODO' messages" \
               "Please do these or remove the messages"

    git diff @{u} | grep -i '^\+[^\*]*\.\.\.' \
        && warning \
               "git diff found '...' messages" \
               "Please fill these in or remove the messages"

    git diff --exit-code || {
        git status
        warning "Please commit the above changes"
        exit 2
    }

    # Make sure we're going to push what we expected to:
    git diff @{u}
    echo
    git log --oneline --graph @{u}...HEAD
    echo
    echo "The changes above will be pushed by \`git push\`"

    return $WARNED

}
