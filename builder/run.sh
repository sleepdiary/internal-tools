#!/bin/sh
#
# Builds the container used by other projects

case "$1" in

    test)
      true
      ;;

    build)
        ./Dockerfile.sh > Dockerfile
        ;;

    build-local)
        ./Dockerfile.sh | docker build --tag sleepdiaryproject/builder -f - .
        ;;

    upgrade)
        curl --silent https://nodejs.org/dist/index.json \
            | sed -ne '/"version"/ { s/{"version":"v\([0-9]*\).*/\1/p ; q }' \
            > node-version.txt \
            || exit 2
        ;;

    *)
        exit 2
        ;;

esac
