#!/bin/sh

for DIR in /app/*
do
    if [ -x "$DIR/bin/run.sh" ]
    then

        LINE="***   Rebuilding ${DIR#/app/}   ***"
        printf '\033[1m\n'
        echo "$LINE" | sed -e 's/./*/g';
        echo "$LINE"
        echo "$LINE" | sed -e 's/./*/g';
        printf '\033[0m\n'

        cd "$DIR" || exit 2

        echo "Building..."
        "./bin/run.sh" build --force
        case "$?" in
            0) printf '\033[1;32mSuccess!\033[0m\n\n' ;;
            1) printf '\033[1;33mNon-fatal errors occurred!\033[0m\n\n' ;;
            *) printf '\033[1;31mFailed!\033[0m\n\n' ;;
        esac

        echo "Testing..."
        "./bin/run.sh" test  --force
        case "$?" in
            0) printf '\033[1;32mSuccess!\033[0m\n\n' ;;
            1) printf '\033[1;33mNon-fatal errors occurred!\033[0m\n\n' ;;
            *) printf '\033[1;31mFailed!\033[0m\n\n' ;;
        esac

    fi
done
