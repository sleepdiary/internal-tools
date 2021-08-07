#!/bin/sh

. ../utils/Dockerfile-utils.sh

# Serve our various repo's from a single port:
APT_PACKAGES="$APT_PACKAGES nginx"

# Make some terminals available to developers:
APT_PACKAGES="$APT_PACKAGES tmux"

# Shell utilities:
APT_PACKAGES="$APT_PACKAGES bash-completion vim less"

TTYD_VERSION="$(cat ttyd-version.txt)"
TTYD_ARCH=x86_64

# Header:
cat <<EOF
FROM sleepdiaryproject/builder:latest
COPY root/opt/sleepdiary/package.json /opt/sleepdiary/package.json
RUN true \\
 \\
&& curl --silent -L -o /opt/sleepdiary/ttyd https://github.com/tsl0922/ttyd/releases/download/$TTYD_VERSION/ttyd.$TTYD_ARCH \\
&& chmod 755 /opt/sleepdiary/ttyd \\
&& mkdir -p /opt/sleepdiary/web-ttys \\
 \\
&& mkdir -p /var/log/nginx \\
&& touch /var/log/nginx/access.log /var/log/nginx/error.log \\
 \\
&& curl -L --silent https://github.com/sindresorhus/github-markdown-css/archive/refs/tags/v4.0.0.tar.gz | tar xz --transform='s/[^\/]*/\/github-markdown-css/' \\
 \\
&& cd /opt/sleepdiary \\
&& npm install --production . \\
&& npm cache clean --force \\
&& cd - > /dev/null \\
 \\
EOF

install_apt_packages $APT_PACKAGES
footer

# Footer:
cat <<EOF
COPY root /
RUN chmod 755 /opt/sleepdiary/*.sh
EXPOSE 8080-8090/tcp
EOF
