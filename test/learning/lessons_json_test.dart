// Loads the lesson files like the app and checks template IDs, item ids, answer indexes and asset paths.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/json_reader.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/parts.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/theme/part_icons.dart';

const _beginnerFile = 'lessons/beginner_lessons.json';
const _intermediateFile = 'lessons/intermediate_lessons.json';
const _advancedFile = 'lessons/advanced_lessons.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonRepository repo;
  late LessonCatalog catalog;
  late List<Lesson> beginner;
  late List<Lesson> intermediate;
  late List<Lesson> advanced;
  late List<Lesson> all;

  setUpAll(() async {
    repo = await LessonRepository.load(rootBundle);
    catalog = repo.catalog;
    beginner = catalog.levels.firstWhere((l) => l.id == 'beginner').lessons;
    intermediate = catalog.levels.firstWhere((l) => l.id == 'intermediate').lessons;
    advanced = catalog.levels.firstWhere((l) => l.id == 'advanced').lessons;
    all = catalog.allLessons;
  });

  test('loads all 13 Beginner lessons in order', () {
    expect(catalog.schemaVersion, 8);
    expect(catalog.levels.map((l) => l.id),
        ['beginner', 'intermediate', 'advanced']);
    expect(beginner, hasLength(13));
    expect(beginner.map((l) => l.order), List.generate(13, (i) => i + 1));
    expect(beginner.map((l) => l.id),
        List.generate(13, (i) => 'b${(i + 1).toString().padLeft(2, '0')}'));
    expect(beginner.map((l) => l.unit), everyElement(isNull));
  });

  test('loads all 12 Intermediate lessons in order, in 4 units of 3', () {
    expect(intermediate, hasLength(12));
    expect(intermediate.map((l) => l.order), List.generate(12, (i) => i + 1));
    expect(intermediate.map((l) => l.id),
        List.generate(12, (i) => 'i${(i + 1).toString().padLeft(2, '0')}'));
    expect(intermediate.map((l) => l.unit?.number),
        [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4]);
    expect(intermediate.map((l) => l.unit!.title).toSet(),
        {'Everyday life', 'Building sentences', 'Real life', 'Putting it together'});
    final level = catalog.levels[1];
    expect(level.unlockAfterLevel, 'beginner');
    // i01 opens with the level; every later lesson needs the quiz before it.
    expect(intermediate.first.unlock.after, isNull);
    for (var i = 1; i < intermediate.length; i++) {
      expect(intermediate[i].unlock.after, intermediate[i - 1].id);
      expect(intermediate[i].unlock.needs, UnlockNeed.passQuiz);
    }
    // Pictures: every lesson has its icon and banner.
    for (final l in intermediate) {
      expect(l.icon, startsWith('assets/images/lessons/lesson-${l.id}-'), reason: l.id);
      expect(l.coverImage, l.icon!.replaceFirst('.webp', '-hero.webp'), reason: l.id);
    }
  });

  test('loads all 10 Advanced lessons in order, in 4 units', () {
    expect(advanced, hasLength(10));
    expect(advanced.map((l) => l.order), List.generate(10, (i) => i + 1));
    expect(advanced.map((l) => l.id),
        List.generate(10, (i) => 'a${(i + 1).toString().padLeft(2, '0')}'));
    expect(advanced.map((l) => l.unit?.number), [1, 1, 1, 2, 2, 3, 3, 4, 4, 4]);
    expect(advanced.map((l) => l.unit!.title).toSet(), {
      'Sounding natural', 'Right words, right people', 'Telling and explaining', 'Hiligaynon in real life',
    });
    expect(catalog.levels.last.unlockAfterLevel, 'intermediate');
    expect(advanced.first.unlock.after, isNull);
    for (var i = 1; i < advanced.length; i++) {
      expect(advanced[i].unlock.after, advanced[i - 1].id);
      expect(advanced[i].unlock.needs, UnlockNeed.passQuiz);
    }
    for (final l in advanced) {
      expect(l.partsCount, inInclusiveRange(16, 17), reason: l.id);
      expect(l.quiz!.questions, hasLength(15), reason: l.id);
      expect(l.quiz!.scoredQuestions, hasLength(14), reason: l.id);
      expect(l.icon, startsWith('assets/images/lessons/lesson-${l.id}-'), reason: l.id);
      expect(l.coverImage, l.icon!.replaceFirst('.webp', '-hero.webp'), reason: l.id);
    }
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
    expect(s.avatars.avatarFor('You'), 'assets/images/avatars/avatar-ana.svg',
        reason: '"You" is the learner, like Ana');
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
    for (final lesson in all.where((l) => l != l1)) {
      expect(lesson.hasQuiz, isTrue, reason: lesson.id);
    }
  });

  test('every part has a known template that matches its class', () {
    for (final lesson in all) {
      expect(lesson.parts, hasLength(lesson.partsCount), reason: lesson.id);
      expect(lesson.partsCount, inInclusiveRange(8, kMaxParts), reason: lesson.id);
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
          RolePlayPartData() => 'P11',
          VerbFormsPartData() => 'P12',
          IdiomCardsPartData() => 'P13',
          RegisterPairsPartData() => 'P14',
        };
        expect(part.template, expected, reason: '${lesson.id} ${part.id}');
        expect(kPartTemplates[part.template], isNotNull);
      }
    }
    for (final lesson in beginner) {
      // The guide: every Beginner lesson has 8–14 parts and at least one reading.
      expect(lesson.partsCount, lessThanOrEqualTo(14), reason: lesson.id);
      expect(lesson.parts.whereType<ReadingPartData>(), isNotEmpty,
          reason: lesson.id);
    }
  });

  test('every question has a known template that matches its class', () {
    for (final lesson in all.where((l) => l.hasQuiz)) {
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
          PassageSetData() => 'Q13',
          ReadAnswerData() => 'Q11',
          SpotMistakeData() => 'Q12',
        };
        expect(q.template, expected, reason: '${lesson.id} ${q.id}');
        expect(kQuestionTemplates[q.template], q.type);
        expect(q.scored, q is! SpeakingData && q is! OpenAnswerData);
      }
      expect(lesson.quiz!.scoredQuestions, isNotEmpty, reason: lesson.id);
    }
  });

  test('every itemId points at an item, and every item is used', () {
    for (final lesson in all) {
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
    for (final lesson in all) {
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
            expect(c.options.toSet(), hasLength(c.options.length), reason: q.id);
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
          case SpotMistakeData():
            expect(q.wrongIndex, inInclusiveRange(0, q.tiles.length - 1), reason: q.id);
            expect(q.tiles.join(' '), q.sentence, reason: q.id);
            expect(q.fix, isNot(q.wrongWord), reason: q.id);
          case SpeakingData() || OpenAnswerData():
            break;
        }
        checked++;
      }
    }
    expect(checked, greaterThan(400));
  });

  test('every Q11 passage is a reading or dialogue of the same lesson', () {
    var count = 0;
    for (final lesson in intermediate) {
      for (final q in lesson.quiz!.questions.whereType<ReadAnswerData>()) {
        final part = lesson.parts.where((p) => p.id == q.passagePart).single;
        expect(part, anyOf(isA<ReadingPartData>(), isA<DialoguePartData>()), reason: q.id);
        final lines = switch (part) {
          ReadingPartData p => p.lines.map((l) => l.hil).toList(),
          DialoguePartData p => p.lines.map((l) => l.hil).toList(),
          _ => const <String>[],
        };
        expect(q.passage.map((l) => l.hil), lines, reason: q.id);
        if (q.mode == ReadAnswerMode.listen) {
          expect(part, isA<DialoguePartData>(), reason: q.id);
          expect((part as DialoguePartData).lines.every((l) => l.hasClip), isTrue, reason: q.id);
        }
        count++;
      }
    }
    expect(count, 17);
  });

  test('role-plays and verb forms are complete', () {
    final rolePlays = [for (final l in intermediate) ...l.parts.whereType<RolePlayPartData>()];
    expect(rolePlays, hasLength(10));
    for (final p in rolePlays) {
      for (final (i, turn) in p.turns.indexed) {
        if (i < p.turns.length - 1) expect(turn.choices, isNotEmpty, reason: '${p.id} turn $i');
        if (turn.choices.isNotEmpty) {
          expect(turn.choices.where((c) => c.correct), hasLength(1), reason: '${p.id} turn $i');
          expect(turn.choices.where((c) => !c.correct && c.hint == null), isEmpty);
        }
      }
    }
    final verbs = [for (final l in intermediate) ...l.parts.whereType<VerbFormsPartData>()];
    expect(verbs.map((p) => p.id), ['i03_p04', 'i04_p07']);
    for (final p in verbs) {
      expect(p.columns, hasLength(3));
      for (final root in p.roots) {
        expect(root.forms, hasLength(3));
        if (root.doerForms != null) expect(root.doerForms, hasLength(3));
      }
    }
    // i04's table has both rows, i03's only one.
    expect(verbs[0].roots.every((r) => r.doerForms == null), isTrue);
    expect(verbs[1].roots.every((r) => r.doerForms != null), isTrue);
  });

  test('the listening dialogues name a clip on every line', () {
    final listening = [
      for (final l in intermediate) ...l.parts.whereType<DialoguePartData>().where((p) => p.listening),
    ];
    expect(listening.map((p) => p.id), ['i10_p05', 'i10_p09']);
    for (final p in listening) {
      expect(p.lines.every((l) => l.hasClip), isTrue, reason: p.id);
    }
  });

  test('every Intermediate listening question has the words of its clip', () {
    final listening = [
      for (final l in intermediate) ...l.quiz!.questions.whereType<ListeningData>(),
    ];
    expect(listening, hasLength(10));
    for (final q in listening) {
      expect(q.audioText, isNotNull, reason: q.id);
      expect(q.audioText!.trim(), isNotEmpty, reason: q.id);
    }
  });

  test('every Advanced passage set: 3 in a row on one reading or dialogue of the lesson', () {
    var sets = 0;
    for (final lesson in advanced) {
      final qs = lesson.quiz!.questions;
      for (var i = 0; i < qs.length; i++) {
        final q = qs[i];
        if (q is! PassageSetData || q.setIndex != 1) continue;
        sets++;
        final group = qs.sublist(i, i + q.setSize).cast<PassageSetData>();
        expect(group.map((g) => g.setIndex), [1, 2, 3], reason: q.id);
        expect(group.map((g) => g.passagePart).toSet(), {q.passagePart}, reason: q.id);
        final part = lesson.parts.where((p) => p.id == q.passagePart).single;
        expect(part, anyOf(isA<ReadingPartData>(), isA<DialoguePartData>()), reason: q.id);
        if (q.mode == ReadAnswerMode.listen) {
          expect((part as DialoguePartData).lines.every((l) => l.hasClip), isTrue, reason: q.id);
        }
      }
    }
    expect(sets, 10, reason: 'one set per Advanced lesson');
    // a08 and a10 listen; the others read.
    final listen = [for (final l in advanced) ...l.quiz!.questions.whereType<PassageSetData>()]
        .where((q) => q.mode == ReadAnswerMode.listen && q.setIndex == 1)
        .map((q) => q.passagePart);
    expect(listen, ['a08_p13', 'a10_p01']);
  });

  test('idiom cards, register pairs and Advanced role-play extras are complete', () {
    final idioms = [for (final l in advanced) ...l.parts.whereType<IdiomCardsPartData>()];
    expect(idioms.map((p) => p.cards.length), [5, 5, 4]);
    for (final c in [for (final p in idioms) ...p.cards]) {
      expect(c.exampleHil, isNotEmpty, reason: c.id);
      expect(c.exampleHil.length, c.exampleFil.length, reason: c.id);
      expect([c.literal, c.means, c.tone, c.sayTo], everyElement(isNotEmpty), reason: c.id);
    }
    expect([for (final p in idioms) ...p.cards].where((c) => c.careful).length, 3);

    final pairs = [for (final l in advanced) ...l.parts.whereType<RegisterPairsPartData>()];
    expect(pairs, hasLength(6));
    expect(pairs.where((p) => p.leftWrongOnPurpose).map((p) => p.id), ['a02_p03', 'a09_p05']);
    for (final p in pairs) {
      expect(p.stepCount, p.situations.length);
      for (final s in p.situations) {
        expect(s.left.note != null, p.leftWrongOnPurpose, reason: '${p.id} ${s.title}');
        expect(s.changes, isNotEmpty, reason: '${p.id} ${s.title}');
      }
    }

    final rolePlays = [for (final l in advanced) ...l.parts.whereType<RolePlayPartData>()];
    expect([for (final p in rolePlays) ...p.turns].where((t) => t.quote != null), hasLength(2));
    expect([for (final p in rolePlays) for (final t in p.turns) ...t.choices].where((c) => c.note != null),
        hasLength(1));
    expect(advanced.expand((l) => l.parts.whereType<ReadingPartData>()).where((p) => p.text != null),
        hasLength(1));
    expect(advanced.expand((l) => l.parts.whereType<DialoguePartData>()).where((p) => p.listening).map((p) => p.id),
        ['a08_p06', 'a08_p10', 'a08_p13', 'a10_p01']);
  });

  test('Q08 plays the same clip on the Wrong sheet', () {
    for (final file in [_beginnerFile, _intermediateFile, _advancedFile]) {
      final raw = jsonDecode(File('assets/$file').readAsStringSync());
      for (final lesson in raw['lessons'] as List) {
        for (final q in (lesson['quiz']?['questions'] as List?) ?? const []) {
          if (q['template'] == 'Q08') {
            expect(q['answerAudio'], q['audio'], reason: q['id'] as String);
          }
        }
      }
    }
  });

  test('every part icon name has a Flutter icon', () {
    final names = <String>{};
    for (final lesson in all) {
      for (final part in lesson.parts) {
        final icon = switch (part) {
          KeyIdeaPartData(:final icon) ||
          TablePartData(:final icon) ||
          PatternPartData(:final icon) ||
          DialoguePartData(:final icon) ||
          ReadingPartData(:final icon) ||
          BridgeMistakesPartData(:final icon) ||
          RolePlayPartData(:final icon) ||
          VerbFormsPartData(:final icon) ||
          RegisterPairsPartData(:final icon) =>
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
      expect(ref.assetPath, ref.found ? 'assets/${ref.jsonPath}' : isNull);
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

    bool isLevel(AssetRef r, String letter) => RegExp('^$letter\\d\\d\\b').hasMatch(r.where);

    // Beginner (and settings): every picture and all 133 native-speaker clips are in the app.
    final rest = repo.assetRefs.where((r) => !isLevel(r, 'i') && !isLevel(r, 'a')).toList();
    expect(rest.where((r) => !r.found).map((r) => '${r.where}: ${r.jsonPath}'), isEmpty);
    final audio = rest.where((r) => r.jsonPath.startsWith('audio/')).toList();
    expect(audio.map((r) => r.jsonPath).toSet(), hasLength(133));

    // Intermediate and Advanced: every picture is in the app (tyangge reuses
    // Beginner's word-tindahan.webp). Clips aren't recorded yet: report them, don't fail.
    for (final (letter, name, pictures) in [('i', 'Intermediate', 70), ('a', 'Advanced', 35)]) {
      final refs = repo.assetRefs.where((r) => isLevel(r, letter) && r.jsonPath.startsWith('images/')).toList();
      expect(refs, hasLength(pictures), reason: '$name pictures');
      expect(refs.where((r) => !r.found).map((r) => '${r.where}: ${r.jsonPath}'), isEmpty);
    }
    expect(repo.assetRefs.where((r) => r.where.startsWith('i09') && r.jsonPath == 'images/words/word-tindahan.webp'),
        hasLength(1), reason: 'tyangge keeps the Beginner picture');
    for (final (letter, name, total) in [('i', 'Intermediate', 132), ('a', 'Advanced', 118)]) {
      final refs = repo.assetRefs.where((r) => isLevel(r, letter) && r.jsonPath.startsWith('audio/')).toList();
      final missing = {for (final r in refs) if (!r.found) r.jsonPath}.toList()..sort();
      final found = {for (final r in refs) if (r.found) r.jsonPath};
      // ignore: avoid_print
      print('$name clips: ${found.length} in the app, ${missing.length} missing'
          '${missing.isEmpty ? '' : ':\n  ${missing.join('\n  ')}'}');
      expect(refs.every((r) => r.jsonPath.startsWith('audio/$letter')), isTrue, reason: name);
      expect(found.length + missing.length, total, reason: name);
    }
  });

  group('the loader rejects broken JSON', () {
    late String settingsText;
    late Map<String, dynamic> good;
    late Map<String, dynamic> goodInter;
    late Map<String, dynamic> goodAdv;
    late Set<String> assets;

    setUpAll(() async {
      settingsText = await rootBundle.loadString(LessonRepository.settingsAsset);
      good = jsonDecode(await rootBundle.loadString('assets/$_beginnerFile'))
          as Map<String, dynamic>;
      goodInter = jsonDecode(await rootBundle.loadString('assets/$_intermediateFile'))
          as Map<String, dynamic>;
      goodAdv = jsonDecode(await rootBundle.loadString('assets/$_advancedFile'))
          as Map<String, dynamic>;
      assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
          .listAssets()
          .toSet();
    });

    Map<String, dynamic> copyOf(Map<String, dynamic> json) =>
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

    String errorOf(Map<String, dynamic> beginnerJson, Map<String, dynamic> interJson,
        [Map<String, dynamic>? advJson]) {
      try {
        LessonRepository.parse(settingsText, {
          _beginnerFile: jsonEncode(beginnerJson),
          _intermediateFile: jsonEncode(interJson),
          _advancedFile: jsonEncode(advJson ?? goodAdv),
        }, assets);
      } on FormatException catch (e) {
        return e.message;
      }
      fail('no error was thrown');
    }

    /// Copies the good JSON, lets [change] break Beginner Lesson 2, and returns the error.
    String errorFor(void Function(Map<String, dynamic> lesson2) change) {
      final copy = copyOf(good);
      change(copy['lessons'][1] as Map<String, dynamic>);
      return errorOf(copy, goodInter);
    }

    /// Same for an Intermediate lesson (0-based [index]).
    String errorForInter(int index, void Function(Map<String, dynamic> lesson) change) {
      final copy = copyOf(goodInter);
      change(copy['lessons'][index] as Map<String, dynamic>);
      return errorOf(good, copy);
    }

    /// Same for an Advanced lesson (0-based [index]).
    String errorForAdv(int index, void Function(Map<String, dynamic> lesson) change) {
      final copy = copyOf(goodAdv);
      change(copy['lessons'][index] as Map<String, dynamic>);
      return errorOf(good, goodInter, copy);
    }

    test('the good files load', () {
      final repo = LessonRepository.parse(settingsText, {
        _beginnerFile: jsonEncode(good),
        _intermediateFile: jsonEncode(goodInter),
        _advancedFile: jsonEncode(goodAdv),
      }, assets);
      expect(repo.catalog.allLessons, hasLength(35));
    });

    test('Q12 wrongIndex out of range', () {
      expect(errorForAdv(0, (l) => l['quiz']['questions'][5]['wrongIndex'] = 9),
          contains('wrongIndex 9 is out of range'));
    });

    test('Q12 tiles that are not the sentence', () {
      expect(errorForAdv(0, (l) => (l['quiz']['questions'][5]['tiles'] as List).removeLast()),
          contains('tiles should be the sentence split on spaces'));
    });

    test('passage set with a question on another passage', () {
      expect(errorForAdv(0, (l) => l['quiz']['questions'][11]['passagePart'] = 'a01_p01'),
          anyOf(contains('passage set needs 3 questions in a row'), contains('should be a reading or a dialogue')));
    });

    test('passage set that starts at question 2', () {
      expect(errorForAdv(0, (l) => (l['quiz']['questions'] as List).removeAt(10)),
          contains('a passage set starts with setIndex 1'));
    });

    test('register pair whose left note does not match leftWrongOnPurpose', () {
      expect(errorForAdv(1, (l) => (l['parts'][2]['situations'][0]['left'] as Map).remove('note')),
          contains('but leftWrongOnPurpose is true'));
    });

    test('idiom card example lines that do not match', () {
      expect(errorForAdv(2, (l) => (l['parts'][2]['cards'][0]['example']['fil'] as List).removeLast()),
          contains('lines, fil has'));
    });

    test('a pattern with 6 slots', () {
      expect(
          errorForAdv(0, (l) => (l['parts'][4]['slots'] as List).add({'label': '', 'hil': 'x'})),
          contains('a pattern needs 3 to 5 slots, not 6'));
    });

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

    test('more than 20 parts', () {
      expect(
          errorForInter(0, (l) {
            final parts = l['parts'] as List;
            final extra = [
              for (var i = 0; i < 6; i++)
                {...parts[0] as Map<String, dynamic>, 'id': 'extra_$i'},
            ];
            parts.addAll(extra);
            l['partsCount'] = parts.length;
          }),
          contains('more than 20 parts'));
    });

    test('build answer word that is not a tile', () {
      final q = (good['lessons'][1]['quiz']['questions'] as List)
          .indexWhere((q) => q['template'] == 'Q05');
      expect(
          errorFor((l) =>
              (l['quiz']['questions'][q]['answer'] as List).add('Extra')),
          contains('answer word "Extra" is not a tile'));
    });

    test('Q11 passage that is not in the lesson', () {
      expect(errorForInter(0, (l) => l['quiz']['questions'][8]['passagePart'] = 'i02_p11'),
          contains('passagePart "i02_p11" is not a part of this lesson'));
    });

    test('Q11 passage that is not a reading or dialogue', () {
      expect(errorForInter(0, (l) => l['quiz']['questions'][8]['passagePart'] = 'i01_p02'),
          contains('should be a reading or a dialogue'));
    });

    test('Q11 listen mode on a reading', () {
      expect(errorForInter(0, (l) => l['quiz']['questions'][8]['mode'] = 'listen'),
          contains('listen mode needs a dialogue'));
    });

    test('role-play turn with two correct choices', () {
      expect(
          errorForInter(0, (l) {
            for (final c in l['parts'][12]['turns'][0]['choices'] as List) {
              c['correct'] = true;
            }
          }),
          contains('needs exactly 1 correct choice'));
    });

    test('role-play turn without choices before the end', () {
      expect(errorForInter(0, (l) => l['parts'][12]['turns'][0]['choices'] = <Object>[]),
          contains('only the last turn may close'));
    });

    test('verb forms with a missing form', () {
      expect(errorForInter(2, (l) => (l['parts'][3]['roots'][0]['forms'] as List).removeLast()),
          contains('forms needs 3 entries'));
    });

    test('listening dialogue line without a clip', () {
      final i = (goodInter['lessons'][9]['parts'] as List).indexWhere((p) => p['listening'] == true);
      expect(errorForInter(9, (l) => (l['parts'][i]['lines'][0] as Map).remove('audio')),
          contains('listening: every line needs audio'));
    });

    test('unit that disagrees with the level\'s unit list', () {
      expect(errorForInter(0, (l) => l['unit'] = {'number': 2, 'title': 'Building sentences'}),
          contains('i01 has unit 2 · Building sentences'));
    });

    test('level file that is not the level the list names', () {
      final copy = copyOf(goodInter)..['title'] = 'Middle';
      expect(errorOf(good, copy), contains('the level list says intermediate / Intermediate'));
    });
  });
}
