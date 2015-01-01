FROM phusion/baseimage

MAINTAINER thinca <thinca+vim@gmail.com>

RUN apt-get -qq update && apt-get -qqy install git gettext libncurses5-dev libacl1-dev libgpm-dev libxmu-dev libgtk2.0-dev libxpm-dev libperl-dev python-dev python3-dev ruby-dev lua5.2 liblua5.2-dev luajit libluajit-5.1

RUN git clone --quiet --depth 1 https://github.com/vim-jp/vim.git /usr/src/vim

WORKDIR /usr/src/vim

RUN ./configure --with-features=huge --enable-gui=gtk2 --enable-perlinterp --enable-pythoninterp --enable-python3interp --enable-rubyinterp --enable-luainterp --with-luajit --enable-fail-if-missing && make && make install

WORKDIR /root

CMD ["/usr/local/bin/vim"]
