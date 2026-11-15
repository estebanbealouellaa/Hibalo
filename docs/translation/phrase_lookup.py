"""Short-phrase lookup for the Hibalo translator (check this BEFORE running the model).

    pl = PhraseList('hibalo_phrase_list_v1.tsv', 'hil_spelling_map_v2.tsv')
    pl.lookup('Patayin ang ilaw.', 'fil2hil')   -> 'patya ang suga'   (then run postprocess.match_style)
    pl.lookup('Diin ang banyo?', 'hil2fil')     -> None               (not in the list: use the model)

The key must be built exactly like this in Dart:
  1. normalize()  (same as text_rules.py: no accent marks, straight quotes, single spaces)
  2. lowercase
  3. replace each of  . , ! ? ; : " ( ) [ ] … — – ' ~ *  with a space
  4. split on spaces; for Hiligaynon input, replace each word with hil_spelling_map_v2 (variant -> standard)
  5. join with one space
"""
import csv, re, unicodedata

PUNCT = re.compile(r"""[.,!?;:"()\[\]…—–'~*]""")


def normalize(t):
    t = unicodedata.normalize('NFD', str(t))
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    t = t.replace('’', "'").replace('‘', "'").replace('“', '"').replace('”', '"')
    return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', t)).strip()


def load_tsv(path):
    with open(path, encoding='utf-8') as fh:
        return list(csv.DictReader(fh, delimiter='\t', quoting=csv.QUOTE_NONE))


class PhraseList:
    def __init__(self, phrase_tsv, spelling_tsv, use_eval_rows=True, use_dictionary_words=True):
        self.smap = {r['variant']: r['standard'] for r in load_tsv(spelling_tsv)}
        self.table = {}
        for r in load_tsv(phrase_tsv):
            if not use_eval_rows and r['in_eval_set'] == '1':
                continue          # switch off when measuring the app on the everyday test
            if not use_dictionary_words and r['kind'] == 'dictionary_word':
                continue
            self.table[(r['direction'], r['key'])] = r

    def key(self, text, src_lang):
        t = PUNCT.sub(' ', normalize(text).lower())
        ws = t.split()
        if src_lang == 'hil':
            ws = [self.smap.get(w, w) for w in ws]
        return ' '.join(ws)

    def lookup(self, text, direction):
        """direction: 'hil2fil' or 'fil2hil'. Returns the stored translation or None."""
        r = self.table.get((direction, self.key(text, 'hil' if direction == 'hil2fil' else 'fil')))
        return r['output'] if r else None


if __name__ == '__main__':
    import sys
    pl = PhraseList(sys.argv[1], sys.argv[2])
    rows = load_tsv(sys.argv[1])
    bad = sum(pl.key(r['input_example'], 'hil' if r['direction'] == 'hil2fil' else 'fil') != r['key'] for r in rows)
    print(f'{len(rows)} rows, keys rebuilt from input_example that differ: {bad} (must be 0)')
    for text, d in [('Patayin ang ilaw.', 'fil2hil'), ('PATAYIN ANG ILAW', 'fil2hil'), ('Naano imo tiil?', 'hil2fil'),
                    ('Maayong aga!', 'hil2fil'), ('Kumusta ka?', 'fil2hil'), ('Diin ang banyo?', 'hil2fil'),
                    ('Salamat gid', 'hil2fil'), ('Indi sia magkadto', 'hil2fil')]:
        print(f'  {d} {text!r:24} -> {pl.lookup(text, d)!r}')
