# Utilities used by Dockerfile.sh

APT_PACKAGES=

# Install an npm program we will use from the command-line
# `npm install --global` makes the specified package runnable,
# but hides its dependencies in a separate directory
install_npm_programs() {
    if echo "$@" | grep -q '[^ ]'
    then cat <<EOF
 \\
&& echo "Installing npm programs: $@" \\
&& npm install --production -g $@ \\
EOF
    fi
}

install_apt_packages() {
    if echo "$@" | grep -q '[^ ]'
    then cat <<EOF
 \\
&& apt-get update \\
&& apt-get install -y$APT_PACKAGES \\
&& apt-get clean \\
&& rm -rf /var/lib/apt/lists/* \\
EOF
    fi
}

footer() {
    cat <<EOF
 \\
&& npm cache clean --force \\
&& echo Install succeeded

ENTRYPOINT [ "/opt/sleepdiary/entrypoint.sh" ]
EOF
}
