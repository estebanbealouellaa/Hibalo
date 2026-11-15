"""Hiligaynon number words for the Hibalo TTS voice (MMS-TTS v4).

Use it ONLY on Hiligaynon text right before it is spoken, e.g. the translator output
"May 3 ka bata sa balay." -> "May tatlo ka bata sa balay."
Do NOT use it before translating (the translator copies digits safely with <n1>..<n9>).

    from hil_numbers import numbers_to_words
    numbers_to_words("Ang P150 para sa 2 ka tawo, ika-3 nga adlaw.")
    -> "Ang isa ka gatos kag kalim-an ka pesos para sa duha ka tawo, ikatlo nga adlaw."

Word choices come from how numbers are written in our Hiligaynon text (MADLAD, Hiligayner,
Kaufmann, Motus, Bible): "isa ka libo", "duha ka gatos", "napulo kag duha", "katluan",
"kalim-an", "ikaduha", "alas" + Spanish hour. Items marked CHECK should be confirmed by a
native speaker; they are constants, so they are easy to change.
"""
import re

ONES = ['', 'isa', 'duha', 'tatlo', 'apat', 'lima', 'anom', 'pito', 'walo', 'siyam']   # CHECK: anom or anum
TEN = 'napulo'
TENS = {2: 'duha ka pulo',     # CHECK: "kaluhaan" is the old word, but it never appears in our text
        3: 'katluan', 4: 'kap-atan', 5: 'kalim-an', 6: 'kan-uman',
        7: 'kapituan', 8: 'kawaluan', 9: 'kasiyaman'}
BIG = [(10 ** 9, 'bilyon'), (10 ** 6, 'milyon'), (1000, 'libo'), (100, 'gatos')]
ZERO = 'sero'
ORDINAL = {1: 'una', 2: 'ikaduha', 3: 'ikatlo', 4: 'ikaapat', 5: 'ikalima', 6: 'ikaanom',
           7: 'ikapito', 8: 'ikawalo', 9: 'ikasiyam', 10: 'ikapulo'}
SPANISH_HOUR = ['', 'una', 'dos', 'tres', 'kwatro', 'singko', 'seis', 'siyete', 'otso', 'nuwebe',
                'diyes', 'onse', 'dose']   # "alas tres" = 3 o'clock


def _under_100(n):
    if n < 10:
        return ONES[n]
    if n == 10:
        return TEN
    if n < 20:
        return f'{TEN} kag {ONES[n - 10]}'
    t, u = divmod(n, 10)
    return TENS[t] + (f' kag {ONES[u]}' if u else '')


def cardinal(n):
    """0 <= n < 10**12 -> Hiligaynon words, e.g. 2026 -> 'duha ka libo kag duha ka pulo kag anom'."""
    if n == 0:
        return ZERO
    parts, rest = [], n
    for value, word in BIG:
        if rest >= value:
            k, rest = divmod(rest, value)
            parts.append(f'{cardinal(k)} ka {word}')
    if rest:
        parts.append(_under_100(rest))
    if len(parts) == 1:
        return parts[0]
    return ' '.join(parts[:-1]) + ' kag ' + parts[-1]


def digits(s):
    """Read digit by digit (phone numbers, codes)."""
    return ' '.join(ZERO if d == '0' else ONES[int(d)] for d in s)


def number_words(s):
    """One number as written ('15,113', '12.7', '007') -> words."""
    s = s.replace(',', '')
    if '.' in s:
        a, b = s.split('.', 1)
        return f'{number_words(a or "0")} punto {digits(b)}'
    if (len(s) > 1 and s.startswith('0')) or len(s) > 12:
        return digits(s)
    return cardinal(int(s))


def _keep_case(original, words):
    return words[0].upper() + words[1:] if original[:1].isupper() else words


NUM = r'\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?'
_RULES = [
    # ika-3 / ika 3 -> ikatlo ; ika-25 -> ika-duha ka pulo kag lima
    (re.compile(r'\b[Ii]ka[- ]?(\d+)\b'),
     lambda m: _keep_case(m.group(0), ORDINAL.get(int(m.group(1)), f'ika-{number_words(m.group(1))}'))),
    # alas 3 / alas 3:30 -> alas tres / alas tres kag katluan ka minuto
    (re.compile(r'\b([Aa]las) (\d{1,2})(?::(\d{2}))?\b'),
     lambda m: m.group(1) + ' ' + (SPANISH_HOUR[int(m.group(2))] if 1 <= int(m.group(2)) <= 12 else number_words(m.group(2)))
     + (f' kag {number_words(m.group(3).lstrip("0") or "0")} ka minuto' if m.group(3) and m.group(3) != '00' else '')),
    # money: P150 / ₱1,500.50 / Php 20
    (re.compile(r'(?:₱|\bPhp ?|\bP)(' + NUM + r')\b'),
     lambda m: number_words(m.group(1)) + ' ka pesos'),
    # percent
    (re.compile(r'(' + NUM + r') ?%'), lambda m: number_words(m.group(1)) + ' porsiyento'),
    # ranges: 12-17 -> napulo kag duha tubtob napulo kag pito
    (re.compile(r'\b(\d+)[-–](\d+)\b(?!-)'),
     lambda m: f'{number_words(m.group(1))} tubtob {number_words(m.group(2))}'),
    # 21-anyos -> duha ka pulo kag isa ka tuig
    (re.compile(r'\b(\d+)-anyos\b'), lambda m: f'{number_words(m.group(1))} ka tuig'),
    # any other number
    (re.compile(r'(?<![\w.])(' + NUM + r')(?![\w])'), lambda m: number_words(m.group(1))),
]


def numbers_to_words(text):
    for rx, fn in _RULES:
        text = rx.sub(fn, text)
    return re.sub(r'\s{2,}', ' ', text).strip()


if __name__ == '__main__':
    tests = {
        0: 'sero', 1: 'isa', 9: 'siyam', 10: 'napulo', 11: 'napulo kag isa', 19: 'napulo kag siyam',
        20: 'duha ka pulo', 21: 'duha ka pulo kag isa', 30: 'katluan', 45: 'kap-atan kag lima',
        50: 'kalim-an', 99: 'kasiyaman kag siyam', 100: 'isa ka gatos', 101: 'isa ka gatos kag isa',
        150: 'isa ka gatos kag kalim-an', 200: 'duha ka gatos', 1000: 'isa ka libo',
        1250: 'isa ka libo duha ka gatos kag kalim-an', 2026: 'duha ka libo kag duha ka pulo kag anom',
        15113: 'napulo kag lima ka libo isa ka gatos kag napulo kag tatlo',
        1_000_000: 'isa ka milyon', 5_000_000: 'lima ka milyon',
    }
    bad = 0
    for n, want in tests.items():
        got = cardinal(n)
        if got != want:
            bad += 1
            print('FAIL', n, got, '!=', want)
    sents = {
        'May 3 ka bata sa balay.': 'May tatlo ka bata sa balay.',
        'Ang P150 para sa 2 ka tawo.': 'Ang isa ka gatos kag kalim-an ka pesos para sa duha ka tawo.',
        'Sa ika-3 nga adlaw, alas 4 sang hapon.': 'Sa ikatlo nga adlaw, alas kwatro sang hapon.',
        'Alas 7:30 ang miting.': 'Alas siyete kag katluan ka minuto ang miting.',
        'Ang 20-anyos nga Pinay.': 'Ang duha ka pulo ka tuig nga Pinay.',
        'Mga 12-17 anyos ang bata.': 'Mga napulo kag duha tubtob napulo kag pito anyos ang bata.',
        'Nagtaas sang 90% ang presyo.': 'Nagtaas sang kasiyaman porsiyento ang presyo.',
        'May 15,113 ka kaso.': 'May napulo kag lima ka libo isa ka gatos kag napulo kag tatlo ka kaso.',
        'Ang 12.7 milyon ka tawo.': 'Ang napulo kag duha punto pito milyon ka tawo.',
        'Tawgi ang 09171234567.': 'Tawgi ang sero siyam isa pito isa duha tatlo apat lima anom pito.',
        'Ika-25 nga tuig.': 'Ika-duha ka pulo kag lima nga tuig.',
        'Ika-2 nga beses.': 'Ikaduha nga beses.',
        'Wala sang numero diri.': 'Wala sang numero diri.',
    }
    for s, want in sents.items():
        got = numbers_to_words(s)
        if got != want:
            bad += 1
            print('FAIL', repr(s), '->', repr(got), '| want', repr(want))
    print('all tests passed' if not bad else f'{bad} failed')
