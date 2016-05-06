" These two variables customize the behavior of the AlignCommodity command.

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1
let b:undo_ftplugin = "setlocal foldmethod< comments< commentstring<"

setl foldmethod=expr
setl foldexpr=GetBeanCountFold(v:lnum)
setl comments=b:;
setl commentstring=;%s
compiler beancount

if !exists("g:beancount_separator_col")
    let g:beancount_separator_col = 50
endif
if !exists("g:beancount_decimal_separator")
    let g:beancount_decimal_separator = "."
endif
if !exists('g:beancount_account_completion')
  let g:beancount_account_completion = 'default'
endif
if !exists('g:beancount_detailed_first')
  let g:beancount_detailed_first = 0
endif

function! GetBeanCountFold(lnum)
    if getline(a:lnum) =~ '\v^;\s+\+'
        return '>1'
    elseif getline(a:lnum) =~ '\v^;\s+-'
        return 1
    elseif getline(a:lnum) =~ '\v^\d{4}-\d{2}-\d{2}' && getline(a:lnum+1) =~ '\v^\s+\S+'
        return '>2'
    elseif getline(a:lnum) =~ '\v^\s+\S'
        return 2
    endif

    return -1
endfunction

command! -buffer -range AlignCommodity
            \ :call beancount#align_commodity(<line1>, <line2>)

" Omnifunc for account completion.
setl omnifunc=beancount#complete_account
