call ale#Set('beancount_bean_check_executable', 'bean-check')
call ale#Set('beancount_bean_check_options', '')

function! ale_linters#beancount#bean_check#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'beancount_bean_check_executable')
endfunction

function! ale_linters#beancount#bean_check#GetCommand(buffer) abort
  let l:options = ale#Var(a:buffer, 'beancount_bean_check_options')
  return ale#Escape(ale_linters#beancount#bean_check#GetExecutable(a:buffer))
    \ . ' '
    \ . (empty(l:options) ? '' : ' ' . l:options)
    \ . ' %s'
endfunction

call ale#linter#Define('beancount', {
\   'name': 'bean_check',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#beancount#bean_check#GetExecutable',
\   'command_callback': 'ale_linters#beancount#bean_check#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
