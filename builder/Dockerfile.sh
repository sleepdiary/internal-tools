#!/bin/sh

set -e

. ../utils/Dockerfile-utils.sh

# Node releases: https://nodejs.org/en/about/releases/
# This should normally be the Active LTS release,
# or optionally the latest Current release,
# if that release will become an Active LTS in future.
NODE_VERSION="$(cat node-version.txt)"

NPM_PROGRAMS="$(cat npm_programs.txt)"

# Several repositories use inotify to automatically rebuild themselves:
APT_PACKAGES="$APT_PACKAGES inotify-tools"

# Header:
cat <<EOF
FROM node:$NODE_VERSION
COPY root/opt/sleepdiary/cache/ /opt/sleepdiary/cache/
RUN true \\
&& mkdir -p /opt/sleepdiary/bin \\
&& echo PATH="/opt/sleepdiary/bin:\$PATH" > /etc/profile.d/fix_path.sh \\
EOF

# JSDoc timestamps all documents.  To generate a repeatable build, we need a fake timestamp.
# We use libfaketime, which I've only been able to make work when it's installed in /tmp:
if echo "$NPM_PROGRAMS" | grep -q jsdoc
then cat <<EOF
 \\
&& git clone --depth 1 https://github.com/wolfcw/libfaketime.git /tmp/libfaketime \\
&& sed -i -e 's/\/usr\/local/\/tmp\/libfaketime/' /tmp/libfaketime/Makefile /tmp/libfaketime/*/Makefile \\
&& make -j -C /tmp/libfaketime/src \\
&& ln -s . /tmp/libfaketime/lib \\
&& ln -s src /tmp/libfaketime/faketime \\
EOF
fi

# Cache an NPM library for use by our repositories
#
# NPM packages often assume they are in the `node_modules`
# sub-directory of a repository.  For example, @vue/cli-service
# looks for "../package.json" relative to the directory it's in
# (after resolving symlinks, so you can't even symlink to a
# node_modules directory stored elsewhere).
#
# NPM's `package-lock.json` tries to solve this by guaranteeing
# to install the same binary every time, but problems include:
# * everything breaks if NPM is offline
# * everything breaks if the package gets deleted
# * weird errors occur if a package is updated without changing the version number
# * NPM-specific solutions don't help with other package managers
# * Pulling from NPM is relatively slow on GitHub
#
# Our workaround is to install in a temporary directory,
# then have utils.sh copy that directory into place
cat <<EOF
 \\
&& for DIR in /opt/sleepdiary/cache/*/ ; do cd "\$DIR"; mkdir -p node_modules; npm ci || exit 2; done \\
EOF

install_npm_programs $NPM_PROGRAMS
install_apt_packages $APT_PACKAGES
footer

cat <<EOF
COPY root /
RUN chmod 755 /opt/sleepdiary/*.sh /opt/sleepdiary/bin/*
ENV PATH="/opt/sleepdiary/bin:${PATH}"
WORKDIR /app
EOF
