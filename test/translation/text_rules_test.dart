import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/translation/number_tags.dart';
import 'package:hibalo_app/services/translation/phrase_lookup.dart';
import 'package:hibalo_app/services/translation/postprocess.dart';
import 'package:hibalo_app/services/translation/text_rules.dart';

const _dataDir = 'assets/translation/data';

void main() {
  group('normalizeText (text_rules.py)', () {
    const cases = {
      'Kumustá   ka?': 'Kumusta ka?',
      '“Hello” ‘there’': '"Hello" \'there\'',
      '  a\t\nb  ': 'a b',
      'niño': 'nino',
      'ÁÉÍ': 'AEI',
    };
    cases.forEach((input, want) {
      test(input, () => expect(normalizeText(input), want));
    });
  });

  group('splitSentences', () {
    const cases = <String, List<String>>{
      'Kumusta ka? Maayo man. Salamat!': [
        'Kumusta ka?',
        'Maayo man.',
        'Salamat!',
      ],
      'Wala sang punto': ['Wala sang punto'],
      'May 1.5 kilo. Tapos na.': ['May 1.5 kilo.', 'Tapos na.'],
      'Siling niya, "Diin ka?" Nagsabat ako.': [
        'Siling niya, "Diin ka?"',
        'Nagsabat ako.',
      ],
      'Ano?! Hala...': ['Ano?!', 'Hala...'],
      'Isa\nDuha. Tatlo': ['Isa\nDuha.', 'Tatlo'],
      '   ': [],
    };
    cases.forEach((input, want) {
      test(input, () => expect(splitSentences(input), want));
    });
  });

  group('scanSegments', () {
    test('keeps list lines apart', () {
      expect(
        scanSegments([
          ['ADOBO', 'SINIGANG', 'P150'],
        ]),
        ['ADOBO', 'SINIGANG', 'P150'],
      );
    });
    test('joins a sentence wrapped over two lines', () {
      expect(
        scanSegments([
          ['Maayong aga sa tanan nga', 'mga bisita.'],
        ]),
        ['Maayong aga sa tanan nga mga bisita.'],
      );
    });
    test('a line with end punctuation is finished', () {
      expect(
        scanSegments([
          ['Bukas na.', 'sarado bukas'],
        ]),
        ['Bukas na.', 'sarado bukas'],
      );
    });
    test('blocks never join, and empty lines are skipped', () {
      expect(
        scanSegments([
          ['Isa', ' '],
          ['duha'],
          [],
        ]),
        ['Isa', 'duha'],
      );
    });
  });

  group('SpellingMap', () {
    final map = SpellingMap({'sia': 'siya', 'kuwarta': 'kwarta', "g'wa": 'gwa'});

    test('replaces whole words and keeps the first capital', () {
      expect(map.apply('Sia may kuwarta.'), 'Siya may kwarta.');
      expect(map.apply('siawa'), 'siawa');
    });
    test('works next to punctuation', () {
      expect(map.apply('(sia), "Kuwarta"?'), '(siya), "Kwarta"?');
    });
    test('handles words with an apostrophe', () {
      expect(map.apply("G'wa ka"), 'Gwa ka');
    });
    test('loads the v2 file', () {
      final file = File('$_dataDir/hil_spelling_map_v2.tsv').readAsStringSync();
      final loaded = SpellingMap.fromTsv(file);
      expect(loaded.standardOf.length, 807);
      expect(loaded.standardOf['abian'], 'abyan');
    });
  });

  group('protectNumbers / restoreNumbers (number_tags.py)', () {
    const cases = <String, (String, List<String>)>{
      'May 3 na bata sa bahay.': ('May <n1> na bata sa bahay.', ['3']),
      '3 at 3 at 4': ('<n1> at <n1> at <n2>', ['3', '4']),
      'Sa 1,500.50 at 12:30 ng 2.': (
        'Sa <n1> at <n2> ng <n3>.',
        ['1,500.50', '12:30', '2'],
      ),
      'v2 a3 3a': ('v2 a3 3a', []),
      'Oo, 5.': ('Oo, <n1>.', ['5']),
      'abc': ('abc', []),
      '1 2 3 4 5 6 7 8 9 10 11 1': (
        '<n1> <n2> <n3> <n4> <n5> <n6> <n7> <n8> <n9> 10 11 <n1>',
        ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
      ),
    };
    cases.forEach((input, want) {
      test(input, () {
        final (tagged, numbers) = protectNumbers(input);
        expect(tagged, want.$1);
        expect(numbers, want.$2);
      });
    });

    test('restore drops unknown tags and double spaces', () {
      expect(restoreNumbers('<n1>  at <n2> <n9>', ['3', '4']), '3 at 4');
    });
  });

  group('matchStyle (postprocess.py)', () {
    const cases = [
      ('Diin ang banyo?', 'nasaan ang banyo', 'Nasaan ang banyo?'),
      ('Patayin ang ilaw', 'patya ang suga', 'Patya ang suga'),
      ('Salamat!', 'Salamat', 'Salamat!'),
      ('Pila ini?', 'Magkano ito.', 'Magkano ito?'),
      ('patya ang suga', 'Patayin mo ang ilaw.', 'Patayin mo ang ilaw.'),
      ('"Kalantaw ka na?"', '"napanood mo na ba"', '"Napanood mo na ba"?'),
      ('3 ka bata ang nag-abot.', '3 bata ang dumating', '3 bata ang dumating.'),
      ('Ok.', 'Sige!', 'Sige!'),
    ];
    for (final (source, output, want) in cases) {
      test(source, () => expect(matchStyle(source, output), want));
    }
    test('accented capitals in the raw input count as capitals', () {
      expect(matchStyle('Ñoño', 'bata'), 'Bata');
    });
  });

  group('PhraseList (phrase_lookup.py)', () {
    final phraseTsv = File(
      '$_dataDir/hibalo_phrase_list_v1.tsv',
    ).readAsStringSync();
    final spelling = SpellingMap.fromTsv(
      File('$_dataDir/hil_spelling_map_v2.tsv').readAsStringSync(),
    );
    final list = PhraseList.fromTsv(phraseTsv, spelling);

    test('has every row and rebuilds every key from input_example', () {
      final rows = parseTsv(phraseTsv);
      expect(rows.length, 8806);
      final bad = rows.where(
        (r) =>
            list.key(
              r['input_example']!,
              fromHiligaynon: r['direction'] == 'hil2fil',
            ) !=
            r['key'],
      );
      expect(bad.map((r) => r['input_example']), isEmpty);
    });

    const lookups = <(String, bool, String?)>[
      ('Patayin ang ilaw.', false, 'patya ang suga'),
      ('PATAYIN ANG ILAW', false, 'patya ang suga'),
      ('Naano imo tiil?', true, 'Ano ang nangyari sa paa mo?'),
      ('Maayong aga!', true, 'magandang umaga'),
      ('Kumusta ka?', false, 'kumusta ka?'),
      ('Diin ang banyo?', true, null),
      ('Salamat gid', true, 'maraming salamat'),
      ('Indi sia magkadto', true, null),
    ];
    for (final (text, fromHiligaynon, want) in lookups) {
      test(text, () {
        final found = list.lookup(text, fromHiligaynon: fromHiligaynon);
        expect(found?.output, want);
      });
    }

    test('useEvalRows false switches off exactly the in_eval_set rows', () {
      final rows = parseTsv(phraseTsv);
      final evalRows = rows.where((r) => r['in_eval_set'] == '1').toList();
      final scoring = PhraseList.fromTsv(
        phraseTsv,
        spelling,
        useEvalRows: false,
      );
      expect(evalRows.length, 337);
      expect(scoring.length, list.length - evalRows.length);
      for (final row in evalRows) {
        final fromHiligaynon = row['direction'] == 'hil2fil';
        expect(
          scoring.lookup(row['input_example']!, fromHiligaynon: fromHiligaynon),
          isNull,
          reason: row['input_example'],
        );
      }
    });

    test('useDictionaryWords false removes the dictionary rows', () {
      final noWords = PhraseList.fromTsv(
        phraseTsv,
        spelling,
        useDictionaryWords: false,
      );
      expect(list.length - noWords.length, 2249);
    });
  });
}
