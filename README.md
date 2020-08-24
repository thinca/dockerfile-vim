# Dockerfile for Vim

Latest Vim from [vim/vim](https://github.com/vim/vim).

```
$ docker run --rm -it thinca/vim
```


## Workaround for terminal size problem

Sometimes terminal size is broken.  (Maybe, Docker sets terminal size too late)
Here is a workaround to this problem.

```
$ docker run --rm -it -e COLUMNS="$(tput cols)" -e LINES="$(tput lines)" thinca/vim
```


## Build Arguments

Note: Buildkit is required to build this image:

```shell
$ export DOCKER_BUILDKIT=1
```


### `VIM_VERSION`

A Git commit reference in [Vim repository](https://github.com/vim/vim). e.g. tag name `v8.0.0000` or commit hash `df980db6`

default: `master`

```
$ docker build --build-arg 'VIM_VERSION=v8.0.0000' --tag 'vim:v8.0.0000' .
```


### `VIM_ENABLE_ALL`

When this is not empty, all supported language interfaces and GUI feature are enabled.
You can overwrite by each variables.

default: empty


ex. Enables only Lua interface.
```
$ docker build --build-arg 'VIM_ENABLE_ALL=' --build-arg 'VIM_ENABLE_LUA=yes' --tag 'vim:lua' .
```

ex. Enables all but Python interface.
```
$ docker build --build-arg 'VIM_ENABLE_ALL=yes' --build-arg 'VIM_ENABLE_PYTHON=' --tag 'vim:all-without-python' .
```

NOTE: The older Vim can not build with some latest version of language interfaces.
Because sometimes the language is updated with breaking changes, and Vim followed to them in newer version.


### `VIM_ENABLE_GUI`

When this is not empty, GUI(gtk+3.0) is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `VIM_ENABLE_PERL`

When this is not empty, Perl interface is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `VIM_ENABLE_PYTHON`

When this is not empty, Python interface is enabled.
Here, "Python" means "Python 2.x".

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `VIM_ENABLE_PYTHON3`

When this is not empty, Python3 interface is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `PYTHON3_VERSION`

A version of Python 3.

You can only specify `3.7` or empty.
`3.8` is used when this is empty.

Vim built with Python 2.x and Python 3.8 is only available either `if_python` or `if_python3`.

You should specify `3.7` to enable both in same time.
But, unfortunately, you can not enable `if_mzscheme` in this case.

default: empty


### `VIM_ENABLE_RUBY`

When this is not empty, Ruby interface is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `VIM_ENABLE_TCL`

When this is not empty, Tcl interface is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `VIM_ENABLE_MZSCHEME`

When this is not empty, MzScheme(Racket) interface is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `VIM_ENABLE_LUA`

When this is not empty, Lua interface is enabled.

default: Follows to [`VIM_ENABLE_ALL`](#vim_enable_all)


### `LUA_VERSION`

A version of lua.
When you use the Vim that is version before `v7.4.093`, please specify `5.1`.

default: `5.3`

```
$ docker build --build-arg 'VIM_VERSION=v7.4.092' --build-arg 'LUA_VERSION=5.1' --tag 'vim:v7.4.092' .
```


### `VIM_COMPILEDBY`

Set to `--with-compiedby` configure option.


## LICENSE

[zlib License](LICENSE.txt)
