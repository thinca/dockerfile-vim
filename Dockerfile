FROM alpine:3.4

LABEL maintainer="thinca <thinca+vim@gmail.com>"

RUN apk add --no-cache \
        git \
        gcc \
        libc-dev \
        make \
        gettext \
        ncurses-dev \
        acl-dev \
        libxmu-dev \
        gtk+2.0-dev \
        libxpm-dev \
        perl-dev \
        python-dev \
        python3-dev \
        ruby \
        ruby-dev \
        lua5.3-dev \
        luajit-dev \
 && git clone --quiet --depth 1 https://github.com/vim/vim.git /usr/src/vim \
 && cd /usr/src/vim \
 && ./configure --with-features=huge --enable-gui=gtk2 --enable-perlinterp --enable-pythoninterp --enable-python3interp --enable-rubyinterp --enable-luainterp --with-luajit --enable-fail-if-missing \
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
        ncurses-dev \
        libxmu-dev \
        ruby


WORKDIR /root

CMD ["/usr/local/bin/vim"]
