" Align currency on decimal point.
function! beancount#align_commodity(line1, line2)
    " Saving cursor position to adjust it if necessary.
    let cursor_col = col('.')
    let cursor_line = line('.')
    " This matches the line up to the first dot (or other separator),
    " excluding comments.
    " Note very nomagic so that the separator is not interpreted as regex.
    let separator_regex = '^\V\[^;]\{-}' . g:beancount_decimal_separator
    " This lets me increment at start of loop, because of continue statements.
    let i = a:line1 - 1
    while i < a:line2
        let i += 1
        let s = getline(i)
        " This matches an account name followed by a space. There may be
        " some conflicts with non-transaction syntax that I don't know about.
        " It won't match a comment or any non-indented line.
        let end_acc = matchend(s, '^\v([-\d]+\s+(balance|price))? +\S+ ')
        if end_acc < 0 | continue | endif
        " Where does commodity amount begin?
        let end_space = matchend(s, '^ *', end_acc)
        " Find the first decimal point, not counting comments.
        let separator = matchend(s, separator_regex, end_space)
        if separator < 0
            " If there is no separator, pretend there's one after the last digit.
            let separator = matchend(s, '^\v[^;]*\d+') + 1
        endif
        if separator < 0 | continue | endif
        let has_spaces = end_space - end_acc
        let need_spaces = g:beancount_separator_col - separator + has_spaces
        if need_spaces < 0 | continue | endif
        call setline(i, s[0 : end_acc - 1] . repeat(" ", need_spaces) . s[ end_space : -1])
        if i == cursor_line && cursor_col >= end_acc
            " Adjust cursor position for continuity.
            call cursor(0, cursor_col + need_spaces - has_spaces)
        endif
    endwhile
endfunction

" Complete account name.
function! beancount#complete_account(findstart, base)
    if a:findstart
        let l:col = searchpos('\s', "bn", line("."))[1]
        if col == 0
            return -1
        else
            return col
        endif
    endif

    let l:pattern = '^\V\.\{10\}\s\+open\s\+\zs\S\*' .
                \ substitute(a:base, ":", '\\S\\*:\\S\\*', "g")
    let l:view = winsaveview()
    let l:fe = &foldenable
    set nofoldenable
    call cursor(1, 1)
    let l:matches = []
    while 1
        let l:cline = search(pattern, "W")
        if l:cline == 0 | break | endif
        call add(matches, expand("<cWORD>"))
    endwhile
    let &foldenable = l:fe
    call winrestview(l:view)
    return l:matches
endfunction
