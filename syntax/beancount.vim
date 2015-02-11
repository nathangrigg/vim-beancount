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
syn match beanAccount "\v[[:alnum:]]+:[-[:alnum:]:]+" contained
syn match beanTag "\v#[-[:alnum:]]+" contained
syn match beanLink "\v\^\S+" contained


" Most directives start with a date.
syn match beanDate "^\v\d{4}-\d{2}-\d{2}" skipwhite
            \ nextgroup=beanOpen,beanTxn,beanClose,beanNote,beanBalance,beanEvent,beanPad,beanPrice
" Options and events have two string arguments. The first, we are matching as
" beanOptionTitle and the second as a regular string.
syn region beanOption matchgroup=beanKeyword start="^option" end="$"
            \ keepend contains=beanOptionTitle,beanComment
syn region beanOption matchgroup=beanKeyword start="^plugin" end="$"
            \ keepend contains=beanString,beanComment
syn region beanEvent matchgroup=beanKeyword start="event" end="$" contained
            \ keepend contains=beanOptionTitle,beanComment
syn region beanOptionTitle start='"' skip='\\"' end='"' contained
            \ nextgroup=beanString skipwhite
syn region beanOpen matchgroup=beanKeyword start="open" end="$" keepend
            \ contained contains=beanAccount,beanCurrency,beanComment
syn region beanClose matchgroup=beanKeyword start="close" end="$" keepend
            \ contained contains=beanAccount,beanComment
syn region beanNote matchgroup=beanKeyword start="\vnote|document" end="$"
            \ keepend contains=beanAccount,beanString,beanComment contained
syn region beanBalance matchgroup=beanKeyword start="balance" end="$" contained
            \ keepend contains=beanAccount,beanAmount,beanComment
syn region beanPrice matchgroup=beanKeyword start="price" end="$" contained
            \ keepend contains=beanCurrency,beanAmount
syn keyword beanKeyword pushtag poptag
syn region beanPad matchgroup=beanKeyword start="pad" end="$" contained
            \ keepend contains=beanAccount,beanComment

syn region beanTxn matchgroup=beanKeyword start="\v(txn)?\s+[*!]" skip="^\s"
            \ end="^" keepend contained fold
            \ contains=beanString,beanPost,beanComment,beanTag,beanLink,beanMeta
syn region beanPost start="^\v\C\s+[A-Z]@=" end="$"
            \ contains=beanAccount,beanAmount,beanComment,beanCost,beanPrice
syn region beanMeta matchgroup=beanTag start="^\v\C\s+[-a-z]+:(\s|$)@=" end="$"

syn region beanCost start="{" end="}" contains=beanAmount contained
syn match beanPrice "\V@@\?" nextgroup=beanAmount contained

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
highlight default link beanTag Comment
highlight default link beanLink Comment
highlight default link beanMeta Comment
