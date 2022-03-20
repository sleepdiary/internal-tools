#!/bin/sh
#
# TODO: this currently works on "main", consider checking out "origin/main" instead

set -e

#DEBUG=echo
BRANCH="update-$( date +%Y-%m-%d )"

BROWSER_TABS=""

PATH_TO_SLEEPDIARY="$( readlink -f "$( dirname "$0" )/../.." )"

case "$1" in
    commit|push)
        true
        ;;
    *)
        echo "Usage: $0 <commit|push>"
        exit 2
        ;;
esac

ALL_GOOD=1
for DIR in "$PATH_TO_SLEEPDIARY"/*
do
    if [ -e "$DIR/bin/run.sh" ]
    then
        if [ "$( git -C "$DIR" symbolic-ref HEAD )" != refs/heads/main ]
        then
            echo "$DIR: please \`git checkout main\`"
            ALL_GOOD=
        fi
        if ! git -C "$DIR" diff --quiet
        then
            echo "$DIR: please stash or commit your changes"
            ALL_GOOD=
        fi
    fi
done
[ -z "$ALL_GOOD" ] && exit 2

do_commit() {
    DIR="$1"
    MESSAGE_FILE="$2"
    $DEBUG cd "$DIR"
    $DEBUG ./bin/run.sh upgrade
    if [ -z "$DEBUG" ]
    then
        git -C "$DIR" diff --quiet && return 0
    else
        echo "# Only if there are actually changes:"
    fi
    $DEBUG git commit -a --reuse-message="$( git -C "$DIR" log --format=%H -1 "$MESSAGE_FILE" )"
}
do_push() {
    DIR="$1"
    MESSAGE_FILE="$2"
    $DEBUG git -C "$DIR" push unsafe-canonical "HEAD:refs/heads/$BRANCH"
    BROWSER_TABS="$BROWSER_TABS https://github.com/$( git -C "$DIR" config --get remote.origin.url | sed -e 's/.*:\([^/]*\).*/\1/' )/$( basename "$DIR" )/pull/new/$BRANCH"
}

# Upgrade all repositories *except* internal-tools:
for DIR in "$PATH_TO_SLEEPDIARY"/*
do
	if [ -e "$DIR/bin/run.sh" -a "$DIR" != "$PATH_TO_SLEEPDIARY/internal-tools" ]
	then
            cat <<EOF

#
# $DIR
#
EOF
            "do_$1" "$DIR" package-lock.json
        fi
done

# upgrade internal-tools last (it will copy all the above upgrades):
cat <<EOF

#
# $PATH_TO_SLEEPDIARY/internal-tools
#
EOF
"do_$1" "$PATH_TO_SLEEPDIARY/internal-tools" builder/root/opt/sleepdiary/cache/core/package-lock.json

if [ "$1" = push ]
then

    $DEBUG sensible-browser $BROWSER_TABS

    echo "Now do:"
    echo "1. create PRs for each tab that just opened"
    echo "2. but only accept the PR for the internal-tools repository"
    echo "3. make a note of the issue numbers for the other PRs (you will need them later)"

fi
