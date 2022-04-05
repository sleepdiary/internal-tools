#!/bin/sh
#
# Manually check the dev-server works
#
# Usage: $0 [ pre-release ] [ /path/to/sleepdiary ]

set -v
set -e

VERSION="${1:-pre-release}"
IMAGE="ghcr.io/sleepdiary/dev-server"
#IMAGE="docker.io/sleepdiaryproject/dev-server"
PATH_TO_SLEEPDIARY="$( readlink -f "${2:-$(dirname "$0")/../..}" )"

echo "Checking version '$VERSION'"

docker pull "$IMAGE:$VERSION"

docker run --rm "$IMAGE:$VERSION" check
