#!/bin/sh
#
# Builds the container used by other projects

SUBDIRECTORIES=builder

cmd_test() {
    for DIR in $SUBDIRECTORIES
    do "$DIR/run.sh" cmd_test || exit 2
    done
}
cmd_build() {
    for DIR in $SUBDIRECTORIES
    do "$DIR/run.sh" cmd_build || exit 2
    done
}
cmd_upgrade() {
    for DIR in $SUBDIRECTORIES
    do "$DIR/run.sh" cmd_upgrade || exit 2
    done
}

. root/build-sleepdiary.sh
