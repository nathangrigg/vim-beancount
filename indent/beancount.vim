if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setlocal indentexpr=GetBeancountIndent(v:lnum)

if exists("*GetBeancountIndent")
    finish
endif

function! s:IsDirective(str)
    return a:str =~ '\v^\s*(\d{4}-\d{2}-\d{2}|pushtag|poptag|option|plugin|include)'
endfunction

function! s:IsPost(str)
    return a:str =~ '\v^\s*(Assets|Liabilities|Expenses|Equity|Income):'
endfunction

function! s:IsMetadata(str)
    return a:str =~ '\v^\s*\w+:\s'
endfunction

function! s:IsTransaction(str)
    return a:str =~ '\v^\s*\d{4}-\d{2}-\d{2}\s+(txn\s+)?\S\s'
endfunction

function GetBeancountIndent(line_num)
    let this_line = getline(a:line_num)
    let prev_line = getline(a:line_num - 1)
    " Don't touch comments
    if this_line =~ '\v^\s*;' | return -1 | endif
    " This is a new directive or previous line is blank.
    if prev_line =~ '^\s*$' || s:IsDirective(this_line) | return 0 | endif
    " Previous line is transaction or this is a posting.
    if s:IsTransaction(prev_line) || s:IsPost(this_line) | return &sw | endif
    if s:IsMetadata(this_line)
        let this_indent = indent(a:line_num - 1)
        if ! s:IsMetadata(prev_line) | let this_indent += &sw | endif
        return this_indent
    endif
    return -1
endfunction
