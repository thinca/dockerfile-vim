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

FROM ubuntu:22.04 AS racket

ARG RACKET_VERSION=8.5

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get --no-install-recommends install -y \
    curl ca-certificates \
    build-essential libsqlite3-dev

WORKDIR /usr/src/racket/src
RUN curl --silent --location \
        "https://mirror.racket-lang.org/installers/${RACKET_VERSION}/racket-${RACKET_VERSION}-src-builtpkgs.tgz" | \
        tar xz --directory=/usr/src/racket --strip-components=1
RUN ./configure --prefix "/usr/local" --enable-dynlib --enable-bcdefault --disable-futures --disable-places --disable-gracket --disable-docs
RUN make -j$(nproc)
RUN make install


FROM ubuntu:22.04 AS base

ARG VIM_ENABLE_ALL
ARG VIM_ENABLE_GUI
ARG VIM_ENABLE_SOUND
ARG VIM_ENABLE_PERL
ARG VIM_ENABLE_PYTHON
ARG VIM_ENABLE_PYTHON3
ARG VIM_ENABLE_RUBY
ARG VIM_ENABLE_LUA
ARG VIM_ENABLE_TCL
ARG VIM_ENABLE_MZSCHEME
ARG LUA_VERSION

RUN [ -z "${VIM_ENABLE_GUI}${VIM_ENABLE_SOUND}${VIM_ENABLE_PERL}${VIM_ENABLE_PYTHON}${VIM_ENABLE_PYTHON3}${VIM_ENABLE_RUBY}${VIM_ENABLE_LUA}${VIM_ENABLE_TCL}" ] \
 || apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get --no-install-recommends install -y \
        ${VIM_ENABLE_GUI:+libgtk-3-0 libxmu6 libxpm4} \
        ${VIM_ENABLE_SOUND:+libcanberra0} \
        ${VIM_ENABLE_PERL:+perl} \
        ${VIM_ENABLE_PYTHON:+python2-dev} \
        ${VIM_ENABLE_PYTHON3:+python3-dev} \
        ${VIM_ENABLE_RUBY:+ruby} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}} \
        ${VIM_ENABLE_TCL:+tcl} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


FROM base AS base-racket

COPY --from=racket /usr/local /usr/local/


FROM base${VIM_ENABLE_MZSCHEME:+-racket} AS prepare

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get --no-install-recommends install -y \
        curl \
        ca-certificates \
        build-essential \
        gettext \
        libtinfo-dev \
        ${VIM_ENABLE_GUI:+libgtk-3-dev libxmu-dev libxpm-dev} \
        ${VIM_ENABLE_SOUND:+libcanberra-dev} \
        ${VIM_ENABLE_PERL:+libperl-dev} \
        ${VIM_ENABLE_RUBY:+ruby-dev} \
        ${VIM_ENABLE_LUA:+$([ "${LUA_VERSION}" = 'jit' ] && echo libluajit-5.1-dev || echo liblua${LUA_VERSION}-dev)} \
        ${VIM_ENABLE_TCL:+tcl-dev}
RUN ${VIM_ENABLE_LUA:+rm -f /usr/lib/x86_64-linux-gnu/liblua*.so}


FROM prepare AS build

ARG VIM_VERSION=master
ARG VIM_COMPILEDBY=""

RUN mkdir -p /usr/src/vim
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
        ${VIM_ENABLE_LUA:+--enable-luainterp $([ "${LUA_VERSION}" = 'jit' ] && echo --with-luajit)} \
        ${VIM_ENABLE_TCL:+--enable-tclinterp} \
        ${VIM_ENABLE_MZSCHEME:+--enable-mzschemeinterp} \
        --enable-fail-if-missing
RUN make -j$(nproc)
RUN make install
RUN rm -fr /usr/local/include/*


FROM base AS release

LABEL maintainer="thinca <thinca+vim@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/thinca/dockerfile-vim"

COPY --from=build /usr/local /usr/local/

ENV LANG="C.UTF-8"

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/vim"]
