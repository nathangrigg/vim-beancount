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
        let end_acc = matchend(s, '^\v([-\d]+\s+(balance|price))? +\S+[^:] ')
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

function! s:count_expression(text, expression)
  return len(split(a:text, a:expression, 1)) - 1
endfunction

function! s:sort_accounts_by_depth(name1, name2)
  let l:depth1 = s:count_expression(a:name1, ':')
  let l:depth2 = s:count_expression(a:name2, ':')
  return depth1 == depth2 ? 0 : depth1 > depth2 ? 1 : -1
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

    if !exists('b:beancount_accounts')
        if exists('b:beancount_root')
            let l:root = b:beancount_root
        else
            let l:root = expand('%')
        endif
        let b:beancount_accounts = beancount#find_accounts(l:root)
    endif

    if g:beancount_account_completion ==? 'chunks'
        let l:pattern = '^\V' . substitute(a:base, ":", '\\[^:]\\*:', "g") . '\[^:]\*'
    else
        let l:pattern = '^\V\.\*' . substitute(a:base, ":", '\\.\\*:\\.\\*', "g") . '\.\*'
    endif

    let l:matches = []
    let l:index = -1
    while 1
        let l:index = match(b:beancount_accounts, l:pattern, l:index + 1)
        if l:index == -1 | break | endif
        call add(l:matches, matchstr(b:beancount_accounts[l:index], l:pattern))
    endwhile

    if g:beancount_detailed_first
        let l:matches = reverse(sort(l:matches, 's:sort_accounts_by_depth'))
    endif

    return l:matches
endfunction

" Get list of acounts.
function! beancount#find_accounts(root_file)
    python << EOM
import collections
import os
import re
import sys
import vim

RE_INCLUDE = re.compile(r'^include\s+"([^\n"]+)"')
RE_ACCOUNT = re.compile(r'^\d{4,}-\d{2}-\d{2}\s+open\s+(\S+)')

def combine_paths(old, new):
    return os.path.normpath(
        new if os.path.isabs(new) else os.path.join(old, new))

def parse_file(fh, files, accounts):
    for line in fh:
        m = RE_INCLUDE.match(line)
        if m: files.append(combine_paths(os.path.dirname(fh.name), m.group(1)))
        m = RE_ACCOUNT.match(line)
        if m: accounts.add(m.group(1))

files = collections.deque([vim.eval("a:root_file")])
accounts = set()
seen = set()
while files:
    current = files.popleft()
    if current in seen:
        continue
    seen.add(current)
    try:
        with open(current, 'r') as fh:
            parse_file(fh, files, accounts)
    except IOError as err:
        pass

vim.command('return [{}]'.format(','.join(repr(x) for x in sorted(accounts))))
EOM
endfunction
