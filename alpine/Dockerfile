FROM alpine

ENV VER_NGINX_DEVEL_KIT=0.3.1rc1
ENV VER_NGINX=1.14.2
ENV MISC_VERSION=0.32

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV NGINX_ROOT=/nginx
ENV WEB_DIR ${NGINX_ROOT}/html

RUN apk update
RUN apk add curl
RUN apk add make
RUN apk add g++
RUN apk add pcre-dev
RUN apk add openssl-dev
RUN apk add zlib-dev


RUN curl -fSL http://nginx.org/download/nginx-${VER_NGINX}.tar.gz -o nginx-${VER_NGINX}.tar.gz
RUN curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -o v${NGINX_DEVEL_KIT}.tar.gz
RUN curl -fSL https://github.com/openresty/set-misc-nginx-module/archive/v${MISC_VERSION}.tar.gz -o v${MISC_VERSION}.tar.gz

RUN tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -xzvf v${NGINX_DEVEL_KIT}.tar.gz && rm v${NGINX_DEVEL_KIT}.tar.gz
RUN tar -xzvf v${MISC_VERSION}.tar.gz && rm v${MISC_VERSION}.tar.gz

WORKDIR /nginx-${VER_NGINX}
RUN ./configure \
    --prefix=${NGINX_ROOT} \
    --with-http_ssl_module \
    --add-module=/${NGINX_DEVEL_KIT} \
    --add-module=/set-misc-nginx-module-${MISC_VERSION}

RUN make -j2
RUN make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/bin/

WORKDIR ${WEB_DIR}
EXPOSE 80
EXPOSE 443

RUN rm -rf /nginx-${VER_NGINX}
RUN rm -rf /${NGINX_DEVEL_KIT}
RUN rm -rf /v${MISC_VERSION}

CMD ["nginx", "-g", "daemon off;"]