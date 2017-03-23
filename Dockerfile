FROM vimagick/squid
MAINTAINER nailgun <dbashkatov@gmail.com>

RUN /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db && \
    chown -R squid:squid /var/lib/ssl_db && \
    apk add -U ca-certificates && \
    update-ca-certificates && \
    apk add perl && \
    rm -rf /var/cache/apk/*

COPY ca-bundle.pem /etc/squid/ca-bundle.pem
COPY ca.pem /etc/squid/ca.pem

COPY squid.conf     /etc/squid/
COPY localnet.conf  /etc/squid/
COPY expire.conf    /etc/squid/
COPY custom.conf    /etc/squid/
COPY cache.conf.tpl /etc/squid/
COPY debug.conf     /etc/squid/
COPY rewrite.db     /etc/squid/
COPY entrypoint.sh  /

VOLUME /var/cache/squid

EXPOSE 3128 3131

ENTRYPOINT ["/entrypoint.sh"]
