// Checks the Dart tokenizer against the real SentencePiece library.
// spm_reference.json holds ids made by Python sentencepiece from spm.model:
// the normalized and number-tagged text of all 300 CSV rows, odd characters,
// and random strings.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/translation/sentencepiece_tokenizer.dart';

void main() {
  final tokenizer = SentencePieceTokenizer.fromBytes(
    File('assets/translation/models/spm.model').readAsBytesSync(),
  );
  final reference =
      jsonDecode(File('test/translation/spm_reference.json').readAsStringSync())
          as Map<String, dynamic>;

  test('reads the whole vocabulary', () {
    expect(tokenizer.vocabSize, 16000);
    expect(tokenizer.unkId, 2);
  });

  test('tags and number placeholders come out as single ids', () {
    expect(tokenizer.encode('>>hil<<'), contains(3));
    expect(tokenizer.encode('>>fil<<'), contains(4));
    for (var k = 1; k <= 9; k++) {
      expect(tokenizer.encode('May <n$k> na'), contains(4 + k));
    }
    expect(tokenizer.encode('May <n1> na bata'), [140, 24, 5, 21, 146]);
  });

  test('encode matches the real library', () {
    final cases = reference['encode'] as List;
    final bad = <String>[];
    for (final c in cases.cast<Map<String, dynamic>>()) {
      final text = c['text'] as String;
      final want = (c['ids'] as List).cast<int>();
      final got = tokenizer.encode(text);
      if (got.join(' ') != want.join(' ')) {
        bad.add('${jsonEncode(text)}\n  got  $got\n  want $want');
      }
    }
    expect(
      bad.length,
      0,
      reason: '${bad.length} of ${cases.length} differ:\n'
          '${bad.take(8).join('\n')}',
    );
  });

  test('decode matches the real library', () {
    final cases = reference['decode'] as List;
    for (final c in cases.cast<Map<String, dynamic>>()) {
      final ids = (c['ids'] as List).cast<int>();
      expect(tokenizer.decode(ids), c['text'], reason: '$ids');
    }
  });
}
