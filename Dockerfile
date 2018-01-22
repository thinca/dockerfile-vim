FROM alpine:3.7

LABEL maintainer="thinca <thinca+vim@gmail.com>"

ARG VIM_VERSION=master
ARG VIM_ENABLE_ALL="yes"
ARG VIM_ENABLE_GUI="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PERL="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PYTHON="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_PYTHON3="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_RUBY="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_LUA="${VIM_ENABLE_ALL}"
ARG VIM_ENABLE_TCL="${VIM_ENABLE_ALL}"
ARG LUA_VERSION="5.3"

RUN apk add --no-cache \
        git \
        gcc \
        libc-dev \
        make \
        gettext \
        ncurses-dev \
        acl-dev \
        libxmu-dev \
        libxpm-dev \
        ${VIM_ENABLE_GUI:+gtk+3.0-dev} \
        ${VIM_ENABLE_PERL:+perl-dev} \
        ${VIM_ENABLE_PYTHON:+python-dev} \
        ${VIM_ENABLE_PYTHON3:+python3-dev} \
        ${VIM_ENABLE_RUBY:+ruby ruby-dev} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}-dev luajit-dev} \
        ${VIM_ENABLE_TCL:+tcl-dev} \
 && git -c advice.detachedHead=false \
        clone --quiet --depth 1 --branch "${VIM_VERSION}" \
        https://github.com/vim/vim.git /usr/src/vim \
 && cd /usr/src/vim \
 && ./configure \
        --with-features=huge \
        ${VIM_ENABLE_GUI:+--enable-gui=gtk3} \
        ${VIM_ENABLE_PERL:+--enable-perlinterp} \
        ${VIM_ENABLE_PYTHON:+--enable-pythoninterp} \
        ${VIM_ENABLE_PYTHON3:+--enable-python3interp} \
        ${VIM_ENABLE_RUBY:+--enable-rubyinterp} \
        ${VIM_ENABLE_LUA:+--enable-luainterp --with-luajit} \
        ${VIM_ENABLE_TCL:+--enable-tclinterp} \
        --enable-fail-if-missing \
 && make \
 && make install \
 && cd /root \
 && rm -fr /usr/src/vim \
 && apk del --purge \
        git \
        gcc \
        libc-dev \
        make \
        gettext \
        libxmu-dev \
        ${VIM_ENABLE_RUBY:+ruby} \
# test
 && vim -es \
        ${VIM_ENABLE_PERL:+-c 'verbose perl print("Perl $^V")'} \
        ${VIM_ENABLE_PYTHON:+-c 'verbose python import platform;print("Python v" + platform.python_version())'} \
        ${VIM_ENABLE_PYTHON3:+-c 'verbose python3 import platform;print("Python3 v" + platform.python_version())'} \
        ${VIM_ENABLE_RUBY:+-c 'verbose ruby puts "Ruby v#{RUBY_VERSION}"'} \
        ${VIM_ENABLE_LUA:+-c 'verbose lua print(_VERSION)'} \
        ${VIM_ENABLE_TCL:+-c 'verbose tcl puts "Tcl v[info patchlevel]"'} \
        -c q


WORKDIR /root

ENTRYPOINT ["/usr/local/bin/vim"]
