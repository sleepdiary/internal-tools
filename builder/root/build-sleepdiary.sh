# Utilities used by build scripts

if type cmd_run >/dev/null 2>&1
then HAS_RUN=1
else HAS_RUN=
fi

if type cmd_upgrade >/dev/null 2>&1
then HAS_UPGRADE=1
else HAS_UPGRADE=
fi

WARNED=
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

run_tests() {

    git log --oneline | grep -i 'fixup!\|squash\!' \
        && warning \
               "git log found squash/fixup commits" \
               "Please do: git rebase -i @{u}"
    git diff --check @{u} \
        || warning \
               "git diff --check found conflict markers or whitespace errors" \
               "Please fix the above issues"

    cmd_build
    RESULT="$?"
    if [ "$RESULT" != 0 ]
    then
        echo
        echo "Please fix the above build errors"
        return "$RESULT"
    fi

    cmd_test
    RESULT="$?"
    if [ "$RESULT" != 0 ]
    then
        echo
        echo "Please fix the above test errors"
        return "$RESULT"
    fi

}

help_message() {
    USAGE="test | build | merge-and-push"
    [ -n "$HAS_RUN"     ] && USAGE="$USAGE | run"
    [ -n "$HAS_UPGRADE" ] && USAGE="$USAGE | upgrade"
    USAGE_PORT=""     ; [ -n "NEEDS_PORT" ] && PORT_USAGE=" -p some_port:8080"
    cat <<EOF
Sleepdiary $SLEEPDIARY_NAME builder

Usage:
       docker run --rm -it -v /path/to/sleepdiary/$SLEEPDIARY_NAME:/app$PORT_USAGE sleepdiary/builder [ $USAGE ] [ --force ]

Options:
  --force        run the command even if everything is already up-to-date
  test           (default) build and run tests
  build          build without running tests
  merge-and-push build, run tests, and push to the upstream repository
EOF
    [ -n "$HAS_RUN"     ] && echo "  run            run a development environment"
    [ -n "$HAS_UPGRADE" ] && echo "  upgrade        upgrade all dependencies"
    cat <<EOF

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

        run_tests || exit $?

        if [ "$WARNED" != "" ]
        then
            echo
            echo "Please fix the above warnings,"
            echo "or just push the changes if you're sure."
            exit "$WARNED"
        fi

        git diff --exit-code || {
            git status
            echo "Please commit the above changes"
            exit 2
        }

        # Make sure we're going to push what we expected to:
        git diff @{u}
        echo
        git log --oneline --graph @{u}...HEAD

        echo
        echo "Please review the above changes, then do: git push"
        exit 0

        ;;

    automated-test)
        # called from e.g. GitHub Actions

        run_tests > test-output.txt 2>&1
        RESULT="$?"

        if [ "$RESULT" = 0 ]
        then
            if [ "$WARNED" = "" ]
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

        ;;

    build)
        cmd_build
        exit "$?"
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

        git merge --strategy-option=theirs --no-edit origin/main

        #
        # Run the build itself
        #

        cmd_build
        cmd_test

        #
        # Add/commit/push changes
        #

        git add .
        if git diff --quiet HEAD
        then echo "No changes to commit"
        else git commit -a -m "Build updates from main branch"
        fi
        git push

        ;;

    run)
        if [ -z "$HAS_RUN" ]
        then
            help_message
            exit 2
        else
            cmd_run
            exit "$?"
        fi
        ;;

    upgrade)
        if [ -z "$HAS_UPGRADE" ]
        then
            help_message
            exit 2
        else
            cmd_upgrade
            exit "$?"
        fi
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
