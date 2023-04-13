FROM debian:11.6

MAINTAINER valkolaci

ENV NGINX_VERSION release-1.23.3
ENV NGINX_HEADERS_MORE_VERSION v0.34
ENV NGINX_FANCY_INDEX_VERSION v0.4.4
ENV NGINX_ECHO_VERSION v0.63
ENV NGINX_LDAP_COMMIT 83c059b73566c2ee9cbda920d91b66657cf120b7

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        git \
        gcc \
        make \
        libpcre3-dev \
        zlib1g-dev \
        libldap2-dev \
        libssl-dev \
        wget \
        libldap-2.4-2 && \
    mkdir /var/log/nginx && \
    mkdir /etc/nginx && \
    cd /tmp && \
    git clone https://github.com/openresty/headers-more-nginx-module.git && \
    cd /tmp/headers-more-nginx-module && \
    git checkout tags/${NGINX_HEADERS_MORE_VERSION} && \
    cd /tmp && \
    git clone https://github.com/aperezdc/ngx-fancyindex.git && \
    cd /tmp/ngx-fancyindex && \
    git checkout tags/${NGINX_FANCY_INDEX_VERSION} && \
    cd /tmp && \
    git clone https://github.com/openresty/echo-nginx-module.git && \
    cd /tmp/echo-nginx-module && \
    git checkout tags/${NGINX_ECHO_VERSION} && \
    cd /tmp && \
    git clone https://github.com/kvspb/nginx-auth-ldap.git && \
    cd /tmp/nginx-auth-ldap && \
    git checkout ${NGINX_LDAP_COMMIT} && \
    cd /tmp && \
    git clone https://github.com/nginx/nginx.git && \
    cd /tmp/nginx && \
    git checkout tags/${NGINX_VERSION} && \
    ./auto/configure \
        --add-module=/tmp/headers-more-nginx-module \
        --add-module=/tmp/ngx-fancyindex \
        --add-module=/tmp/echo-nginx-module \
        --add-module=/tmp/nginx-auth-ldap \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-pcre \
        --with-debug \
        --conf-path=/etc/nginx/nginx.conf \ 
        --sbin-path=/usr/sbin/nginx \ 
        --pid-path=/var/log/nginx/nginx.pid \ 
        --error-log-path=/var/log/nginx/error.log \ 
        --http-log-path=/var/log/nginx/access.log && \ 
    make install && \
    apt-get purge -y \
        git \
        gcc \
        make \
        libpcre3-dev \
        zlib1g-dev \
        libldap2-dev \
        libssl-dev \
        wget && \
    apt-get autoremove -y && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/src/* && \
    rm -rf /tmp/* && \
    rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/man/* && \
    rm -rf /usr/share/locale/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
