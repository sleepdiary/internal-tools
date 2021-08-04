#!/bin/sh

if [ -x "$PWD/bin/entrypoint.sh" ]
then
    exec "$PWD/bin/entrypoint.sh" "$@"
else
    echo "Contents of $PWD:"
    ls -lha
    echo "Contents of $PWD/bin:"
    ls -lha bin
    echo "Please create a $PWD/bin/entrypoint.sh" >&2
    exit 2
fi
