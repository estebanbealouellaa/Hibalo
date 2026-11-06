// Hiligaynon number words for the voice only (port of hil_numbers.py): never on shown text or before translating.

const List<String> _ones = [
  '', 'isa', 'duha', 'tatlo', 'apat', 'lima',
  'anom', // CHECK: anom or anum
  'pito', 'walo', 'siyam',
];
const String _ten = 'napulo';
const Map<int, String> _tens = {
  2: 'duha ka pulo', // CHECK: "kaluhaan" never appears in our text
  3: 'katluan', 4: 'kap-atan', 5: 'kalim-an', 6: 'kan-uman',
  7: 'kapituan', 8: 'kawaluan', 9: 'kasiyaman',
};
const List<(int, String)> _big = [
  (1000000000, 'bilyon'), (1000000, 'milyon'), (1000, 'libo'), (100, 'gatos'),
];
const String _zero = 'sero';
const Map<int, String> _ordinal = {
  1: 'una', 2: 'ikaduha', 3: 'ikatlo', 4: 'ikaapat', 5: 'ikalima',
  6: 'ikaanom', 7: 'ikapito', 8: 'ikawalo', 9: 'ikasiyam', 10: 'ikapulo',
};
const List<String> _spanishHour = [
  '', 'una', 'dos', 'tres', 'kwatro', 'singko', 'seis', 'siyete', 'otso',
  'nuwebe', 'diyes', 'onse', 'dose',
];

String _under100(int n) {
  if (n < 10) return _ones[n];
  if (n == 10) return _ten;
  if (n < 20) return '$_ten kag ${_ones[n - 10]}';
  final unit = n % 10;
  return _tens[n ~/ 10]! + (unit > 0 ? ' kag ${_ones[unit]}' : '');
}

/// 0 <= n < 10^12 -> words. 2026 -> "duha ka libo kag duha ka pulo kag anom".
String cardinal(int n) {
  if (n == 0) return _zero;
  final parts = <String>[];
  var rest = n;
  for (final (value, word) in _big) {
    if (rest >= value) {
      parts.add('${cardinal(rest ~/ value)} ka $word');
      rest %= value;
    }
  }
  if (rest > 0) parts.add(_under100(rest));
  if (parts.length == 1) return parts.first;
  final head = parts.sublist(0, parts.length - 1).join(' ');
  return '$head kag ${parts.last}';
}

/// Reads digit by digit (phone numbers, codes).
String _digits(String s) => s
    .split('')
    .map((d) => d == '0' ? _zero : _ones[int.parse(d)])
    .join(' ');

/// One number as written ("15,113", "12.7", "007") -> words.
String numberWords(String written) {
  final s = written.replaceAll(',', '');
  final dot = s.indexOf('.');
  if (dot >= 0) {
    final whole = s.substring(0, dot);
    return '${numberWords(whole.isEmpty ? '0' : whole)} punto '
        '${_digits(s.substring(dot + 1))}';
  }
  if ((s.length > 1 && s.startsWith('0')) || s.length > 12) return _digits(s);
  return cardinal(int.parse(s));
}

String _keepCase(String original, String words) {
  final first = original.isEmpty ? '' : original[0];
  final isCapital = first != first.toLowerCase();
  return isCapital ? words[0].toUpperCase() + words.substring(1) : words;
}

String _alasRule(Match m) {
  final hour = int.parse(m.group(2)!);
  final minutes = m.group(3);
  final spoken = hour >= 1 && hour <= 12
      ? _spanishHour[hour]
      : numberWords(m.group(2)!);
  var text = '${m.group(1)} $spoken';
  if (minutes != null && minutes != '00') {
    final trimmed = minutes.replaceFirst(RegExp('^0+'), '');
    text += ' kag ${numberWords(trimmed.isEmpty ? '0' : trimmed)} ka minuto';
  }
  return text;
}

const String _num = r'\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?';

/// Same order as the Python file: the special forms first, any other number
/// last.
final List<(RegExp, String Function(Match))> _rules = [
  // ika-3 / ika 3 -> ikatlo ; ika-25 -> ika-duha ka pulo kag lima
  (
    RegExp(r'\b[Ii]ka[- ]?(\d+)\b'),
    (m) {
      // tryParse: a number too long for int just isn't an ordinal.
      final known = _ordinal[int.tryParse(m.group(1)!)];
      return _keepCase(m.group(0)!, known ?? 'ika-${numberWords(m.group(1)!)}');
    },
  ),
  // alas 3 / alas 3:30 -> alas tres / alas tres kag katluan ka minuto
  (RegExp(r'\b([Aa]las) (\d{1,2})(?::(\d{2}))?\b'), _alasRule),
  // money: P150 / ₱1,500.50 / Php 20
  (
    RegExp('(?:₱|\\bPhp ?|\\bP)($_num)\\b'),
    (m) => '${numberWords(m.group(1)!)} ka pesos',
  ),
  (RegExp('($_num) ?%'), (m) => '${numberWords(m.group(1)!)} porsiyento'),
  // ranges: 12-17 -> napulo kag duha tubtob napulo kag pito
  (
    RegExp(r'\b(\d+)[-–](\d+)\b(?!-)'),
    (m) => '${numberWords(m.group(1)!)} tubtob ${numberWords(m.group(2)!)}',
  ),
  // 21-anyos -> duha ka pulo kag isa ka tuig
  (RegExp(r'\b(\d+)-anyos\b'), (m) => '${numberWords(m.group(1)!)} ka tuig'),
  (RegExp('(?<![\\w.])($_num)(?![\\w])'), (m) => numberWords(m.group(1)!)),
];

final RegExp _extraSpaces = RegExp(r'\s{2,}');

/// "May 3 ka bata sa balay." -> "May tatlo ka bata sa balay."
String numbersToWords(String text) {
  var out = text;
  for (final (pattern, spoken) in _rules) {
    out = out.replaceAllMapped(pattern, spoken);
  }
  return out.replaceAll(_extraSpaces, ' ').trim();
}
