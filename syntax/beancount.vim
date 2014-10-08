" Vim syntax file
" Language: beancount
" Maintainer: Nathan Grigg
" Latest Revision: 2014-10-07

" if exists("b:current_syntax")
"     finish
" endif

syntax clear
" Basics.
syn region beanComment start="\s*;" end="$" keepend contains=beanMarker
syn match beanMarker "\v(\{\{\{|\}\}\})\d?" contained
syn region beanString start='"' skip='\\"' end='"' contained
syn match beanAmount "\v[-+]?[[:digit:].,]+" nextgroup=beanCurrency contained
            \ skipwhite
syn match beanCurrency "\v\w+" contained
" Account name: alphanumeric with at least one colon.
syn match beanAccount "\v[[:alnum:]]+:[[:alnum:]:]+" contained


" Most directives start with a date.
syn match beanDate "^\v\d{4}-\d{2}-\d{2}" skipwhite
            \ nextgroup=beanOpen,beanTxn,beanClose,beanNote,beanBalance,beanEvent,beanPad
" Options and events have two string arguments. The first, we are matching as
" beanOptionTitle and the second as a regular string.
syn region beanOption matchgroup=beanKeyword start="^option" end="$"
            \ contains=beanOptionTitle,beanComment
syn region beanEvent matchgroup=beanKeyword start="event" end="$" contained
            \ contains=beanOptionTitle,beanComment
syn region beanOptionTitle start='"' skip='\\"' end='"' contained
            \ nextgroup=beanString skipwhite
syn region beanOpen matchgroup=beanKeyword start="open" end="$"
            \ contains=beanAccount,beanCurrency,beanComment
syn region beanClose matchgroup=beanKeyword start="close" end="$"
            \ contains=beanAccount,beanComment
syn region beanNote matchgroup=beanKeyword start="\vnote|document" end="$"
            \ contains=beanAccount,beanString,beanComment
syn region beanBalance matchgroup=beanKeyword start="balance" end="$"
            \ contains=beanAccount,beanAmount,beanComment
syn keyword beanKeyword pushtag poptag
syn region beanPad matchgroup=beanKeyword start="^pad" end="$"
            \ contains=beanAccount,beanComment

syn region beanTxn matchgroup=beanKeyword start="\v(txn)?\s+[*!]" skip="^\s"
            \ end="^" contains=beanString,beanPost,beanComment contained
syn region beanPost start="^\v\s+" end="$"
            \ contains=beanAccount,beanAmount,beanComment,beanCost,beanPrice
syn region beanCost start="{" end="}" contains=beanAmount contained
syn match beanPrice "\V@@\?" nextgroup=beanAmount contained
" TODO: tags and links

highlight default link beanKeyword Keyword
highlight default link beanOptionTitle Keyword
highlight default link beanDate Keyword
highlight default link beanString String
highlight default link beanComment Comment
highlight default link beanAccount Identifier
highlight default link beanAmount Number
highlight default link beanCurrency Number
highlight default link beanCost Number
highlight default link beanPrice Number
