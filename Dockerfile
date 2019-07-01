FROM alpine:3.10 as builder

ENV SSDEEP_VERSION=2.14.1 \
    MODSECURITY_VERSION=3.0.3 \
    MODSECURITY_NGINX_VERSION=1.0.0 \
    OWASP_VERSION=3.1.0 \
    NGINX_VERSION=1.16.0

LABEL maintainer="Hermann Rorschach <mr.hermann.rorschach@gmail.com>"

RUN apk add --no-cache \
    ca-certificates automake autoconf gcc g++ musl-dev libcurl openssl-dev \
    libpcrecpp libtool libxml2-dev yajl-dev lua5.2-dev pkgconf geoip-dev make \
    linux-headers pcre-dev curl-dev libmaxminddb-dev \
    && cp -l /usr/lib/liblua-5.2.so.0 /usr/lib/liblua-5.2.so

RUN wget https://github.com/ssdeep-project/ssdeep/releases/download/release-${SSDEEP_VERSION}/ssdeep-${SSDEEP_VERSION}.tar.gz \
    && tar xf ssdeep-${SSDEEP_VERSION}.tar.gz \
    && cd ssdeep-${SSDEEP_VERSION} \
    && ./configure && make -j $(nproc) && make install \
    && cd -

RUN wget https://github.com/SpiderLabs/ModSecurity/releases/download/v${MODSECURITY_VERSION}/modsecurity-v${MODSECURITY_VERSION}.tar.gz \
         https://github.com/SpiderLabs/ModSecurity/releases/download/v${MODSECURITY_VERSION}/modsecurity-v${MODSECURITY_VERSION}.tar.gz.sha256 \
    && sha256sum -c modsecurity-v${MODSECURITY_VERSION}.tar.gz.sha256 \
    && tar xf modsecurity-v${MODSECURITY_VERSION}.tar.gz \
    && cd modsecurity-v${MODSECURITY_VERSION} \
    && ./configure && make -j $(nproc) && make install \
    && cp -v modsecurity.conf-recommended unicode.mapping /usr/local/modsecurity/ \
    && cd - \
    && rm -rf /usr/local/lib/perl5

RUN wget https://github.com/SpiderLabs/ModSecurity-nginx/releases/download/v1.0.0/modsecurity-nginx-v${MODSECURITY_NGINX_VERSION}.tar.gz \
         https://github.com/SpiderLabs/ModSecurity-nginx/releases/download/v1.0.0/modsecurity-nginx-v${MODSECURITY_NGINX_VERSION}.tar.gz.sha256 \
    && sha256sum -c modsecurity-nginx-v${MODSECURITY_NGINX_VERSION}.tar.gz.sha256 \
    && tar xf modsecurity-nginx-v${MODSECURITY_NGINX_VERSION}.tar.gz \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar xf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
       --user=nobody \
       --group=nogroup \
       --with-pcre-jit \
       --with-file-aio \
       --with-threads \
       --with-http_addition_module \
       --with-http_auth_request_module \
       --with-http_flv_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_mp4_module \
       --with-http_random_index_module \
       --with-http_realip_module \
       --with-http_slice_module \
       --with-http_ssl_module \
       --with-http_sub_module \
       --with-http_stub_status_module \
       --with-http_v2_module \
       --with-http_secure_link_module \
       --with-stream \
       --with-stream_realip_module \
       --add-module=/modsecurity-nginx-v${MODSECURITY_NGINX_VERSION} \
       --with-http_dav_module \
    && make -j $(nproc) build modules install \
    && cd -

RUN wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${OWASP_VERSION}.tar.gz \
    && tar xf v${OWASP_VERSION}.tar.gz \
    && mv owasp-modsecurity-crs-${OWASP_VERSION} /usr/local/owasp-modsecurity-crs

RUN find /usr/local -name '.so' -or -name '*.a' -exec strip {} \;


FROM alpine:3.10

RUN apk add --no-cache ca-certificates libcurl libpcrecpp libxml2 yajl lua5.2 geoip pcre curl libmaxminddb \
    && cp -l /usr/lib/liblua-5.2.so.0 /usr/lib/liblua-5.2.so

COPY --from=builder /usr/local /usr/local
COPY nginx/ /etc/nginx/

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["/etc/nginx/run.sh"]
