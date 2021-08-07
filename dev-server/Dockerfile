FROM sleepdiaryproject/builder:latest
COPY root/opt/sleepdiary/package.json /opt/sleepdiary/package.json
RUN true \
 \
&& curl --silent -L -o /opt/sleepdiary/ttyd https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 \
&& chmod 755 /opt/sleepdiary/ttyd \
&& mkdir -p /opt/sleepdiary/web-ttys \
 \
&& mkdir -p /var/log/nginx \
&& touch /var/log/nginx/access.log /var/log/nginx/error.log \
 \
&& curl -L --silent https://github.com/sindresorhus/github-markdown-css/archive/refs/tags/v4.0.0.tar.gz | tar xz --transform='s/[^\/]*/\/github-markdown-css/' \
 \
&& cd /opt/sleepdiary \
&& npm install --production . \
&& npm cache clean --force \
&& cd - > /dev/null \
 \
 \
&& apt-get update \
&& apt-get install -y nginx tmux bash-completion vim less \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
 \
&& echo Install succeeded

ENTRYPOINT [ "/opt/sleepdiary/entrypoint.sh" ]
COPY root /
RUN chmod 755 /opt/sleepdiary/*.sh
EXPOSE 8080-8090/tcp
