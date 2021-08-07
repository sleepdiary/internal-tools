#!/bin/sh
#
# Builds the container used by other projects

SUBDIRECTORIES="builder dev-server"

case "$1" in

    test)
        for DIR in $SUBDIRECTORIES
        do
            cd "$DIR"
            "./run.sh" test || exit 2
            cd - > /dev/null
        done
        ;;

    build)
        for DIR in $SUBDIRECTORIES
        do
            cd "$DIR"
            "./run.sh" build || exit 2
            cd - > /dev/null
        done
        ;;

    upgrade)
        for DIR in $SUBDIRECTORIES
        do
            cd "$DIR"
            "./run.sh" upgrade || exit 2
            cd - > /dev/null
        done
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

        for DIR in $SUBDIRECTORIES
        do
            echo "Building $DIR"
            cd "$DIR"
            "./run.sh" build || exit 2
            "./run.sh" test  || exit 2
            cd - > /dev/null
        done

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

    *)
        exit 2
        ;;

esac
