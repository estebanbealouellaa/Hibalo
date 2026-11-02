// Copies the end punctuation and the first capital letter from the user's
// input to the translation. Dart port of docs/translation/postprocess.py.
// Run it on the final text (model output AND phrase-list output), after the
// numbers are restored.

const String _end = '.?!';
const String _open = '"\'([';
const String _close = '"\')]';

final RegExp _letter = RegExp(r'^\p{L}$', unicode: true);
final RegExp _upper = RegExp(r'^\p{Lu}$', unicode: true);
final RegExp _lower = RegExp(r'^\p{Ll}$', unicode: true);
final RegExp _space = RegExp(r'^\s$');

/// Last character, ignoring closing quotes and brackets.
String _coreEnd(String text) {
  var t = text.trimRight();
  while (t.isNotEmpty && _close.contains(t[t.length - 1])) {
    t = t.substring(0, t.length - 1).trimRight();
  }
  return t.isEmpty ? '' : t[t.length - 1];
}

/// Where the first letter is, or -1 if the text starts with a digit or symbol.
int _firstLetterIndex(String text) {
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (_letter.hasMatch(c)) return i;
    if (!_open.contains(c) && !_space.hasMatch(c)) return -1;
  }
  return -1;
}

String matchStyle(String source, String output) {
  if (output.trim().isEmpty) return output;
  var out = output.trim();
  final sourceEnd = _coreEnd(source);
  final outEnd = _coreEnd(out);

  // 1) End punctuation.
  if (_end.contains(sourceEnd)) {
    if (!_end.contains(outEnd)) {
      out = out + sourceEnd; // add the missing ? ! .
    } else if (sourceEnd == '?' && outEnd != '?') {
      final i = out.trimRight().lastIndexOf(outEnd);
      out = '${out.substring(0, i)}?${out.substring(i + 1)}'; // stays a question
    }
  }

  // 2) First capital.
  final si = _firstLetterIndex(source);
  final oi = _firstLetterIndex(out);
  if (si >= 0 && oi >= 0 && _upper.hasMatch(source[si]) && _lower.hasMatch(out[oi])) {
    out = out.substring(0, oi) + out[oi].toUpperCase() + out.substring(oi + 1);
  }
  return out;
}
