call ale#linter#Define('beancount', {
\   'name': 'bean_check',
\   'output_stream': 'stderr',
\   'executable': 'bean-check',
\   'command': 'bean-check ' . beancount#get_root(),
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
