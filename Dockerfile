FROM vimagick/squid

COPY squid.conf /etc/squid/squid.conf
COPY ca-bundle.pem /etc/squid/ca-bundle.pem
COPY ca.pem /etc/squid/ca.pem
COPY squid.conf /etc/squid/squid.conf
COPY rewrite.db /etc/squid/rewrite.db

RUN /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db && \
    chown -R squid:squid /var/lib/ssl_db && \
    squid -z -f /etc/squid/squid.conf && \
    chown -R squid:squid /var/cache/squid && \
    rm /var/log/squid/cache.log && \
    apk add -U ca-certificates && \
    update-ca-certificates && \
    apk add perl && \
    rm -rf /var/cache/apk/*
