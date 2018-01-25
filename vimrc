" Docker sets the terminal size in very lazy timing.
" This workaround tries to reset terminal size.
augroup reset-term-for-docker-env
  autocmd! VimEnter * set term&
augroup END
