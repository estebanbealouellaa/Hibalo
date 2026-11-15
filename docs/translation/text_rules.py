"""Input cleanup for the Hibalo translator. The Dart code must do the same before translating:
1. remove accent marks (a with accent -> a), 2. straight quotes, 3. one space between words, trim."""
import re, unicodedata

def normalize(t):
    t = unicodedata.normalize('NFD', str(t))
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    t = t.replace('’', "'").replace('‘', "'").replace('“', '"').replace('”', '"')
    return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', t)).strip()
