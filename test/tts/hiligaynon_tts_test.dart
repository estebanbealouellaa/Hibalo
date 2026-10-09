// Checks the Dart port of the Hiligaynon voice (v4) against the PC script.
// v4_reference.json is made by C:\Hibalo-TTS-Mobile\make_ref_v4.py, which
// imports the functions of generate_tts_v4.py (voice_text, ends_statement,
// split_sentences, split_first, to_ids, trim_edges, even_volume) with their
// default settings and reads voice_seed7.bin with numpy.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_dsp.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_engine.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_text.dart';

dynamic _json(String path) => jsonDecode(File(path).readAsStringSync());

const _models = 'assets/tts/models';

const _paragraph =
    'Sa Sabado, makadto kami sa tiyanggihan kaupod ang akon iloy. '
    'Mabakal kami sang isda, utan, kag prutas para sa amon panyaga. '
    'Pagkatapos sina, mapuli kami sa balay kag magaluto sang adobo. '
    'Malipayon gid ako kon kaupod ko ang akon pamilya.';

/// Same signal as test_signal() in make_ref_v4.py: a quiet hiss (below the speech level) around
/// three swelling tones of different loudness, and a tail that is not a whole
/// 10 ms frame.
Float32List _testSignal() {
  const sr = 16000;
  final out = <double>[];
  void tone(double sec, double f, double amp) {
    final n = (sr * sec).toInt();
    for (var t = 0; t < n; t++) {
      out.add(
        amp * math.sin(math.pi * t / n) * math.sin(2 * math.pi * f * t / sr),
      );
    }
  }

  void hiss(double sec) {
    for (var t = 0; t < (sr * sec).toInt(); t++) {
      out.add(0.004 * math.sin(2 * math.pi * 3001 * t / sr));
    }
  }

  hiss(.25);
  tone(.3, 220, .08);
  hiss(.07);
  tone(.25, 330, .6);
  hiss(.05);
  tone(.4, 180, .2);
  hiss(.3);
  out.addAll(List.filled(77, 0));
  return Float32List.fromList(out);
}

void _expectClose(List<double> got, List want, double tol) {
  expect(got.length, want.length);
  for (var i = 0; i < got.length; i++) {
    expect(got[i], closeTo(want[i] as num, tol), reason: 'index $i');
  }
}

void main() {
  final ref = _json('test/tts/v4_reference.json') as Map<String, dynamic>;
  final vocab = (_json('$_models/vocab.json') as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, (v as num).toInt()),
  );

  /// What the engine feeds the model: [voice text, pause after] per part.
  List<List<Object>> said(String text) {
    final parts = splitSentences(text);
    return [
      for (var i = 0; i < parts.length; i++)
        [
          voiceText(
            parts[i].$1,
            stretchEnd: endsStatement(parts[i].$1, i == parts.length - 1),
          ),
          parts[i].$2,
        ],
    ];
  }

  group('expected values from the spec', () {
    test('Kumusta ka? -> ids', () {
      // A question is never stretched (endsStatement is false for it).
      expect(toIds(voiceText('Kumusta ka?', stretchEnd: false), vocab), [
        0, 28, 0, 41, 0, 7, 0, 11, 0, 8, 0, 11, 0, 5, 0, 10, 0, 0, 0, 41, //
        0, 7, 0, 0, 0, 41, 0, 1, 0, 41, 0, 28, 0,
      ]);
    });

    test('lead-in + question', () {
      expect(said('Maayong aga sa imo, kumusta ka?'), [
        ['— maayong aga sa imo —', 0.2],
        ['— kumusta ka | —', 0.5],
      ]);
    });

    test('paragraph: first sentence cut at its comma, only the end stretched', () {
      expect(said(_paragraph), [
        ['— sa sabado —', 0.2],
        ['— makadto kami sa tiyanggihan kaupod ang akon iloy —', 0.5],
        [
          '— mabakal kami sang isda — utan — kag prutas para sa amon panyaga —',
          0.5,
        ],
        [
          '— pagkatapos sina — mapuli kami sa balay kag magaluto sang adobo —',
          0.5,
        ],
        ['— malipayon gid ako kon kaupod ko ang akon pamilyaa —', 0.5],
      ]);
    });

    test('short statement: last vowel stretched', () {
      expect(said('Salamat gid sa imo'), [
        ['— salamat gid sa imoo —', 0.5],
      ]);
    });

    test('question: never stretched', () {
      expect(said('Kumusta ka?'), [
        ['— kumusta ka | —', 0.5],
      ]);
    });

    test('ends in a consonant: nothing to stretch', () {
      expect(said('Salamat gid'), [
        ['— salamat gid —', 0.5],
      ]);
    });

    test('empty last part: nothing stretched (it still counts as last)', () {
      expect(said('Salamat gid sa imo. ...'), [
        ['— salamat gid sa imo —', 0.5],
        ['', 0.5],
      ]);
    });

    test('long lead-in is cut again (same as the script)', () {
      expect(
        said('Maayong aga sa imo kag sa imo pamilya subong, kumusta ka?'),
        [
          ['— maayong aga sa imo —', 0.2],
          ['— kag sa imo pamilya subong —', 0.2],
          ['— kumusta ka | —', 0.5],
        ],
      );
    });

    test('splitFirst: comma, then clause word, else whole', () {
      // comma: >= 2 words on the left, >= 3 on the right
      expect(splitFirst('Sa Sabado, makadto kami sa tiyanggihan kaupod.'), [
        'Sa Sabado',
        'makadto kami sa tiyanggihan kaupod.',
      ]);
      // comma too early, and no clause word: kept whole
      const early = 'Oo, makadto kami sa tiyanggihan kaupod ang akon iloy.';
      expect(splitFirst(early), [early]);
      // comma too late: cut before the clause word instead
      expect(splitFirst('Makadto kami sa tiyanggihan kag sa balay, ayhan.'), [
        'Makadto kami sa tiyanggihan',
        'kag sa balay, ayhan.',
      ]);
      // 6 words or fewer: never cut
      const short = 'Makadto kami sa balay kag tiyanggihan.';
      expect(splitFirst(short), [short]);
    });

    test('endsStatement', () {
      expect(endsStatement('pamilya.', true), isTrue);
      expect(endsStatement('Salamat gid sa imo', true), isTrue);
      expect(endsStatement('kumusta ka?  ', true), isFalse);
      expect(endsStatement('panyaga.', false), isFalse);
    });

    test('two sentences', () {
      expect(said('Gab-i na. Diin ka makadto?'), [
        ['— gab-i na —', 0.5],
        ['— diin ka makadto | —', 0.5],
      ]);
    });

    test('colon, no comma: one part + fixed spelling', () {
      expect(said('Nagapamangkot siya: diin ang libro?'), [
        ['— nagapamangkott siya — diin ang libro | —', 0.5],
      ]);
    });

    test('ñ and accents', () {
      expect(said('Ang Niño kag ang kapé.'), [
        ['— ang ninyo kag ang kapee —', 0.5],
      ]);
    });

    test('spaced dash becomes a pause', () {
      expect(said('Indi - ido!'), [
        ['— indi — idoo —', 0.5],
      ]);
    });

    test('digits are dropped for now', () {
      expect(voiceText('May 3 ka libro.'), '— may ka libroo —');
      expect(
        voiceText('May 3 ka libro.', stretchEnd: false),
        '— may ka libro —',
      );
    });

    test('settings match the script defaults', () {
      final set = ref['settings'] as Map<String, dynamic>;
      expect(HiligaynonTtsEngine.speed, set['speed']);
      expect(kSentenceGap, set['gap']);
      expect(kQuestionGap, set['question_gap']);
      expect(kPieceGap, set['piece_gap']);
      expect(kFirstMax, set['first_max']);
      expect(set['max_words'], 0, reason: 'long-sentence split is not ported');
      expect(set['end_fix'], 'c');
      expect(set['split_first'], isTrue);
    });
  });

  group('voiceText matches Python', () {
    (ref['voice_text'] as Map<String, dynamic>).forEach((text, want) {
      test(jsonEncode(text), () => expect(voiceText(text), want));
    });
  });

  group('voiceText without the stretch matches Python', () {
    (ref['voice_text_plain'] as Map<String, dynamic>).forEach((text, want) {
      test(jsonEncode(text), () {
        expect(voiceText(text, stretchEnd: false), want);
      });
    });
  });

  group('splitSentences matches Python', () {
    (ref['split'] as Map<String, dynamic>).forEach((text, want) {
      test(jsonEncode(text), () {
        expect([
          for (final (p, gap) in splitSentences(text)) [p, gap],
        ], want);
      });
    });
  });

  group('splitFirst matches Python', () {
    (ref['split_first'] as Map<String, dynamic>).forEach((text, want) {
      test(jsonEncode(text), () => expect(splitFirst(text), want));
    });
  });

  group('what the model is fed matches Python', () {
    (ref['said'] as Map<String, dynamic>).forEach((text, want) {
      test(jsonEncode(text), () => expect(said(text), want));
    });
  });

  group('toIds matches Python', () {
    (ref['ids'] as Map<String, dynamic>).forEach((text, want) {
      test(text, () => expect(toIds(text, vocab), want));
    });
  });

  group('dsp matches numpy', () {
    final dsp = ref['dsp'] as Map<String, dynamic>;
    final signal = _testSignal();
    final step = dsp['even_step'] as int;
    List<double> every(Float32List x) => [
      for (var i = 0; i < x.length; i += step) x[i],
    ];

    test('test signal', () => expect(signal.length, dsp['signal_len']));

    test('trimEdges', () {
      final trimmed = trimEdges(signal);
      expect(trimmed.length, dsp['trim_len']);
      expect(trimmed.offsetInBytes ~/ 4, dsp['trim_start']);
    });

    test('evenVolume after trimEdges', () {
      final out = evenVolume(trimEdges(signal));
      expect(out.length, dsp['even_len']);
      _expectClose(every(out), dsp['even'] as List, 1e-5);
    });

    test('evenVolume on the untrimmed signal', () {
      _expectClose(
        every(evenVolume(signal)),
        dsp['even_untrimmed'] as List,
        1e-5,
      );
    });

    test('silence is left alone', () {
      final quiet = Float32List(4000);
      expect(trimEdges(quiet), same(quiet));
      expect(evenVolume(quiet), same(quiet));
    });
  });

  test('voice_seed7.bin decodes like numpy float16', () {
    final seed = ref['seed'] as Map<String, dynamic>;
    final bytes = File('$_models/voice_seed7.bin').readAsBytesSync();
    final x = decodeFloat16(ByteData.sublistView(bytes));
    expect(x.length, seed['count']);
    _expectClose(x.sublist(0, 12), seed['head'] as List, 0);
    _expectClose(x.sublist(4000, 4012), seed['at_4000'] as List, 0);
    _expectClose(x.sublist(x.length - 12), seed['tail'] as List, 0);
    var sum = 0.0;
    var absSum = 0.0;
    for (final v in x) {
      sum += v;
      absSum += v.abs();
    }
    expect(sum, closeTo(seed['sum'] as num, 1e-6));
    expect(absSum, closeTo(seed['abs_sum'] as num, 1e-6));
  });

  test('float16 special values', () {
    final b = ByteData(10)
      ..setUint16(0, 0x0001, Endian.little) // smallest subnormal
      ..setUint16(2, 0x8200, Endian.little) // -subnormal
      ..setUint16(4, 0x3c00, Endian.little) // 1
      ..setUint16(6, 0xc000, Endian.little) // -2
      ..setUint16(8, 0x7bff, Endian.little); // max
    expect(decodeFloat16(b), [
      math.pow(2, -24),
      -math.pow(2, -15),
      1,
      -2,
      65504,
    ]);
  });

  test('encodeWav header and length', () {
    final wav = encodeWav(Float32List.fromList([0, 0.5, -1, 1]));
    expect(ascii.decode(wav.sublist(0, 4)), 'RIFF');
    expect(wav.length, 44 + 8);
    final data = ByteData.sublistView(wav, 44);
    expect(data.getInt16(2, Endian.little), 16384);
    expect(data.getInt16(4, Endian.little), -32767);
  });
}
