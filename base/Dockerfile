FROM alpine:3.11 AS iconv

RUN apk add --no-cache curl g++ make
RUN curl -SL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz | tar -xz
WORKDIR libiconv-1.16
RUN ./configure
RUN make
RUN make install


FROM alpine:3.11 AS base

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

RUN ([ -z "${VIM_ENABLE_MZSCHEME}" ] || echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories) \
 && ([ -z "${VIM_ENABLE_MZSCHEME}" -a -z "${VIM_ENABLE_PYTHON3}" ] || echo "http://dl-cdn.alpinelinux.org/alpine/v3.10/main" >> /etc/apk/repositories) \
 && apk add --no-cache \
        ncurses \
        acl \
        diffutils \
        ${VIM_ENABLE_GUI:+gtk+3.0 libxpm} \
        ${VIM_ENABLE_PERL:+perl} \
        ${VIM_ENABLE_PYTHON:+python2} \
        ${VIM_ENABLE_PYTHON3:+python3=3.7.5-r1} \
        ${VIM_ENABLE_RUBY:+ruby} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION} luajit} \
        ${VIM_ENABLE_TCL:+tcl} \
        ${VIM_ENABLE_MZSCHEME:+racket}


FROM base AS build

RUN apk add \
        git \
        gcc \
        libc-dev \
        make \
        gettext \
        ncurses-dev \
        acl-dev \
        ${VIM_ENABLE_GUI:+gtk+3.0-dev libxpm-dev} \
        ${VIM_ENABLE_PERL:+perl-dev} \
        ${VIM_ENABLE_PYTHON:+python2-dev} \
        ${VIM_ENABLE_PYTHON3:+python3-dev=3.7.5-r1} \
        ${VIM_ENABLE_RUBY:+ruby-dev} \
        ${VIM_ENABLE_TCL:+tcl-dev} \
        ${VIM_ENABLE_LUA:+lua${LUA_VERSION}-dev luajit-dev} \
        ${VIM_ENABLE_MZSCHEME:+racket-dev}
RUN [ -z "${VIM_ENABLE_MZSCHEME}" ] || raco pkg install --batch --auto cext-lib
RUN git -c advice.detachedHead=false \
        clone --quiet --depth 1 --branch "${VIM_VERSION}" \
        https://github.com/vim/vim.git /usr/src/vim
WORKDIR /usr/src/vim
RUN ./configure \
        --with-features=huge \
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

# test
RUN vim -es \
        -c 'verbose echo "----- Running Test -----"' \
        ${VIM_ENABLE_PERL:+-c 'verbose perl print("Perl $^V")'} \
        ${VIM_ENABLE_PYTHON:+-c 'verbose python import platform;print("Python v" + platform.python_version())'} \
        ${VIM_ENABLE_PYTHON3:+-c 'verbose python3 import platform;print("Python3 v" + platform.python_version())'} \
        ${VIM_ENABLE_RUBY:+-c 'verbose ruby puts "Ruby v#{RUBY_VERSION}"'} \
        ${VIM_ENABLE_LUA:+-c 'verbose lua print(_VERSION)'} \
        ${VIM_ENABLE_TCL:+-c 'verbose tcl puts "Tcl v[info patchlevel]"'} \
        ${VIM_ENABLE_MZSCHEME:+-c 'verbose mzscheme (string-append "Racket v" (version))'} \
        -c 'verbose echo "----- Finish Test -----\n"' \
        -c q

COPY vimrc /usr/local/share/vim/vimrc

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/vim"]
