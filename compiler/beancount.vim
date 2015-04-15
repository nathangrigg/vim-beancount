if exists("current_compiler")
    finish
endif
let current_compiler = "beancount"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=bean-check\ %
CompilerSet errorformat=%-G         " Skip blank lines
CompilerSet errorformat+=%f:%l:\ %m  " File:line: message
CompilerSet errorformat+=%-G\ %.%#   " Skip indented lines.

let &cpo = s:cpo_save
unlet s:cpo_save
