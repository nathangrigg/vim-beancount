call ale#Set('beancount_beanformat_executable', 'bean-format')
call ale#Set('beancount_beanformat_options', '')

function! ale#fixers#beanformat#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'beancount_beanformat_executable')
    let l:options = ale#Var(a:buffer, 'beancount_beanformat_options')
    return {
    \   'command': ale#Escape(l:executable)
    \      . (empty(l:options) ? '' : ' ' . l:options)
    \      . ' %t',
    \}
endfunction
