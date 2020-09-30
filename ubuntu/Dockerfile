FROM ubuntu:20.10 AS base

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
ARG LUA_VERSION="5.3"
ARG PYTHON3_VERSION=""

RUN [ -z "${VIM_ENABLE_GUI}${VIM_ENABLE_SOUND}${VIM_ENABLE_PERL}${VIM_ENABLE_PYTHON}${VIM_ENABLE_PYTHON3}${VIM_ENABLE_RUBY}${VIM_ENABLE_LUA}${VIM_ENABLE_TCL}${VIM_ENABLE_MZSCHEME}" ] \
 || apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        ${VIM_ENABLE_GUI:+libgtk-3-0 libxmu6 libxpm4} \
        ${VIM_ENABLE_SOUND:+libcanberra0} \
        ${VIM_ENABLE_PERL:+perl} \
        ${VIM_ENABLE_PYTHON:+python-dev} \
        ${VIM_ENABLE_PYTHON3:+python3-dev} \
        ${VIM_ENABLE_RUBY:+ruby} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION} luajit} \
        ${VIM_ENABLE_TCL:+tcl} \
        ${VIM_ENABLE_MZSCHEME:+racket} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


FROM base AS prepare

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        build-essential \
        gettext \
        libtinfo-dev \
        ${VIM_ENABLE_GUI:+libgtk-3-dev libxmu-dev libxpm-dev} \
        ${VIM_ENABLE_SOUND:+libcanberra-dev} \
        ${VIM_ENABLE_PERL:+libperl-dev} \
        ${VIM_ENABLE_RUBY:+ruby-dev} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}-dev libluajit-5.1-dev} \
        ${VIM_ENABLE_TCL:+tcl-dev}
RUN mkdir -p /usr/src/vim


FROM prepare AS build

ARG VIM_VERSION=master
ARG VIM_COMPILEDBY=""

RUN curl --silent --location \
        "https://github.com/vim/vim/archive/${VIM_VERSION}.tar.gz" | \
        tar xz --directory=/usr/src/vim --strip-components=1
WORKDIR /usr/src/vim
RUN ./configure \
        --with-features=huge \
        ${VIM_COMPILEDBY:+--with-compiledby="${VIM_COMPILEDBY}"} \
        ${VIM_ENABLE_GUI:+--enable-gui=gtk3} \
        ${VIM_ENABLE_PERL:+--enable-perlinterp} \
        ${VIM_ENABLE_PYTHON:+--enable-pythoninterp} \
        ${VIM_ENABLE_PYTHON3:+--enable-python3interp} \
        ${VIM_ENABLE_RUBY:+--enable-rubyinterp} \
        ${VIM_ENABLE_LUA:+--enable-luainterp --with-luajit} \
        ${VIM_ENABLE_TCL:+--enable-tclinterp} \
        ${VIM_ENABLE_MZSCHEME:+--enable-mzschemeinterp} \
        --enable-fail-if-missing
RUN make ${VIM_ENABLE_MZSCHEME:+MZSCHEME_LIBS="-lracket3m -lrktio -lffi"}
RUN mv /usr/local /usr/local_bak
RUN make install


FROM base AS release

LABEL maintainer="thinca <thinca+vim@gmail.com>"

COPY --from=build /usr/local /usr/local/

ENV LANG="C.UTF-8"

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/vim"]
