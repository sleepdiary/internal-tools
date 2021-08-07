#!/bin/sh
#
# example run.sh file
# copy/paste this into a project,
# and fill in the TODO items below

#!/bin/sh

do_build() {

    echo

    if [ -n "$FORCE" ]
    then make -j -B build
    else make -j    build
    fi

    RESULT="$?"

    case "$RESULT" in
        0) printf "\033[1;32mSuccess!\033[0m\n" ;;
        1) printf "\033[1;33Non-fatal errors occurred!\033[0m\n" ;;
        *) printf "\033[1;31mFailed!\033[0m\n" ;;
    esac

    return "$RESULT"

}

case "$1" in

    build)

        npm ci --silent
        do_build
        ;;

    test)

        WARNED=
        # TODO: add tests here
        exit $WARNED
        ;;

    serve)
        DIRECTORIES=src # TODO: add directories
        do_build
        inotifywait -r -q -e CLOSE_WRITE -m $DIRECTORIES | \
            while read REPLY
            do do_build
            done
        ;;

    *)
        exit 2
        ;;

esac
