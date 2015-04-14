if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setlocal indentexpr=GetBeancountIndent(v:lnum)

if exists("*GetBeancountIndent")
    finish
endif

function GetBeancountIndent(line_num)
    let this_line = getline(a:line_num)
    let prev_line = getline(a:line_num - 1)
    " This is a new directive or previous line is blank.
    echom this_line
    echom prev_line
    if this_line =~ '\v^\s*\d{4}-\d{2}-\d{2}' || prev_line =~ '^\s*$'
        return 0
    endif
    " Previous line is the beginning of a transaction.
    if prev_line =~ '\v^\s*\d{4}-\d{2}-\d{2}\s+(txn\s+)?.\s+'
        return &shiftwidth
    endif
    return -1
endfunction
