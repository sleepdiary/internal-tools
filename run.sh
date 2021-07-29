#!/bin/sh
#
# Runner used by GitHub Actions

cmd_test() {
    true
}
cmd_build() {
    ./Dockerfile.sh > Dockerfile
    # to create an image locally: docker build --tag sleepdiaryproject/builder .
}
cmd_upgrade() {
    curl --silent https://nodejs.org/dist/index.json \
         | sed -ne '/"version"/ { s/{"version":"v\([0-9]*\).*/\1/p ; q }' \
         > node-version.txt \
         || exit 2
}

. root/build-sleepdiary.sh
