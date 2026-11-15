"""Copy the end punctuation and the first capital letter from the user's input to the translation.

    from postprocess import match_style
    match_style("Diin ang banyo?", "nasaan ang banyo")   -> "Nasaan ang banyo?"
    match_style("patya ang suga", "Patayin mo ang ilaw.") -> "Patayin mo ang ilaw."   (input lowercase: output unchanged)

Run it on the final text shown to the user (model output AND phrase-list output), after numbers are restored.
"""
import re

END = '.?!'
_OPEN = '"\'(['
_CLOSE = '"\')]'


def _core_end(t):
    """Last character, ignoring closing quotes/brackets."""
    t = t.rstrip()
    while t and t[-1] in _CLOSE:
        t = t[:-1].rstrip()
    return t[-1] if t else ''


def _first_letter_index(t):
    for i, c in enumerate(t):
        if c.isalpha():
            return i
        if c not in _OPEN and not c.isspace():
            return -1          # starts with a digit or symbol: leave it
    return -1


def match_style(src, out):
    if not out.strip():
        return out
    out = out.strip()
    s_end, o_end = _core_end(src), _core_end(out)
    # 1) end punctuation
    if s_end in END:
        if o_end not in END:
            out = out + s_end                              # add the missing ? ! .
        elif s_end == '?' and o_end != '?':
            i = out.rstrip().rfind(o_end)
            out = out[:i] + '?' + out[i + 1:]              # question stays a question
    # 2) first capital
    si, oi = _first_letter_index(src), _first_letter_index(out)
    if si >= 0 and oi >= 0 and src[si].isupper() and out[oi].islower():
        out = out[:oi] + out[oi].upper() + out[oi + 1:]
    return out


if __name__ == '__main__':
    cases = [('Diin ang banyo?', 'nasaan ang banyo', 'Nasaan ang banyo?'),
             ('Patayin ang ilaw', 'patya ang suga', 'Patya ang suga'),
             ('Salamat!', 'Salamat', 'Salamat!'),
             ('Pila ini?', 'Magkano ito.', 'Magkano ito?'),
             ('patya ang suga', 'Patayin mo ang ilaw.', 'Patayin mo ang ilaw.'),
             ('"Kalantaw ka na?"', '"napanood mo na ba"', '"Napanood mo na ba"?'),
             ('3 ka bata ang nag-abot.', '3 bata ang dumating', '3 bata ang dumating.'),
             ('Ok.', 'Sige!', 'Sige!')]
    bad = 0
    for s, o, want in cases:
        got = match_style(s, o)
        if got != want:
            bad += 1; print('FAIL', repr(s), repr(o), '->', repr(got), 'want', repr(want))
    print('all tests passed' if not bad else f'{bad} failed')
