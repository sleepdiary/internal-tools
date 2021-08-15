#!/bin/sh

if ! [ -x "$PWD/bin/run.sh" ]
then
    cat <<EOF
Could not find $PWD/bin/run.sh

Please try one of the following:

a) rerun docker with \`-v /path/to/sleepdiary/app:/app\`
b) check the logs below for a bug to fix
c) raise an issue in the "internal tools" repository
   * link: https://github.com/sleepdiary/internal-tools/issues/new/choose
   * please include the command you used to run this program
   * please paste everything below into the bug report

EOF
    echo "Contents of $PWD:"
    ls -lha
    echo
    echo "Contents of $PWD/bin:"
    ls -lha bin
    echo
    exit 2
fi

if [ -e /opt/sleepdiary/utils.sh ]
then . /opt/sleepdiary/utils.sh
else printf "\033[1;31m/opt/sleepdiary/utils.sh not found - some checks bypassed.\033[0m\n"
fi

run_merge() {
    MERGE_OPTIONS=
    #MERGE_OPTIONS="$MERGE_OPTIONS --strategy-option=theirs" # NO!  These conflicts sometimes need manual intervention
    MERGE_OPTIONS="$MERGE_OPTIONS --no-edit"
    git merge $MERGE_OPTIONS "$@"
}

run_tests() {

    ./bin/run.sh build
    RESULT="$?"
    if [ "$RESULT" != 0 ]
    then
        echo
        echo "Please fix the above build errors"
        return "$RESULT"
    fi

    ./bin/run.sh test
    RESULT="$?"
    if [ "$RESULT" != 0 ]
    then
        echo
        echo "Please fix the above test errors"
        return "$RESULT"
    fi

    RESULT="0"

    if ! git diff --quiet
    then

        echo "Please stash your changes to run the merge tests"
        exit 1

    elif [ "$(cat .git/HEAD )" = "ref: refs/heads/main" ]
    then

        echo
        git checkout --quiet built
        run_merge --no-commit main
        RESULT="$?"
        [ "$RESULT" != 0 ] && git diff
        [ -e .git/MERGE_HEAD ] && git merge --abort
        git checkout --quiet main

    elif [ "$(cat .git/HEAD )" = "ref: refs/heads/built" ]
    then

        echo
        run_merge --no-commit main
        RESULT="$?"
        [ "$RESULT" != 0 ] && git diff
        [ -e .git/MERGE_HEAD ] && git merge --abort

    else

        echo "Please do \`git checkout main\` or \`git checkout built\` to run the merge tests"
        exit 1

    fi

    if [ "$RESULT" -ne 0 ]
    then
        cat <<EOF

These changes cannot be merged into the "built" branch.
Please try one of the following:

a) Edit your commits to avoid the merge conflict(s) above
b) push the commit anyway and tell the maintainers how to resolve the conflict manually
c) see https://github.com/sleepdiary/docs/development/minimising-planned-maintenance

EOF
        exit 2
    fi

}

help_message() {
    cat <<EOF
Sleepdiary repository builder

Usage:
       docker run --rm -it -v /path/to/sleepdiary/$SLEEPDIARY_NAME:/app sleepdiary/builder [ test | build | merge-and-push ] [ --force ]

Options:
  --force        run the command even if everything is already up-to-date
  test           (default) build and run tests
  build          build without running tests
  merge-and-push build, run tests, and push to the upstream repository

License: https://github.com/sleepdiary/$SLEEPDIARY_NAME/blob/main/LICENSE
EOF
}

FORCE=
for ARG
do
    shift
    case "$ARG" in
        -f|--f|--fo|--for|--forc|--force)
            FORCE=1
            ;;
        *)
            set -- "$@" "$ARG"
            ;;
    esac
done

case "$1" in

    test|"")

        FORCE=1

        if [ $( git rev-list --count HEAD..@{u}) != 0 ]
        then
            echo
            echo "Please pull or rebase upstream changes"
            exit 2
        fi

        run_tests
        RESULT="$?"
        if [ "$RESULT" -ne 0 ]
        then
                echo
                echo "Please fix the above issues,"
                echo "or just push the changes if you're sure."
                exit "$RESULT"
        fi
        exit 0

        ;;

    automated-test)
        # called from e.g. GitHub Actions

        run_tests 2>&1 | tee test-output.txt
        RESULT="$?"

        if [ "$RESULT" = 0 ]
        then
            if [ "$WARNED" = 0 ]
            then HEADER="👍 All tests pass"
            else HEADER="😐 The tests passed, but there were some warnings.
If you're sure this is correct, please merge \`built\` manually"
            fi
        else HEADER="💔 Please fix the tests below"
        fi

        # Based on https://github.community/t/set-output-truncates-multiline-strings/16852
        echo -n "::set-output name=comment::"
        echo "$HEADER
<details>
  <summary>Click to see the test output</summary>

$( sed -e 's/^/      /' test-output.txt )
</details>
" | sed \
        -e ':a;N;$!ba' \
        -e 's/%/%25/g' \
        -e 's/\r/%0D/g' -e 's/\n/%0A/g' \

        rm -f test-output.txt

        ;;

    build)
        exec ./bin/run.sh build
    ;;

    merge-and-push)

        set -v # verbose mode - print commands to stderr
        set -e # exit if any of the commands below return non-zero

        #
        # Check if there are changes to commit
        #

        if ! git diff --quiet
        then
            git diff
            echo "Please commit all changes"
            exit 2
        fi

        #
        # Check if there's anything to do
        #

        if ! git rev-list HEAD..origin/main | grep -q .
        then
            echo "'main' has already been merged - stopping"
            exit 0
        fi

        #
        # Merge changes from main
        #

        run_merge origin/main

        #
        # Run the build itself
        #

        set +e
        ./bin/run.sh build
        RESULT="$?"
        if [ "$RESULT" != 0 -a "$RESULT" != 1 ]
        then
            echo "Build failed"
            exit "$RESULT"
        fi

        # Add things now, so the test doesn't complain about unstaged changes:
        git add .

        ./bin/run.sh test
        RESULT="$?"
        if [ "$RESULT" != 0 -a "$RESULT" != 1 ]
        then
            echo "Build failed"
            exit "$RESULT"
        fi
        set -e

        #
        # Add/commit/push changes
        #

        if git diff --quiet HEAD
        then echo "No changes to commit"
        else git commit -a -m "Build updates from main branch"
        fi
        git push

        ;;

    h|help|-h|--h|--he|--hel|--help)
        help_message
        exit 0
        ;;

    *)
        help_message
        exit 2
        ;;

esac
