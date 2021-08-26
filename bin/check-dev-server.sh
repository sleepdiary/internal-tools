#!/bin/sh
#
# Manually check the dev-server works
#
# Usage: $0 [ pre-release ] [ /path/to/sleepdiary ]

set -v
set -e

VERSION="${1:-latest}"
PATH_TO_SLEEPDIARY="$( readlink -f "${2:-$(dirname "$0")/../..}" )"

echo "Checking version '$VERSION'"

docker pull "docker.io/sleepdiaryproject/dev-server:$VERSION"

docker run --rm -v "$PATH_TO_SLEEPDIARY:/app" "sleepdiaryproject/dev-server:$VERSION" check
