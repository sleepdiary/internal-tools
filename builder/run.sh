#!/bin/sh
#
# Builds the container used by other projects

set -e

case "$1" in

    test)
      true
      ;;

    build)
        ./Dockerfile.sh > Dockerfile
        ;;

    build-local)
        DOCKERFILE="$( ./Dockerfile.sh )"
        RESULT="$?"
        [ "$RESULT" = 0 ] || exit "$RESULT"
        echo "$DOCKERFILE" | docker build --tag sleepdiaryproject/builder -f - .
        ;;

    upgrade)

        # Update Node itself:
        curl --silent https://nodejs.org/dist/index.json \
            | sed -ne '/"version"/ { s/{"version":"v\([0-9]*\).*/\1/p ; q }' \
            > node-version.txt \
            || exit 2
        ;;

    *)
        exit 2
        ;;

esac
