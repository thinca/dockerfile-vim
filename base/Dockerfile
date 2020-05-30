FROM alpine:3.12 AS iconv

RUN apk add --no-cache g++ make
RUN wget --quiet --output-document - http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz | \
        tar -xz --strip-components=1
RUN ./configure
RUN make
RUN make install


FROM alpine:3.12 AS base

ARG VIM_VERSION=master
ARG VIM_ENABLE_ALL=""
ARG VIM_ENABLE_GUI="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PERL="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PYTHON="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PYTHON3="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_RUBY="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_LUA="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_TCL="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_MZSCHEME="${VIM_ENABLE_ALL}"
ARG LUA_VERSION="5.3"
ARG PYTHON3_VERSION=""
ARG VIM_COMPILEDBY=""

RUN { [ -z "${VIM_ENABLE_MZSCHEME}" ] || \
    { echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
      echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories; }; } \
 && { [ -z "${VIM_ENABLE_PYTHON3}" -o "v${PYTHON3_VERSION}" != "v3.7" ] || \
      { echo "http://dl-cdn.alpinelinux.org/alpine/v3.10/main" >> /etc/apk/repositories; \
      PYTHON3_VERSION_DETAIL="=3.7.5-r1"; }; } \
 && apk add --no-cache \
        ncurses \
        acl \
        diffutils \
        ${VIM_ENABLE_GUI:+gtk+3.0 libxpm} \
        ${VIM_ENABLE_PERL:+perl} \
        ${VIM_ENABLE_PYTHON:+python2} \
        ${VIM_ENABLE_PYTHON3:+python3${PYTHON3_VERSION_DETAIL}} \
        ${VIM_ENABLE_RUBY:+ruby} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION} luajit} \
        ${VIM_ENABLE_TCL:+tcl} \
        ${VIM_ENABLE_MZSCHEME:+racket}


FROM base AS build

RUN apk add \
        gcc \
        libc-dev \
        make \
        gettext \
        ncurses-dev \
        acl-dev \
        ${VIM_ENABLE_GUI:+gtk+3.0-dev libxpm-dev} \
        ${VIM_ENABLE_PERL:+perl-dev} \
        ${VIM_ENABLE_PYTHON:+python2-dev} \
        ${VIM_ENABLE_PYTHON3:+python3-dev} \
        ${VIM_ENABLE_RUBY:+ruby-dev} \
        ${VIM_ENABLE_TCL:+tcl-dev} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}-dev luajit-dev} \
        ${VIM_ENABLE_MZSCHEME:+racket-dev}
RUN [ -z "${VIM_ENABLE_MZSCHEME}" ] || raco pkg install --batch --auto cext-lib
RUN mkdir -p /usr/src/vim
RUN wget --quiet --output-document - \
        "https://github.com/vim/vim/archive/${VIM_VERSION}.tar.gz" | \
        tar xz --directory=/usr/src/vim --strip-components=1
WORKDIR /usr/src/vim
RUN ./configure \
        --with-features=huge \
        --with-compiledby="${VIM_COMPILEDBY}" \
        ${VIM_ENABLE_GUI:+--enable-gui=gtk3} \
        ${VIM_ENABLE_PERL:+--enable-perlinterp} \
        ${VIM_ENABLE_PYTHON:+--enable-pythoninterp} \
        ${VIM_ENABLE_PYTHON3:+--enable-python3interp} \
        ${VIM_ENABLE_RUBY:+--enable-rubyinterp} \
        ${VIM_ENABLE_LUA:+--enable-luainterp --with-luajit} \
        ${VIM_ENABLE_TCL:+--enable-tclinterp} \
        ${VIM_ENABLE_MZSCHEME:+--enable-mzschemeinterp --with-plthome=/usr} \
        --enable-fail-if-missing
RUN make
RUN mv /usr/local /usr/local_bak
RUN make install


FROM base AS release

LABEL maintainer="thinca <thinca+vim@gmail.com>"

COPY --from=build /usr/local /usr/local/
COPY --from=iconv /usr/local/include /usr/local/include/
COPY --from=iconv /usr/local/lib /usr/local/lib/

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/vim"]
