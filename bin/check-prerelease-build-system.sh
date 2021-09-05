#!/bin/sh
#
# Send a test commit to your origin repository,
# to check whether the pre-release build system breaks anything

set -e

QUIET=--quiet

# If the GitHub Actions build fails, you may be able to replicate it locally by doing:
#docker pull ghcr.io/sleepdiary/builder:pre-release
#docker run --rm -v .:/app "ghcr.io/sleepdiary/builder:pre-release" test

sed -i -e 's/builder:latest/builder:pre-release/g' .github/workflows/main.yml
git commit $QUIET .github/workflows/main.yml -m "WIP: test the pre-release builder against this repo"
sed -i -e 's/builder:pre-release/builder:latest/g' .github/workflows/main.yml
git reset $QUIET HEAD^
git push $QUIET origin HEAD@{1}:main

sensible-browser "https://github.com/$( git config --get remote.origin.pushUrl | sed -e 's/.*:\([^/]*\).*/\1/' )/$( basename "$PWD" )/actions/"

echo "Next steps:"
echo "2. Check the current run succeeds (should have opened in a Firefox tab)"
echo "3. git push --force-with-lease=HEAD@{1} origin HEAD:main"
