if exists('g:loaded_syntastic_beancount_bean_check')
    finish
endif

let g:loaded_syntastic_beancount_bean_check=1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_beancount_bean_check_IsAvailable() dict
    return executable(self.getExec())
endfunction

function! SyntaxCheckers_beancount_bean_check_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    return SyntasticMake({ 'makeprg': makeprg })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'beancount',
    \ 'name': 'bean_check',
    \ 'exec': 'bean-check'})

let &cpo = s:save_cpo
unlet s:save_cpo
