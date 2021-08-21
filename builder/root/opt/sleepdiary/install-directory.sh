#!/bin/sh
#
# Usage: .../install-directory.sh "$SOURCE" "$DEST"
#
# Copies hardlinks if possible, else copies properly.
# Only useful for packages that misbehave when symlinked.

SOURCE="$1"
DEST="$2"

stat -c "%d" "$SOURCE" "$DEST" | {
    read SOURCE_FS
    read DEST_FS
    if [ "$SOURCE_FS" = "$DEST_FS" ]
    then cp -al "$SOURCE" "$DEST" # on the same filesystem
    else cp -a  "$SOURCE" "$DEST" # on another filesystem
    fi
}
