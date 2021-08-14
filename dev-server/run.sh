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
        ./Dockerfile.sh | docker build --tag sleepdiaryproject/dev-server -f - .
        ;;

    upgrade)
        curl --silent -D - https://github.com/tsl0922/ttyd/releases/latest \
            | sed -n -e 's/\r//' -e 's/^[Ll]ocation:.*\/tag\///p' \
            > ttyd-version.txt \
            || exit 2
        curl --silent -D - https://github.com/sindresorhus/github-markdown-css/releases/latest \
            | sed -n -e 's/\r//' -e 's/^[Ll]ocation:.*\/tag\///p' \
            > github-markdown-css-version.txt \
            || exit 2
        ;;

    *)
        exit 2
        ;;

esac
