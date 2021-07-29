#!/bin/sh
#
# example entrypoint.sh file
# copy/paste this into a project,
# and fill in the TODO items below

SLEEPDIARY_NAME= # TODO: add the name of your repository here
#NEEDS_PORT=1 # TODO: delete or uncomment

cmd_build() {
    # TODO: commands to build the project
    if [ -n "$FORCE" ]
    then make -B build
    else make    build
    fi
}

cmd_test() {

    # TODO: tests that run after "build" succeeds

    # the "warning" command marks that a command failed, allow the build to finish, then fail:
    command_that_might_fail || warning "message"

    # the "return" command marks that a command failed and exits immediately:
    command_that_might_fail || return "$?"

}

cmd_run() {
    # TODO: run a development environment
    inotifywait -q -e CLOSE_WRITE -m $( find src/ -type f ) | \
        while read REPLY
        do make build
        done
}

cmd_upgrade() {
    # TODO: upgrade versions of all apps
}

. /bin/sleepdiary-entrypoint.sh
