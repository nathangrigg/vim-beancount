" These two variables customize the behavior of the AlignCommodity command.

if !exists("g:beancount_separator_col")
    let g:beancount_separator_col = 50
endif
if !exists("g:beancount_decimal_separator")
    let g:beancount_decimal_separator = "."
endif

command! -range AlignCommodity :call beancount#align_commodity(<line1>, <line2>)

" Align commodity to proper column
inoremap <buffer> . .<C-O>:AlignCommodity<CR>
nnoremap <buffer> <leader>= :AlignCommodity<CR>
vnoremap <buffer> <leader>= :AlignCommodity<CR>

" Insert incoming transactions at the bottom
function! s:InsertIncoming()
    let incoming = expand('%:h') . '/incoming.bean'
    try
        execute '$read' incoming
        call system('mv ' . incoming . ' ' . incoming . '~')
    catch /:E484/
        echom "Not found: incoming.bean"
    endtry
endfunction

command! -buffer Incoming call <SID>InsertIncoming()

setl commentstring=;%s
