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

        # Cache NPM packages:
        PROGRAMS="$(cat npm_programs.txt)"
        rm -rf "root/opt/sleepdiary/cache"
        curl --silent \
             -H "Accept: application/vnd.github.v3+json" \
             https://api.github.com/orgs/sleepdiary/repos \
            | sed -ne 's/^    "name": "\(.*\)",/\1/p' \
            | while read REPO
        do
            echo "$REPO"
            DIR="root/opt/sleepdiary/cache/$REPO"
            mkdir -p "$DIR"
            GIT_DIR="$( dirname "$0" )/../../$REPO/.git"
            if [ -e "$GIT_DIR" ]
            then
                git --git-dir="$GIT_DIR" show main:package.json > "$DIR/package.json" || true
                git --git-dir="$GIT_DIR" show main:package-lock.json > "$DIR/package-lock.json" || true
            else
                curl --silent \
                     -o "$DIR/package.json" "https://raw.githubusercontent.com/sleepdiary/$REPO/main/package.json" \
                     -o "$DIR/package-lock.json" "https://raw.githubusercontent.com/sleepdiary/$REPO/main/package-lock.json"
            fi
            if [ -s "$DIR/package-lock.json" ]
            then
                cd "$DIR"
                npm rm $PROGRAMS
            else
                rm -rf "$DIR"
            fi
        done

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
