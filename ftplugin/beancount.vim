if exists('b:did_ftplugin')
    finish
endif

let b:did_ftplugin = 1
let b:undo_ftplugin = 'setlocal foldmethod< comments< commentstring<'

function! BeancountFoldexpr()
  let thisline = getline(v:lnum)
  let nextline = getline(v:lnum+1)

  if thisline =~ '^\s*$'
    " ignore empty lines
    return '='
  endif

  if thisline =~ '^#'
    " current line starts with hashes
    return '>'.matchend(thisline, '^#\+')
  elseif thisline =~ '^\S'
    if nextline =~ '^\s\+'
      return 'a1'
    else
      return '='
    endif
  elseif thisline =~ '^\s\+'
    if nextline =~ '^\(\s*$\|\S\)'
      return 's1'
    else
      return '='
    endif
  else
    " keep previous foldlevel
    return '='
  endif
endfunc

setl foldexpr=BeancountFoldexpr()
setl foldmethod=expr

setl comments=b:;
setl commentstring=;%s
compiler beancount

" This variable customizes the behavior of the AlignCommodity command.
if !exists('g:beancount_separator_col')
    let g:beancount_separator_col = 50
endif
if !exists('g:beancount_account_completion')
    let g:beancount_account_completion = 'default'
endif
if !exists('g:beancount_detailed_first')
    let g:beancount_detailed_first = 0
endif

command! -buffer -range AlignCommodity
            \ :call beancount#align_commodity(<line1>, <line2>)

command! -buffer -range GetContext
            \ :call beancount#get_context()

" Omnifunc for account completion.
setl omnifunc=beancount#complete
