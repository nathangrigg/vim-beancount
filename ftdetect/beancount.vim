" This is to avoid setting ft twice. Taken from vim-ruby.
function! s:setf(filetype) abort
    if &filetype !=# a:filetype
        let &filetype = a:filetype
    endif
endfunction

augroup Beancount
    au BufNewFile,BufRead *.bean,*.beancount  call s:setf('beancount')
augroup END
