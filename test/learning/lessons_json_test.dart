// Loads lessons.json like the app and checks template IDs, item ids, answer indexes and asset paths.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/parts.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/theme/part_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonRepository repo;
  late LessonCatalog catalog;
  late List<Lesson> beginner;

  setUpAll(() async {
    repo = await LessonRepository.load(rootBundle);
    catalog = repo.catalog;
    beginner = catalog.levels.firstWhere((l) => l.id == 'beginner').lessons;
  });

  test('loads all 13 Beginner lessons in order', () {
    expect(catalog.schemaVersion, 7);
    expect(catalog.levels.map((l) => l.id),
        ['beginner', 'intermediate', 'advanced']);
    expect(beginner, hasLength(13));
    expect(beginner.map((l) => l.order), List.generate(13, (i) => i + 1));
    expect(beginner.map((l) => l.id),
        List.generate(13, (i) => 'b${(i + 1).toString().padLeft(2, '0')}'));
  });

  test('settings match the guide', () {
    final s = catalog.settings;
    expect(s.passMark, 0.8);
    expect(s.xp.perCorrect, 10);
    expect(s.xp.lessonComplete, 20);
    expect(s.xp.quickCheck, 5);
    expect(s.timerSeconds, 30);
    expect(s.timedTypes, {
      'multiple_choice', 'listening', 'fill_blank',
      'build_sentence', 'real_situation', 'match_pairs',
    });
    expect(s.tierFor(1.0).title, 'Perpekto!');
    expect(s.tierFor(0.8).title, 'Maayo gid!');
    expect(s.tierFor(0.79).passed, isFalse);
    expect(s.missingPicture, 'assets/images/mascots/firefly_reading.webp');
    expect(s.avatars.avatarFor('Ana'), 'assets/images/avatars/avatar-ana.svg');
    expect(s.avatars.avatarFor('Manang Rosa'),
        'assets/images/avatars/avatar-manang.svg');
    expect(s.avatars.avatarFor('Seller'),
        'assets/images/avatars/avatar-neighbor.svg');
    expect(s.uiLanguages, ['English', 'Filipino', 'Hiligaynon']);
  });

  test('Lesson 1 is the letters lesson with no quiz', () {
    final l1 = beginner.first;
    expect(l1.isLetters, isTrue);
    expect(l1.hasQuiz, isFalse);
    expect(l1.letters, hasLength(19));
    final letters = l1.parts.whereType<LettersPartData>().single;
    expect(letters.stepCount, 19);
    for (final lesson in beginner.skip(1)) {
      expect(lesson.hasQuiz, isTrue, reason: lesson.id);
    }
  });

  test('every part has a known template that matches its class', () {
    for (final lesson in beginner) {
      expect(lesson.parts, hasLength(lesson.partsCount), reason: lesson.id);
      expect(lesson.partsCount, inInclusiveRange(8, 14), reason: lesson.id);
      for (final part in lesson.parts) {
        final expected = switch (part) {
          KeyIdeaPartData() => 'P01',
          TablePartData() => 'P02',
          PatternPartData() => 'P03',
          WordsPartData() => 'P04',
          LettersPartData() => 'P05',
          QuickCheckPartData() => 'P06',
          DialoguePartData() => 'P07',
          ReadingPartData() => 'P08',
          BridgeMistakesPartData() => 'P09',
          CultureNotePartData() => 'P10',
        };
        expect(part.template, expected, reason: '${lesson.id} ${part.id}');
      }
      // The guide: every lesson has at least one reading.
      expect(lesson.parts.whereType<ReadingPartData>(), isNotEmpty,
          reason: lesson.id);
    }
  });

  test('every question has a known template that matches its class', () {
    for (final lesson in beginner.where((l) => l.hasQuiz)) {
      for (final q in lesson.quiz!.questions) {
        final expected = switch (q) {
          MultipleChoiceData() => 'Q01',
          ListeningData() => 'Q02',
          FillBlankData() => 'Q03',
          TypeAnswerData() => 'Q04',
          BuildSentenceData() => 'Q05',
          RealSituationData() => 'Q06',
          MatchPairsData() => 'Q07',
          DictationData() => 'Q08',
          SpeakingData() => 'Q09',
          OpenAnswerData() => 'Q10',
        };
        expect(q.template, expected, reason: '${lesson.id} ${q.id}');
        expect(kQuestionTemplates[q.template], q.type);
        expect(q.scored, q is! SpeakingData && q is! OpenAnswerData);
      }
      expect(lesson.quiz!.scoredQuestions, isNotEmpty, reason: lesson.id);
    }
  });

  test('every itemId points at an item, and every item is used', () {
    for (final lesson in beginner) {
      final shown = <String>{};
      for (final part in lesson.parts.whereType<WordsPartData>()) {
        expect(part.items, isNotEmpty, reason: '${lesson.id} ${part.id}');
        for (final item in part.items) {
          expect(lesson.items, contains(item), reason: item.id);
          shown.add(item.id);
        }
      }
      expect(shown, lesson.items.map((i) => i.id).toSet(), reason: lesson.id);
    }
  });

  test('every answer index and answer word is valid', () {
    var checked = 0;
    for (final lesson in beginner) {
      for (final part in lesson.parts.whereType<QuickCheckPartData>()) {
        expect(part.answer, inInclusiveRange(0, part.options.length - 1),
            reason: part.id);
        checked++;
      }
      for (final q in lesson.quiz?.questions ?? const <QuizQuestion>[]) {
        switch (q) {
          case ChoiceQuestion c:
            expect(c.answer, inInclusiveRange(0, c.options.length - 1),
                reason: q.id);
          case BuildSentenceData():
            final tiles = [...q.tiles];
            for (final word in q.answer) {
              expect(tiles.remove(word), isTrue, reason: '${q.id} "$word"');
            }
            expect(tiles, isNotEmpty, reason: '${q.id} has no distractor');
          case TypedQuestion t:
            expect(t.accepted, isNotEmpty, reason: q.id);
          case MatchPairsData():
            expect(q.pairs.length, greaterThanOrEqualTo(2), reason: q.id);
          case SpeakingData() || OpenAnswerData():
            break;
        }
        checked++;
      }
    }
    expect(checked, greaterThan(100));
  });

  test('Q08 plays the same clip on the Wrong sheet', () {
    // Checked on the raw JSON, because the clips aren't in the app yet.
    final raw = jsonDecode(File(LessonRepository.lessonsAsset).readAsStringSync());
    for (final lesson in raw['levels'][0]['lessons'] as List) {
      for (final q in (lesson['quiz']?['questions'] as List?) ?? const []) {
        if (q['template'] == 'Q08') {
          expect(q['answerAudio'], q['audio'], reason: q['id'] as String);
        }
      }
    }
  });

  test('every part icon name has a Flutter icon', () {
    final names = <String>{};
    for (final lesson in beginner) {
      for (final part in lesson.parts) {
        final icon = switch (part) {
          KeyIdeaPartData(:final icon) ||
          TablePartData(:final icon) ||
          PatternPartData(:final icon) ||
          DialoguePartData(:final icon) ||
          ReadingPartData(:final icon) ||
          BridgeMistakesPartData(:final icon) =>
            icon,
          _ => null,
        };
        if (icon != null) names.add(icon);
      }
    }
    expect(names.where((n) => !kPartIcons.containsKey(n)), isEmpty);
  });

  test('every asset in the app loads, and every file on disk is found', () async {
    expect(repo.assetRefs, isNotEmpty);
    for (final ref in repo.assetRefs) {
      final onDisk = File('assets/${ref.jsonPath}').existsSync();
      // A file in the repo must be registered in pubspec.yaml, so the app
      // finds it. A file not in the repo must count as missing.
      expect(ref.found, onDisk, reason: '${ref.where}: ${ref.jsonPath}');
      if (ref.found) {
        final data = await rootBundle.load(ref.assetPath!);
        expect(data.lengthInBytes, greaterThan(0), reason: ref.assetPath);
      }
    }
    // These exist today and must never fall back.
    for (final lesson in beginner) {
      expect(lesson.icon, isNotNull, reason: '${lesson.id} icon');
      expect(lesson.coverImage, isNotNull, reason: '${lesson.id} banner');
    }
    final fallback = await rootBundle.load(catalog.settings.missingPicture);
    expect(fallback.lengthInBytes, greaterThan(0));

    // Not an error: these files aren't made yet. Printed for the record.
    final missing = repo.missingAssets;
    final byFolder = <String, int>{};
    for (final ref in missing) {
      final folder = ref.jsonPath.substring(0, ref.jsonPath.lastIndexOf('/'));
      byFolder[folder] = (byFolder[folder] ?? 0) + 1;
    }
    // ignore: avoid_print
    print('Assets found: ${repo.assetRefs.length - missing.length}, '
        'missing (fallback / no audio button): ${missing.length} $byFolder');
  });

  group('the loader rejects broken JSON', () {
    late Map<String, dynamic> good;
    late Set<String> assets;

    setUpAll(() async {
      good = jsonDecode(await rootBundle.loadString(LessonRepository.lessonsAsset))
          as Map<String, dynamic>;
      assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
          .listAssets()
          .toSet();
    });

    /// Copies the good JSON, lets [change] break it, and returns the error.
    String errorFor(void Function(Map<String, dynamic> lesson2) change) {
      final copy = jsonDecode(jsonEncode(good)) as Map<String, dynamic>;
      change(copy['levels'][0]['lessons'][1] as Map<String, dynamic>);
      try {
        LessonRepository.parse(jsonEncode(copy), assets);
      } on FormatException catch (e) {
        return e.message;
      }
      fail('no error was thrown');
    }

    test('unknown template', () {
      expect(errorFor((l) => l['parts'][0]['template'] = 'P99'),
          contains('unknown part template "P99"'));
    });

    test('template and type disagree', () {
      expect(errorFor((l) => l['quiz']['questions'][0]['type'] = 'listening'),
          contains('should have type "multiple_choice"'));
    });

    test('answer index out of range', () {
      expect(errorFor((l) => l['quiz']['questions'][0]['answer'] = 7),
          contains('answer 7 is out of range'));
    });

    test('itemId with no item', () {
      expect(errorFor((l) => (l['parts'][1]['itemIds'] as List).add('nope')),
          contains('itemId "nope" is not in items'));
    });

    test('partsCount wrong', () {
      expect(errorFor((l) => l['partsCount'] = 3),
          contains('partsCount is 3'));
    });

    test('build answer word that is not a tile', () {
      final q = (good['levels'][0]['lessons'][1]['quiz']['questions'] as List)
          .indexWhere((q) => q['template'] == 'Q05');
      expect(
          errorFor((l) =>
              (l['quiz']['questions'][q]['answer'] as List).add('Extra')),
          contains('answer word "Extra" is not a tile'));
    });
  });
}
