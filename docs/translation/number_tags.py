"""Number placeholders for the Hibalo student model (same as student v1).
protect(src) -> (tagged_src, numbers)   before translating
restore(hyp, numbers) -> text            after translating
"""
import re
NUM_RE = re.compile(r'(?<![\w.,:])\d+(?:[.,:]\d+)*(?![\w]|[.,:]\d)')
TAG_RE = re.compile(r'<n([1-9])>')
MAX_TAGS = 9

def protect(src):
    numbers = []
    def rep(m):
        n = m.group(0)
        if n in numbers:
            return f'<n{numbers.index(n) + 1}>'
        if len(numbers) >= MAX_TAGS:
            return n
        numbers.append(n)
        return f'<n{len(numbers)}>'
    return NUM_RE.sub(rep, src), numbers

def restore(hyp, numbers):
    def rep(m):
        k = int(m.group(1)) - 1
        return numbers[k] if k < len(numbers) else ''
    return re.sub(r'\s{2,}', ' ', TAG_RE.sub(rep, hyp)).strip()
