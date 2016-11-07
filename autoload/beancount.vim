function! s:UsingPython3()
  if has('python3')
    return 1
  endif
  return 0
endfunction

let s:using_python3 = s:UsingPython3()

" Equivalent to python's startswith
" Matches based on user's ignorecase preference
function! s:startswith(string, prefix)
  return strpart(a:string, 0, strlen(a:prefix)) == a:prefix
endfunction

" Align currency on decimal point.
function! beancount#align_commodity(line1, line2)
    " Saving cursor position to adjust it if necessary.
    let cursor_col = col('.')
    let cursor_line = line('.')

    " This lets me increment at start of loop, because of continue statements.
    let i = a:line1 - 1
    while i < a:line2
        let i += 1
        let s = getline(i)
        " This matches an account name followed by a space. There may be
        " some conflicts with non-transaction syntax that I don't know about.
        " It won't match a comment or any non-indented line.
        let end_acc = matchend(s, '^\v(([\-/[:digit:]]+\s+(balance|price))|\s+[!&#?%PSTCURM])?\s+\S+[^:] ')
        if end_acc < 0 | continue | endif
        " Where does commodity amount begin?
        let end_space = matchend(s, '^ *', end_acc)

        " Now look for a minus sign and a number, and align on the next column.
        let l:comma = g:beancount_decimal_separator == ',' ? '.' : ','
        let separator = matchend(s, '^\v(-)?[' . l:comma . '[:digit:]]+', end_space) + 1
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

let s:directives = ["open", "close", "commodity", "txn", "balance", "pad", "note", "document", "price", "event", "query", "custom"]

" ------------------------------
" Completion functions
" ------------------------------
function! beancount#complete(findstart, base)
    if a:findstart
        let l:col = searchpos('\s', "bn", line("."))[1]
        if col == 0
            return -1
        else
            return col
        endif
    endif

    let l:partial_line = strpart(getline("."), 0, getpos(".")[2]-1)
    " Match directive types
    if l:partial_line =~# '^\d\d\d\d\(-\|/\)\d\d\1\d\d $'
        return beancount#complete_basic(s:directives, a:base, '')
    endif

    " If we are using python3, now is a good time to load everything
    call beancount#load_everything()

    let l:two_tokens = searchpos('\S\+\s', "bn", line("."))[1]
    let l:prev_token = strpart(getline("."), l:two_tokens, getpos(".")[2] - l:two_tokens)
    " Match curriences if previous token is number
    if l:prev_token =~ '^\d\+\([\.,]\d\+\)*'
        call beancount#load_currencies()
        return beancount#complete_basic(b:beancount_currencies, a:base, '')
    endif

    let l:first = strpart(a:base, 0, 1)
    let l:rest = strpart(a:base, 1)
    if l:first == "#"
        call beancount#load_tags()
        return beancount#complete_basic(b:beancount_tags, l:rest, '#')
    elseif l:first == "^"
        call beancount#load_links()
        return beancount#complete_basic(b:beancount_links, l:rest, '^')
    elseif l:first == '"'
        call beancount#load_payees()
        return beancount#complete_basic(b:beancount_payees, l:rest, '"')
    else
        call beancount#load_accounts()
        return beancount#complete_account(a:base)
    endif
endfunction

function! s:get_root()
    if exists('b:beancount_root')
        return b:beancount_root
    endif
    return expand('%')
endfunction

function! beancount#load_everything()
    if s:using_python3
        let l:root = s:get_root()
python3 << EOF
import vim
from beancount import loader
from beancount.core import data

accounts = set()
currencies = set()
links = set()
payees = set()
tags = set()

entries, errors, options_map = loader.load_file(vim.eval('l:root'))
for index, entry in enumerate(entries):
    if isinstance(entry, data.Open):
        accounts.add(entry.account)
        if entry.currencies:
            currencies.update(entry.currencies)
    elif isinstance(entry, data.Commodity):
        currencies.add(entry.currency)
    elif isinstance(entry, data.Transaction):
        if entry.tags:
            tags.update(entry.tags)
        if entry.links:
            links.update(entry.links)
        if entry.payee:
            payees.add(entry.payee)

vim.command('let b:beancount_accounts = [{}]'.format(','.join(repr(x) for x in sorted(accounts))))
vim.command('let b:beancount_currencies = [{}]'.format(','.join(repr(x) for x in sorted(currencies))))
vim.command('let b:beancount_links = [{}]'.format(','.join(repr(x) for x in sorted(links))))
vim.command('let b:beancount_payees = [{}]'.format(','.join(repr(x) for x in sorted(payees))))
vim.command('let b:beancount_tags = [{}]'.format(','.join(repr(x) for x in sorted(tags))))
EOF
    endif
endfunction

function! beancount#load_accounts()
    if !s:using_python3 && !exists('b:beancount_accounts')
        let l:root = s:get_root()
        let b:beancount_accounts = beancount#find_accounts(l:root)
    endif
endfunction

function! beancount#load_tags()
    if !s:using_python3 && !exists('b:beancount_tags')
        let l:root = s:get_root()
        let b:beancount_tags = beancount#find_tags(l:root)
    endif
endfunction

function! beancount#load_links()
    if !s:using_python3 && !exists('b:beancount_links')
        let l:root = s:get_root()
        let b:beancount_links = beancount#find_links(l:root)
    endif
endfunction

function! beancount#load_currencies()
    if !s:using_python3 && !exists('b:beancount_currencies')
        let l:root = s:get_root()
        let b:beancount_currencies = beancount#find_currencies(l:root)
    endif
endfunction

function! beancount#load_payees()
    if !s:using_python3 && !exists('b:beancount_payees')
        let l:root = s:get_root()
        let b:beancount_payees = beancount#find_payees(l:root)
    endif
endfunction

" General completion function
function! beancount#complete_basic(input, base, prefix)
    let l:matches = filter(copy(a:input), 's:startswith(v:val, a:base)')

    return map(l:matches, 'a:prefix . v:val')
endfunction

" Complete account name.
function! beancount#complete_account(base)
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

function! beancount#query_single(root_file, query)
python << EOF
import vim
import subprocess
import os

# We intentionally want to ignore stderr so it doesn't mess up our query processing
output = subprocess.check_output(['bean-query', vim.eval('a:root_file'), vim.eval('a:query')], stderr=open(os.devnull, 'w')).split('\n')
output = output[2:]

result_list = [y for y in (x.strip() for x in output) if y]

vim.command('return [{}]'.format(','.join(repr(x) for x in sorted(result_list))))
EOF
endfunction

" Get list of accounts.
function! beancount#find_accounts(root_file)
    return beancount#query_single(a:root_file, 'select distinct account;')
endfunction

" Get list of tags.
function! beancount#find_tags(root_file)
    return beancount#query_single(a:root_file, 'select distinct tags;')
endfunction

" Get list of links.
function! beancount#find_links(root_file)
    return beancount#query_single(a:root_file, 'select distinct links;')
endfunction

" Get list of currencies.
function! beancount#find_currencies(root_file)
    return beancount#query_single(a:root_file, 'select distinct currency;')
endfunction

" Get list of payees.
function! beancount#find_payees(root_file)
    return beancount#query_single(a:root_file, 'select distinct payee;')
endfunction

" Call bean-doctor on the current line and dump output into a scratch buffer
function! beancount#get_context()
    let context = system('bean-doctor context ' . expand('%') . ' ' . line('.'))
    botright new
    setlocal buftype=nofile bufhidden=hide noswapfile
    call append(0, split(context, '\v\n'))
    normal! gg
endfunction
