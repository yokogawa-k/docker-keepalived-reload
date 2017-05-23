FROM debian:8

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      gcc \
      libc6-dev \
      libssl-dev \
      make \
      ipvsadm \
      colordiff \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

ARG KEEPALIVED_VERSION=1.2.13
ENV KEEPALIVED_DIR_NAME keepalived-${KEEPALIVED_VERSION}
ENV KEEPALIVED_DOWNLOAD_URL http://www.keepalived.org/software/${KEEPALIVED_DIR_NAME}.tar.gz

RUN set -ex \
    && curl -LO ${KEEPALIVED_DOWNLOAD_URL} \
    && tar xzf ${KEEPALIVED_DIR_NAME}.tar.gz \
    && cd ${KEEPALIVED_DIR_NAME} \
    && ./configure \
    && make \
    && make install

COPY ./conf/ /etc/keepalived/
COPY ./check.sh /

CMD ["/usr/local/sbin/keepalived", "-D", "-n", "-C", "-l", "-p", "/var/run/keepalived.pid", "-c", "/var/run/keepalived-checker.pid"]

