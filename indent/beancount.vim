if exists('b:did_indent')
    finish
endif
let b:did_indent = 1

setlocal indentexpr=GetBeancountIndent(v:lnum)

if exists('*GetBeancountIndent')
    finish
endif

if exists('*shiftwidth')
    func s:sw()
        return shiftwidth()
    endfunc
else
    func s:sw()
        return &shiftwidth
    endfunc
endif

function! s:IsDirective(str)
    return a:str =~# '\v^\s*(\d{4}-\d{2}-\d{2}|pushtag|poptag|option|plugin|include)'
endfunction

function! s:IsPosting(str)
    return a:str =~# '\v^\s*[A-Z]\w+:'
endfunction

function! s:IsMetadata(str)
    return a:str =~# '\v^\s*[a-z][a-zA-Z0-9\-_]+:'
endfunction

function! s:IsTransaction(str)
    " The final \S represents the flag (e.g. * or !).
    return a:str =~# '\v^\s*\d{4}-\d{2}-\d{2}\s+(txn\s+)?\S(\s|$)'
endfunction

function GetBeancountIndent(line_num)
    let l:this_line = getline(a:line_num)
    let l:prev_line = getline(a:line_num - 1)
    " Don't touch comments
    if l:this_line =~# '\v^\s*;' | return -1 | endif
    " This is a new directive or previous line is blank.
    if l:prev_line =~# '^\s*$' || s:IsDirective(l:this_line) | return 0 | endif
    " Previous line is transaction or this is a posting.
    if s:IsTransaction(l:prev_line) || s:IsPosting(l:this_line) | return s:sw() | endif
    if s:IsMetadata(l:this_line)
        let l:this_indent = indent(a:line_num - 1)
        if ! s:IsMetadata(l:prev_line) | let l:this_indent += s:sw() | endif
        return l:this_indent
    endif
    return -1
endfunction
