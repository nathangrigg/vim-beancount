" These two variables customize the behavior of the AlignCommodity command.

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1
let b:undo_ftplugin = "setlocal foldmethod< comments< commentstring<"

setl foldmethod=marker
setl comments=b:;
setl commentstring=;%s

if !exists("g:beancount_separator_col")
    let g:beancount_separator_col = 50
endif
if !exists("g:beancount_decimal_separator")
    let g:beancount_decimal_separator = "."
endif

command! -buffer -range AlignCommodity
            \ :call beancount#align_commodity(<line1>, <line2>)

" Omnifunc for account completion.
setl omnifunc=beancount#complete_account
