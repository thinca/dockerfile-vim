FROM alpine:edge AS iconv

RUN apk add --no-cache g++ make
RUN wget --quiet --output-document - http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz | \
        tar -xz --strip-components=1
RUN ./configure
RUN make -j$(nproc)
RUN make install


FROM alpine:edge AS base

ARG VIM_ENABLE_ALL=""
ARG VIM_ENABLE_GUI="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_SOUND="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PERL="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PYTHON="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PYTHON3="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_RUBY="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_LUA="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_TCL="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_MZSCHEME="${VIM_ENABLE_ALL}"
ARG LUA_VERSION="jit"
ARG PYTHON3_VERSION=""

RUN { [ -z "${VIM_ENABLE_MZSCHEME}" ] || \
      echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories; } \
 && { [ -z "${VIM_ENABLE_PYTHON3}" -o "v${PYTHON3_VERSION}" != "v3.7" ] || \
      { echo "https://dl-cdn.alpinelinux.org/alpine/v3.10/main" >> /etc/apk/repositories; \
      PYTHON3_VERSION_DETAIL="~3.7"; }; } \
 && { [ -z "${VIM_ENABLE_PYTHON}" ] || \
      echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories; \
      echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories; \
      PYTHON3_VERSION_DETAIL="~3.9"; } \
 && apk add --no-cache \
        ncurses \
        acl \
        diffutils \
        gettext \
        ${VIM_ENABLE_GUI:+gtk+3.0 libxmu libxpm} \
        ${VIM_ENABLE_SOUND:+libcanberra} \
        ${VIM_ENABLE_PERL:+perl} \
        ${VIM_ENABLE_PYTHON:+python2} \
        ${VIM_ENABLE_PYTHON3:+python3${PYTHON3_VERSION_DETAIL}} \
        ${VIM_ENABLE_RUBY:+ruby libc6-compat} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}} \
        ${VIM_ENABLE_TCL:+tcl} \
        ${VIM_ENABLE_MZSCHEME:+racket}


FROM base AS prepare

RUN apk add \
        gcc \
        libc-dev \
        make \
        gettext-dev \
        ncurses-dev \
        acl-dev \
        ${VIM_ENABLE_GUI:+gtk+3.0-dev libxmu-dev libxpm-dev} \
        ${VIM_ENABLE_SOUND:+libcanberra-dev} \
        ${VIM_ENABLE_PERL:+perl-dev} \
        ${VIM_ENABLE_PYTHON:+python2-dev} \
        ${VIM_ENABLE_PYTHON3:+python3-dev} \
        ${VIM_ENABLE_RUBY:+ruby-dev} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}-dev} \
        ${VIM_ENABLE_TCL:+tcl-dev} \
        ${VIM_ENABLE_MZSCHEME:+racket-dev}
RUN [ -z "${VIM_ENABLE_MZSCHEME}" ] || raco pkg install --batch --auto cext-lib


FROM prepare AS build

ARG VIM_VERSION=master
ARG VIM_COMPILEDBY=""

RUN mkdir -p /usr/src/vim
RUN wget --quiet --output-document - \
        "https://github.com/vim/vim/archive/${VIM_VERSION}.tar.gz" | \
        tar xz --directory=/usr/src/vim --strip-components=1
WORKDIR /usr/src/vim
RUN [ -z "${VIM_ENABLE_LUA}" -o "${LUA_VERSION}" == 'jit' ] || { \
      ln -s "lua${LUA_VERSION}" "/usr/bin/lua"; \
      ln -s "lua${LUA_VERSION}/liblua.a" "/usr/lib/liblua${LUA_VERSION}.a"; }
RUN ./configure \
        --with-features=huge \
        ${VIM_COMPILEDBY:+--with-compiledby="${VIM_COMPILEDBY}"} \
        ${VIM_ENABLE_GUI:+--enable-gui=gtk3} \
        ${VIM_ENABLE_PERL:+--enable-perlinterp} \
        ${VIM_ENABLE_PYTHON:+--enable-pythoninterp} \
        ${VIM_ENABLE_PYTHON3:+--enable-python3interp} \
        ${VIM_ENABLE_RUBY:+--enable-rubyinterp} \
        ${VIM_ENABLE_LUA:+--enable-luainterp $([ "${LUA_VERSION}" = 'jit' ] && echo --with-luajit)} \
        ${VIM_ENABLE_TCL:+--enable-tclinterp} \
        ${VIM_ENABLE_MZSCHEME:+--enable-mzschemeinterp --with-plthome=/usr} \
        --enable-fail-if-missing
RUN make -j$(nproc)
RUN mv /usr/local /usr/local_bak
RUN make install


FROM base AS release

LABEL maintainer="thinca <thinca+vim@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/thinca/dockerfile-vim"

COPY --from=build /usr/local /usr/local/
COPY --from=iconv /usr/local/include /usr/local/include/
COPY --from=iconv /usr/local/lib /usr/local/lib/

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/vim"]
