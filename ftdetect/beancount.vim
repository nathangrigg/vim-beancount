" This is to avoid setting ft twice. Taken from vim-ruby.
function! s:setf(filetype) abort
    if &filetype !=# a:filetype
        let &filetype = a:filetype
    endif
endfunction

au BufNewFile,BufRead *.bean,*.beancount set filetype=beancount
