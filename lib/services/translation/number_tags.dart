// Number placeholders for the translation model. Dart port of
// docs/translation/number_tags.py. Digits are swapped for <n1>..<n9> before
// translating and put back afterwards, so the model can't change them.

final RegExp _number = RegExp(r'(?<![\w.,:])\d+(?:[.,:]\d+)*(?![\w]|[.,:]\d)');
final RegExp _tag = RegExp(r'<n([1-9])>');
final RegExp _extraSpaces = RegExp(r'\s{2,}');

const int _maxTags = 9;

/// Left to right, each new number gets the next tag and a repeated number
/// reuses its tag. After 9 numbers the rest stay as they are.
/// Returns the tagged text and the list of numbers.
(String, List<String>) protectNumbers(String source) {
  final numbers = <String>[];
  final tagged = source.replaceAllMapped(_number, (m) {
    final number = m.group(0)!;
    final known = numbers.indexOf(number);
    if (known >= 0) return '<n${known + 1}>';
    if (numbers.length >= _maxTags) return number;
    numbers.add(number);
    return '<n${numbers.length}>';
  });
  return (tagged, numbers);
}

/// Puts the numbers back. A tag with no number is dropped.
String restoreNumbers(String output, List<String> numbers) {
  final restored = output.replaceAllMapped(_tag, (m) {
    final k = int.parse(m.group(1)!) - 1;
    return k < numbers.length ? numbers[k] : '';
  });
  return restored.replaceAll(_extraSpaces, ' ').trim();
}
