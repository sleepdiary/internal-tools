FROM node:16
RUN true \
&& mkdir -p /opt/sleepdiary \
 \
&& git clone --depth 1 https://github.com/wolfcw/libfaketime.git /tmp/libfaketime \
&& sed -i -e 's/\/usr\/local/\/tmp\/libfaketime/' /tmp/libfaketime/Makefile /tmp/libfaketime/*/Makefile \
&& make -j -C /tmp/libfaketime/src \
&& ln -s . /tmp/libfaketime/lib \
&& ln -s src /tmp/libfaketime/faketime \
 \
&& npm install --production -g jsdoc google-closure-compiler jasmine \
&& npm cache clean --force \
 \
&& apt-get update \
&& apt-get install -y inotify-tools \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
 \
&& echo Install succeeded

ENTRYPOINT [ "/opt/sleepdiary/entrypoint.sh" ]
COPY root /
RUN chmod 755 /opt/sleepdiary/*.sh /app/bin/run.sh
WORKDIR /app
