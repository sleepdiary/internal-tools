FROM node:16
RUN true \
   \
&& git clone --depth 1 https://github.com/wolfcw/libfaketime.git /tmp/libfaketime \
&& sed -i -e 's/\/usr\/local/\/tmp\/libfaketime/' /tmp/libfaketime/Makefile /tmp/libfaketime/*/Makefile \
&& make -j -C /tmp/libfaketime/src \
&& ln -s . /tmp/libfaketime/lib \
&& ln -s src /tmp/libfaketime/faketime \
   \
&& npm install -g jsdoc google-closure-compiler jasmine \
   \
&& apt-get update \
&& apt-get install -y inotify-tools \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
   \
&& npm cache clean --force \
&& echo Install succeeded
COPY root /
RUN chmod 755 /build-sleepdiary.sh /entrypoint.sh /app/bin/entrypoint.sh
WORKDIR /app
ENTRYPOINT [ "/entrypoint.sh" ]
