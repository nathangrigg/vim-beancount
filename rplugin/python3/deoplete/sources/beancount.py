import re

from deoplete.source.base import Base

try:
    from beancount.loader import load_file
    from beancount.core.data import Open, Transaction
    HAS_BEANCOUNT = True
except ImportError:
    HAS_BEANCOUNT = False

DIRECTIVES = ['open', 'close', 'commodity', 'txn', 'balance', 'pad', 'note',
              'document', 'price', 'event', 'query', 'custom']


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.vim = vim

        self.name = 'beancount'
        self.mark = '[bc]'
        self.filetypes = ['beancount']
        self.min_pattern_length = 0

    def on_init(self, context):
        if not HAS_BEANCOUNT:
            self.error('Importing beancount failed.')

    def on_event(self, context):
        self.__make_cache(context)

    def get_complete_position(self, context):
        m = re.search(r'\S*$', context['input'])
        return m.start() if m else -1

    def gather_candidates(self, context):
        if re.match(r'^\d{4}[/-]\d\d[/-]\d\d \w*$', context['input']):
            return DIRECTIVES
        if not context['complete_str']:
            return []
        first = context['complete_str'][0]
        if first == '#':
            return ['#' + w for w in self._tags]
        elif first == '^':
            return ['^' + w for w in self._links]
        elif first == '"':
            return ['"{}"'.format(w) for w in self._payees]
        return self._accounts

    def __make_cache(self, context):
        accounts = set()
        links = set()
        payees = set()
        tags = set()
        if HAS_BEANCOUNT:
            entries, _, _ = load_file(self.vim.eval("expand('%')"))
        else:
            entries = []

        for entry in entries:
            if isinstance(entry, Open):
                accounts.add(entry.account)
            elif isinstance(entry, Transaction):
                if entry.payee:
                    payees.add(entry.payee)
            if hasattr(entry, 'links') and entry.links:
                links.update(entry.links)
            if hasattr(entry, 'tags') and entry.tags:
                tags.update(entry.tags)

        self._accounts = sorted(accounts)
        self._links = sorted(links)
        self._payees = sorted(payees)
        self._tags = sorted(tags)
