FROM ubuntu:14.04

ENV VER_NGINX_DEVEL_KIT=0.2.19
ENV VER_LUA_NGINX_MODULE=0.9.16
ENV VER_NGINX=1.7.10
ENV VER_LUAJIT=2.0.4    
ENV MISC_VERSION=0.31

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT=/nginx
ENV WEB_DIR ${NGINX_ROOT}/html

ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0

RUN apt-get -qq update
RUN apt-get -qq -y install wget


RUN apt-get -qq -y install make
RUN apt-get -qq -y install libpcre3
RUN apt-get -qq -y install libpcre3-dev
RUN apt-get -qq -y install zlib1g-dev
RUN apt-get -qq -y install libssl-dev
RUN apt-get -qq -y install gcc

RUN wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz
RUN wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz
RUN wget https://github.com/openresty/set-misc-nginx-module/archive/v${MISC_VERSION}.tar.gz

RUN tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz
RUN tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
RUN tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz
RUN tar -xzvf v${MISC_VERSION}.tar.gz && rm v${MISC_VERSION}.tar.gz

WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make
RUN make install

WORKDIR /nginx-${VER_NGINX}
RUN ./configure \
    --prefix=${NGINX_ROOT} \
    --with-http_ssl_module \
    --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" \
    --add-module=/${NGINX_DEVEL_KIT} \
    --add-module=/set-misc-nginx-module-${MISC_VERSION}\
    --add-module=/${LUA_NGINX_MODULE}

RUN make -j2
RUN make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx

WORKDIR ${WEB_DIR}
EXPOSE 80
EXPOSE 443

RUN rm -rf /nginx-${VER_NGINX}
RUN rm -rf /LuaJIT-${VER_LUAJIT}
RUN rm -rf /${NGINX_DEVEL_KIT}
RUN rm -rf /${LUA_NGINX_MODULE}
RUN rm -rf /v${MISC_VERSION}

CMD ["nginx", "-g", "daemon off;"]
