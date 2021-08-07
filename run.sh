#!/bin/sh
#
# Builds the container used by other projects

SUBDIRECTORIES="builder"

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

    *)
        exit 2
        ;;

esac
