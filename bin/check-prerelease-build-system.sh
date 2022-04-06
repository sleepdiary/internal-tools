#!/bin/sh
#
# Send a test commit to your origin repository,
# to check whether the pre-release build system breaks anything

set -e

QUIET=--quiet

BRANCH="update-$( date +%Y-%m-%d )"

# If the GitHub Actions build fails, you may be able to replicate it locally by doing:
#docker pull ghcr.io/sleepdiary/builder:pre-release
#docker run --rm -v .:/app "ghcr.io/sleepdiary/builder:pre-release" test

if ! git -C "$DIR" diff --quiet
then
    echo "$DIR: please stash or commit your changes"
    exit 2
fi

CURRENT_BRANCH="$( git symbolic-ref --short HEAD )"

git fetch $QUIET safe-personal main
git checkout $QUIET "unsafe-canonical/$BRANCH"
sed -i -e 's/builder:latest/builder:pre-release/g' .github/workflows/main.yml
git commit $QUIET .github/workflows/main.yml -m "WIP: test the pre-release builder against this repo"
git push $QUIET origin HEAD:main
git fetch $QUIET safe-personal

sensible-browser "https://github.com/$( git config --get remote.origin.pushUrl | sed -e 's/.*:\([^/]*\).*/\1/' )/$( basename "$PWD" )/actions/"

echo git checkout $QUIET "$CURRENT_BRANCH"
git checkout $QUIET "$CURRENT_BRANCH"

echo "Next steps:"
echo "1. Check the current run succeeds (should have opened in a browser tab)"
echo "2. git push --force-with-lease=main:safe-personal/main origin unsafe-canonical/main:main"
