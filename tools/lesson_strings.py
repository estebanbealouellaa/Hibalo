"""Filipino lesson text: export the English to CSV for translators, import the translations.

    python tools/lesson_strings.py export "Claude outputs/fil_export"
    python tools/lesson_strings.py import <csv> [<csv> ...]      # writes assets/lessons/*.fil.json
    python tools/lesson_strings.py import --dry-run <csv> ...    # checks only
    python tools/lesson_strings.py check                          # checks the overlay files

Overlay format and keys: see lib/learning/data/lesson_overlay.dart (this script uses the same
keys: nearest object id + the path inside it). Dev tool only, not part of the app.
"""
import csv
import datetime
import json
import os
import re
import sys
from collections import OrderedDict, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LESSONS = os.path.join(ROOT, 'assets', 'lessons')
SETTINGS = 'learning_settings.json'
LEVEL_FILES = OrderedDict([('Beginner', 'beginner_lessons.json'),
                           ('Intermediate', 'intermediate_lessons.json'),
                           ('Advanced', 'advanced_lessons.json')])

# Never translated (ids, files, answers, Hiligaynon, Filipino glosses, speaker names...).
PROTECTED = {
    'id', 'template', 'type', 'kind', 'mode', 'direction', 'optionKind', 'check', 'source', 'sourceLesson',
    'itemIds', 'passagePart', 'screenTemplates', 'lessons', 'after', 'needs', 'afterLevel', 'file',
    'audio', 'answerAudio', 'image', 'icon', 'coverImage',
    'answer', 'accepted', 'tiles', 'wordBank', 'pairs', 'fix',
    'hil', 'fil', 'meaning', 'means', 'modelAnswer', 'audioText', 'transcript',
    'root', 'forms', 'doerForms', 'letter', 'name', 'alt', 'speaker',
}

# Same list as LessonOverlay.translatableFields: the only fields an overlay may change.
TRANSLATABLE = {'title', 'objectives', 'question', 'hint', 'setting', 'situation', 'soundHint', 'cue', 'quote',
                'literal', 'sayTo', 'tone', 'warning', 'leftLabel', 'rightLabel', 'label', 'columns', 'tip', 'why',
                'text', 'prompt', 'bridge', 'explain', 'note', 'changes', 'right', 'wrong', 'options', 'rows'}
# Fields that are always English display text.
ALWAYS = {'title', 'objectives', 'question', 'hint', 'setting', 'situation', 'soundHint', 'cue', 'quote',
          'literal', 'sayTo', 'tone', 'warning', 'leftLabel', 'rightLabel', 'label', 'columns', 'tip', 'why'}
# Fields that hold English or Hiligaynon/Filipino: exported only when the text is English.
MIXED = {'text', 'prompt', 'bridge', 'explain', 'note', 'changes', 'right', 'wrong'}  # not 'sentence': Q03/Q12 check it against the blank and the tiles
# English mixed with Hiligaynon that the language check misses (reviewed by hand, Nov 16).
ALWAYS_KEYS = {'b03_bm.mistakes[0].wrong', 'b12_c1.prompt', 'b13_k1.terms[2].note', 'i04_p08.terms[2].note',
               'i06_p02.rows[4][2]', 'i09_p05.terms[0].note', 'a03_p11.terms[1].note', 'a05_p07.explain',
               'a05_p15.mistakes[1].wrong'}
# Option lists that look English but must stay as they are (Hiligaynon loanwords).
KEEP_OPTIONS = {'a08_q14.options'}

# Lance's decisions (Stage 0, Nov 16): shown in the notes; the Filipino column stays empty.
DECIDED = {
    'Beginner': 'Baguhan', 'Intermediate': 'Katamtaman', 'Advanced': 'Abante', 'Keep practicing': 'Magsanay pa',
}
SPEAKERS = OrderedDict([('Driver', 'Drayber'), ('Man', 'Lalaki'), ('Seller', 'Tindero'), ('Friend', 'Kaibigan'),
                        ('Guard', 'Guwardiya'), ('Server', 'Weyter'), ('Receptionist', 'Receptionist'),
                        ('You', 'Ikaw')])

EN_WORDS = set('''the a an is are was were be been to of in on for with and or but not this that these those
it its you your he she they we my me our their his her them what which who whom where when why how do does did
can will would should could say says said means mean word words sentence phrase answer correct right wrong use
used using also only one two three more most than then there here if like as by from about after before tap
type write read listen choose pick match each every all some yes very much many lesson part quiz question
example examples note tip same different friend morning afternoon evening family people person someone
something sounds sound start end ending first last next little small big good bad new old want wants asks ask
tell tells call calls show shows give gives make makes go goes come comes get gets know see hear look out up
just still even never always often usually because so too also into over under who's it's don't doesn't isn't
you're they're can't won't
filipino hiligaynon english tagalog cebuano ilonggo kinaray'''.split())
# Table columns in these languages hold words, not English to translate.
LANGUAGE_COLUMNS = {'Hiligaynon', 'Filipino', 'Cebuano', 'Kinaray-a', 'Tagalog', 'Ilonggo'}
HF_WORDS = set('''ang sang sa ng si ni nga ako ka ko mo siya kami kita kamo sila ini ina ato amo man gid na pa ba
mga ay ito iyan iyon akin ikaw tayo kayo hindi indi wala may at kag'''.split())


_VOCAB = None


def hil_fil_vocabulary():
    """Every word used in the lessons' Hiligaynon and Filipino fields (minus common English words)."""
    global _VOCAB
    if _VOCAB is None:
        words = set()
        for file in LEVEL_FILES.values():
            walk_strings(load(file), lambda k, field, v, o: words.update(re.findall(r"[a-z']+", v.lower()))
                         if field in ('hil', 'fil', 'meaning', 'means', 'accepted', 'tiles', 'answer', 'modelAnswer',
                                      'pairs', 'wordBank', 'forms', 'doerForms', 'root', 'alt', 'transcript') else None)
        _VOCAB = (words | HF_WORDS) - EN_WORDS
    return _VOCAB


def is_english(text):
    """English when it has more English-looking words than Hiligaynon/Filipino ones (*…* and quotes skipped)."""
    t = re.sub(r'\*[^*]*\*', ' ', text)
    words = re.findall(r"[A-Za-z']+", re.sub(r'"[^"]*"|“[^”]*”', ' ', t).lower())
    if not words:  # the whole text is a quotation: judge what's inside
        words = re.findall(r"[A-Za-z']+", t.lower())
    if not words:
        return False
    vocab = hil_fil_vocabulary()
    hf = sum(w in vocab for w in words)
    en = sum(w in EN_WORDS or (w not in vocab and len(w) > 2) for w in words)
    return en > hf


# --- keys (same walk as LessonOverlay.forEachString) -------------------------------------------

def walk_strings(node, visit, ident='', path='', field='', parent=None):
    """visit(key, field, value, node_with_id, container, index_or_key)"""
    if isinstance(node, dict):
        if isinstance(node.get('id'), str):
            ident, path, parent = node['id'], '', node
        for k, v in node.items():
            walk_strings(v, visit, ident, k if not path else f'{path}.{k}', k, parent if parent is not None else node)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk_strings(v, visit, ident, f'{path}[{i}]', field, parent)
    elif isinstance(node, str):
        visit(f'{ident}.{path}' if ident else path, field, node, parent)


def load(name):
    with open(os.path.join(LESSONS, name), encoding='utf-8') as f:
        return json.load(f)


def strings_of(data):
    out = OrderedDict()
    walk_strings(data, lambda key, field, value, owner: out.__setitem__(key, (field, value, owner)))
    return out


# --- what to export ----------------------------------------------------------------------------

def table_english_columns(table):
    """Indexes of table columns whose cells are English (not Hiligaynon, not Filipino)."""
    cols = table.get('columns') or []
    hil = set(table.get('hilColumns') or [])
    out = set()
    for i, header in enumerate(cols):
        if i in hil or header in LANGUAGE_COLUMNS:
            continue
        cells = [r[i] for r in table.get('rows', []) if isinstance(r, list) and i < len(r) and isinstance(r[i], str) and r[i].strip()]
        if header == 'English' or (cells and sum(is_english(c) for c in cells) * 2 > len(cells)):
            out.add(i)
    return out


def select(data, file):
    """(key, field, English, owner) for every display text to translate in one lesson file."""
    picked = []
    option_lists = defaultdict(list)
    tables = {}

    def find_tables(node):
        if isinstance(node, dict):
            if isinstance(node.get('id'), str) and 'columns' in node and 'rows' in node:
                tables[node['id']] = table_english_columns(node)
            for v in node.values():
                find_tables(v)
        elif isinstance(node, list):
            for v in node:
                find_tables(v)

    find_tables(data)
    for key, (field, value, owner) in strings_of(data).items():
        if field not in TRANSLATABLE or not value.strip():
            continue
        if file != SETTINGS and key == f"{data.get('id')}.title":
            continue  # the level name: exported with the settings (it must match there)
        if field == 'options':
            option_lists[key.rsplit('[', 1)[0]].append((key, field, value, owner))
            continue
        if field == 'rows':
            m = re.match(r'^(.*)\.rows\[(\d+)\]\[(\d+)\]$', key)
            hil_cols = set((owner or {}).get('hilColumns') or [])
            cols = (owner or {}).get('columns') or []
            col = int(m.group(3)) if m else -1
            in_language_column = 0 <= col < len(cols) and cols[col] in LANGUAGE_COLUMNS
            if m and (col in tables.get(m.group(1), set())
                      or (col not in hil_cols and not in_language_column and is_english(value))):
                picked.append((key, field, value, owner))
            continue
        if field in ALWAYS or key in ALWAYS_KEYS or (field in MIXED and is_english(value)):
            picked.append((key, field, value, owner))
    for list_key, items in option_lists.items():
        if list_key in KEEP_OPTIONS:
            continue
        if any(is_english(v) for _, _, v, _ in items):
            picked.extend(items)
    return picked


# --- context, length, notes --------------------------------------------------------------------

def context(key, field, owner):
    if owner is None:
        return ''
    if field == 'options':
        opts = owner.get('options') or []
        ans = owner.get('answer')
        shown = ' / '.join(f'{o}{"  ✓" if i == ans else ""}' for i, o in enumerate(opts))
        q = owner.get('prompt') or owner.get('question') or owner.get('situation') or ''
        return f'Q: {q} || options: {shown}'
    if field == 'rows':
        m = re.search(r'\.rows\[(\d+)\]', key)
        if m:
            row = owner['rows'][int(m.group(1))]
            hil = set(owner.get('hilColumns') or [])
            cells = [c for i, c in enumerate(row) if i in hil and isinstance(c, str)]
            return 'Hiligaynon: ' + ' / '.join(cells) if cells else ''
    if field in ('right', 'wrong'):
        other = owner.get('wrong' if field == 'right' else 'right')
        return f'{"wrong" if field == "right" else "right"}: {other}' if isinstance(other, str) else ''
    for f in ('hil', 'sentence', 'text', 'audioText'):
        v = owner.get(f)
        if isinstance(v, str) and v.strip() and f != field and not is_english(v):
            return f'Hiligaynon: {v}'
    return ''


CAPS = {'columns': 18, 'label': 16, 'tone': 18, 'sayTo': 34, 'leftLabel': 34, 'rightLabel': 34, 'speaker': 14,
        'objectives': 80, 'soundHint': 30}


def max_length(field, key, english):
    n = len(english)
    if field == 'title':
        if re.match(r'^[a-z]+\.title$', key):
            return 14  # level tab
        if '.unit.title' in key or '.units[' in key:
            return 32
        if re.match(r'^[bia]\d\d\.title$', key):
            return 42  # lesson row / detail
        return max(n + 8, 34)
    if field in CAPS:
        return max(CAPS[field], n)
    if field == 'options':
        return max(n + 12, int(n * 1.3))
    return max(n + 15, int(n * 1.35))


def notes(field, key, english, owner):
    out = []
    if field == 'options' and owner is not None:
        opts = owner.get('options') or []
        i = int(re.search(r'\[(\d+)\]$', key).group(1))
        out.append(f'option {i + 1} of {len(opts)}{" (correct)" if owner.get("answer") == i else ""}; keep the order')
    if re.search(r'\*[^*]+\*', english):
        out.append('keep every *…* part exactly (Hiligaynon)')
    if field != 'soundHint' and quoted_non_english(english):
        out.append('keep quoted Hiligaynon/Filipino exactly')
    plain = re.sub(r'\*[^*]*\*', '', english)
    if re.search(r'\bFilipino\b', plain) and field not in ('columns', 'title'):
        out.append('compares with Filipino: reword for a Filipino reader')
    if re.search(r'\bEnglish\b', plain) or field == 'soundHint':
        out.append('use a Filipino example instead of English (Lance)')
    if '.units[' in key or '.unit.title' in key:
        out.append('unit name: one translation for all its lessons')
    if field == 'columns' and english == 'English':
        out.append('Lance: this column becomes "Filipino"')
    if field == 'rows' and owner is not None and (owner.get('columns') or [None])[0] == 'English':
        out.append('Lance: English column becomes Filipino (Magandang umaga / ano / saan / wala)')
    if english in DECIDED:
        out.append(f'decided: {DECIDED[english]}')
    return '; '.join(out)


# --- export ------------------------------------------------------------------------------------

# Filipino left empty = the text stays as it is (right for names, Hiligaynon and loanwords).
HEADER = ['keys', 'level', 'lessons', 'part / question ids', 'fields', 'English', 'Hiligaynon context',
          'max length', 'Filipino', 'notes', 'uses']


def lesson_of(key):
    m = re.match(r'^([bia]\d\d)', key)
    return m.group(1) if m else ''


def node_of(key):
    head = key.split('.', 1)[0]
    return head if re.match(r'^[bia]\d\d_', head) else ''


def export(outdir):
    os.makedirs(outdir, exist_ok=True)
    summary = []
    settings = load(SETTINGS)
    for level, file in LEVEL_FILES.items():
        data = load(file)
        groups = OrderedDict()
        for key, field, value, owner in select(data, file):
            g = groups.setdefault(value, {'keys': [], 'fields': [], 'ctx': [], 'notes': [], 'max': 0})
            g['keys'].append(key)
            g['fields'].append(field)
            c = context(key, field, owner)
            if c and c not in g['ctx']:
                g['ctx'].append(c)
            n = notes(field, key, value, owner)
            if n and n not in g['notes']:
                g['notes'].append(n)
            limit = max_length(field, key, value)
            g['max'] = limit if not g['max'] else min(g['max'], limit)
        path = os.path.join(outdir, f'{file.split("_")[0]}_fil.csv')
        words = 0
        with open(path, 'w', encoding='utf-8-sig', newline='') as f:
            w = csv.writer(f)
            w.writerow(HEADER)
            for english, g in groups.items():
                words += len(re.findall(r"[A-Za-z][A-Za-z'’-]*", re.sub(r'\*[^*]*\*', ' ', english)))
                w.writerow([' | '.join(g['keys']), level,
                            ' '.join(sorted({lesson_of(k) for k in g['keys']} - {''})),
                            ' '.join(sorted({node_of(k) for k in g['keys']} - {''})),
                            ' '.join(sorted(set(g['fields']))), english,
                            ' || '.join(g['ctx'][:3]) + (' || …' if len(g['ctx']) > 3 else ''),
                            g['max'], '', ' / '.join(g['notes']), len(g['keys'])])
        summary.append((path, level, len(groups), sum(len(g['keys']) for g in groups.values()), words))

    # Settings: level names (also in each level file), result titles, speaker names.
    path = os.path.join(outdir, 'settings_fil.csv')
    rows = []
    for lvl in settings['levels']:
        keys = [f'{SETTINGS}#{lvl["id"]}.title']
        if lvl.get('file'):
            keys.append(f'{os.path.basename(lvl["file"])}#{lvl["id"]}.title')
        rows.append([' | '.join(keys), 'Settings', '', '', 'title', lvl['title'], '', 14, '',
                     notes('title', '', lvl['title'], None) + '; level tab and chips', len(keys)])
    for i, tier in enumerate(settings['settings']['resultTiers']):
        if tier['title'] in DECIDED:  # Perpekto! / Maayo gid! are Hiligaynon on purpose
            rows.append([f'{SETTINGS}#settings.resultTiers[{i}].title', 'Settings', '', '', 'title', tier['title'],
                         '', 24, '', notes('title', '', tier['title'], None) + '; quiz result title', 1])
    used = set()
    for file in LEVEL_FILES.values():
        walk_strings(load(file), lambda key, field, value, owner: used.add(value) if field == 'speaker' else None)
    for name, decided in SPEAKERS.items():
        if name in used:
            rows.append([f'{SETTINGS}#speakers.{name}', 'Settings', '', '', 'speaker name', name, '', 14, '',
                         f'decided: {decided}; display only (the JSON keeps "{name}")', 1])
    with open(path, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f)
        w.writerow(HEADER)
        w.writerows(rows)
    summary.append((path, 'Settings', len(rows), sum(r[-1] for r in rows), sum(len(r[5].split()) for r in rows)))
    for path, level, groups, keys, words in summary:
        print(f'{os.path.relpath(path, ROOT)}: {groups} distinct English texts, {keys} keys, {words} words')
    return summary


# --- import / check ----------------------------------------------------------------------------

def markup(text):
    return sorted(re.findall(r'\*[^*]+\*', text))


def quoted_non_english(text):
    return [q for q in re.findall(r'"([^"]+)"|“([^”]+)”', text) for q in q if q and not is_english(q)]


def validate_entries(file, entries, data):
    """Errors and warnings for {key: (en, fil)} against one English file (mirrors LessonOverlay.validate)."""
    errors, warnings = [], []
    strings = strings_of(data)
    speakers = set()
    for f in LEVEL_FILES.values():
        walk_strings(load(f), lambda k, fld, v, o: speakers.add(v) if fld == 'speaker' else None)
    for key, (en, fil) in entries.items():
        if key.startswith('speakers.'):
            name = key[len('speakers.'):]
            if file != SETTINGS or name != en or name not in speakers:
                errors.append(f'{file} {key}: not a speaker name')
            continue
        if key not in strings:
            errors.append(f'{file} {key}: no such text in the English file')
            continue
        field, english, owner = strings[key]
        if field not in TRANSLATABLE:
            errors.append(f'{file} {key}: "{field}" can\'t be translated')
        if english != en:
            errors.append(f'{file} {key}: stale (the English is now "{english}")')
        if not fil.strip():
            errors.append(f'{file} {key}: Filipino is empty')
            continue
        if markup(english) != markup(fil):
            errors.append(f'{file} {key}: *Hiligaynon* parts changed: {markup(english)} -> {markup(fil)}')
        for q in quoted_non_english(english):
            if q not in fil:
                warnings.append(f'{file} {key}: quoted "{q}" not found in the Filipino')
    # options stay different from each other
    lists = defaultdict(dict)
    for key, (field, english, owner) in strings.items():
        if field == 'options':
            lists[key.rsplit('[', 1)[0]][key] = english
    for lst, opts in lists.items():
        after = [entries.get(k, (None, v))[1] or v for k, v in opts.items()]
        if len(set(after)) < len(after) and len(set(opts.values())) == len(opts):
            errors.append(f'{file} {lst}: two options would be the same: {after}')
    return errors, warnings


def overlay_path(file):
    return os.path.join(LESSONS, file[:-len('.json')] + '.fil.json')


def read_overlay(file):
    p = overlay_path(file)
    if not os.path.exists(p):
        return OrderedDict()
    with open(p, encoding='utf-8') as f:
        raw = json.load(f).get('strings', {})
    return OrderedDict((k, (v['en'], v['fil'])) for k, v in raw.items())


def write_overlay(file, entries):
    data = {'_meta': {'language': 'fil', 'source': file,
                      'note': 'Filipino lesson text, made with tools/lesson_strings.py import. Keys: see lib/learning/data/lesson_overlay.dart.',
                      'updated': datetime.date.today().isoformat(), 'count': len(entries)},
            'strings': OrderedDict((k, {'en': en, 'fil': fil}) for k, (en, fil) in sorted(entries.items()))}
    with open(overlay_path(file), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def import_csvs(paths, dry_run=False):
    default_file = {**{lvl: f for lvl, f in LEVEL_FILES.items()}, 'Settings': SETTINGS}
    new = defaultdict(OrderedDict)
    too_long = []
    for p in paths:
        with open(p, encoding='utf-8-sig', newline='') as f:
            for row in csv.DictReader(f):
                fil = (row.get('Filipino') or '').strip()
                if not fil:
                    continue
                if row.get('max length', '').isdigit() and len(fil) > int(row['max length']):
                    too_long.append(f'{row["keys"].split(" | ")[0]}: {len(fil)} > {row["max length"]} characters')
                for k in row['keys'].split(' | '):
                    file, key = (k.split('#', 1) if '#' in k else (default_file[row['level']], k))
                    new[file][key] = (row['English'], fil)
    errors, warnings = [], [f'longer than the hint: {t}' for t in too_long]
    for file, entries in new.items():
        merged = read_overlay(file)
        merged.update(entries)
        e, w = validate_entries(file, merged, load(file))
        errors += e
        warnings += w
        new[file] = merged
    for w in warnings:
        print('warning:', w)
    if errors:
        for e in errors:
            print('ERROR:', e)
        print(f'{len(errors)} errors: nothing written.')
        return 1
    for file, entries in new.items():
        if dry_run:
            print(f'{file}: {len(entries)} texts OK (dry run, nothing written)')
            continue
        write_overlay(file, entries)
        print(f'{os.path.relpath(overlay_path(file), ROOT)}: {len(entries)} texts')
    return 0


def check():
    bad = 0
    for file in [SETTINGS, *LEVEL_FILES.values()]:
        entries = read_overlay(file)
        if not entries:
            continue
        e, w = validate_entries(file, entries, load(file))
        for x in w:
            print('warning:', x)
        for x in e:
            print('ERROR:', x)
        bad += len(e)
        print(f'{file}: {len(entries)} texts, {len(e)} errors')
    return 1 if bad else 0


if __name__ == '__main__':
    if len(sys.argv) >= 3 and sys.argv[1] == 'export':
        export(sys.argv[2])
    elif len(sys.argv) >= 3 and sys.argv[1] == 'import':
        args = [a for a in sys.argv[2:] if a != '--dry-run']
        sys.exit(import_csvs(args, dry_run='--dry-run' in sys.argv))
    elif len(sys.argv) == 2 and sys.argv[1] == 'check':
        sys.exit(check())
    else:
        print(__doc__)
        sys.exit(2)
