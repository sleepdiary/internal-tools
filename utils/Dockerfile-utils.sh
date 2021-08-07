# Utilities used by Dockerfile.sh

NPM_PACKAGES=
APT_PACKAGES=

install_npm_packages() {
    if echo "$@" | grep -q '[^ ]'
    then cat <<EOF
 \\
&& npm install --production -g $@ \\
&& npm cache clean --force \\
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
&& echo Install succeeded

ENTRYPOINT [ "/opt/sleepdiary/entrypoint.sh" ]
EOF
}
