// Filipino lesson text (Stage 1): overlay keys, applying and checking overlays, the English
// fallback, Learn search on the Filipino title, the language switch and speaker display names.
// The Filipino here is a stand-in ("(fil) " + the English); the real text comes later.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_overlay.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/screens/learn_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/parts/chat_line.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String settingsText;
  late Map<String, String> levelTexts;
  late Set<String> assets;
  late LessonCatalog english;

  setUpAll(() async {
    settingsText = await rootBundle.loadString(LessonRepository.settingsAsset);
    levelTexts = {
      for (final f in LessonRepository.levelFiles(settingsText)) f: await rootBundle.loadString('assets/$f'),
    };
    assets = (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets().toSet();
    english = LessonRepository.parse(settingsText, levelTexts, assets).catalog;
  });

  Map<String, dynamic> decode(String text) => jsonDecode(text) as Map<String, dynamic>;

  /// A stand-in overlay: "(fil) " + the English for every display text in [text].
  Map<String, dynamic> pseudo(String text, {Map<String, String> extra = const {}}) {
    final strings = <String, Map<String, String>>{};
    LessonOverlay.forEachString(decode(text), (key, field, value, _) {
      if (LessonOverlay.translatableFields.contains(field) && value.trim().isNotEmpty) {
        strings[key] = {'en': value, 'fil': '(fil) $value'};
      }
    });
    for (final e in extra.entries) {
      strings[e.key] = {'en': e.key.substring(e.key.indexOf('.') + 1), 'fil': e.value};
    }
    return {'strings': strings};
  }

  Map<String, String> pseudoOverlays() => {
        LessonRepository.settingsFile: jsonEncode(pseudo(settingsText, extra: {'speakers.You': 'Ikaw', 'speakers.Driver': 'Drayber'})),
        for (final e in levelTexts.entries) e.key: jsonEncode(pseudo(e.value)),
      };

  group('keys', () {
    test('nearest id + the path inside it; strings without an id use the path from the root', () {
      String file(String level) => levelTexts.entries.firstWhere((e) => e.key.contains(level)).value;
      final b = LessonOverlay.keysOf(decode(file('beginner')));
      expect(b['b02.title'], ('title', 'Greetings & Courtesy'));
      expect(b['b02_q9.options[0]'], ('options', 'To be polite to an older person'));
      expect(b['b07_t1.columns[1]'], ('columns', 'Used for'));
      expect(b['b07_t1.rows[0][1]']?.$1, 'rows');
      expect(b['beginner.title'], ('title', 'Beginner'));
      final i = LessonOverlay.keysOf(decode(file('intermediate')));
      expect(i['i01.unit.title'], ('title', 'Everyday life'));
      expect(i['intermediate.units[0].title'], ('title', 'Everyday life'));
      final s = LessonOverlay.keysOf(decode(settingsText));
      expect(s['settings.resultTiers[2].title'], ('title', 'Keep practicing'));
      expect(s['beginner.title'], ('title', 'Beginner'));
    });

    test('the overlay asset sits next to its file', () {
      expect(LessonOverlay.assetFor('lessons/beginner_lessons.json'), 'lessons/beginner_lessons.fil.json');
    });
  });

  group('apply', () {
    Map<String, dynamic> lesson() => {
          'id': 'x1',
          'title': 'Greetings',
          'hil': 'Maayong aga',
          'prompt': 'Which one?',
          'options': ['Morning', 'Evening'],
        };

    test('swaps display text; keeps stale, non-display and empty entries in English', () {
      final json = lesson();
      final result = LessonOverlay.apply(json, {
        'strings': {
          'x1.title': {'en': 'Greetings', 'fil': 'Pagbati'},
          'x1.hil': {'en': 'Maayong aga', 'fil': 'Magandang umaga'}, // never: Hiligaynon
          'x1.prompt': {'en': 'Which word?', 'fil': 'Alin?'}, // stale: the English changed
          'x1.options[0]': {'en': 'Morning', 'fil': ' '}, // empty
          'x1.options[1]': {'en': 'Evening', 'fil': 'Gabi'},
        },
      });
      expect(json, {
        'id': 'x1',
        'title': 'Pagbati',
        'hil': 'Maayong aga',
        'prompt': 'Which one?',
        'options': ['Morning', 'Gabi'],
      });
      expect(result.applied, 2);
      expect(result.stale, 1);
    });

    test('speaker display names come from speakers.<Name>', () {
      final result = LessonOverlay.apply({}, {
        'strings': {
          'speakers.You': {'en': 'You', 'fil': 'Ikaw'},
          'speakers.Guard': {'en': 'Guard', 'fil': ''},
        },
      });
      expect(result.speakerNames, {'You': 'Ikaw'});
    });
  });

  group('validate (the import checks)', () {
    final json = {
      'id': 'x1',
      'text': 'Say *Maayong aga* to greet.',
      'hil': 'Maayong aga',
      'options': ['Morning', 'Evening'],
    };

    test('a good overlay has no problems', () {
      expect(
          LessonOverlay.validate(json, {
            'strings': {
              'x1.text': {'en': 'Say *Maayong aga* to greet.', 'fil': 'Sabihin ang *Maayong aga* para bumati.'},
              'x1.options[0]': {'en': 'Morning', 'fil': 'Umaga'},
            },
          }),
          isEmpty);
    });

    test('unknown key, non-display field, stale English, empty text, changed markup, equal options', () {
      final problems = LessonOverlay.validate(json, {
        'strings': {
          'x9.text': {'en': 'x', 'fil': 'y'},
          'x1.hil': {'en': 'Maayong aga', 'fil': 'Magandang umaga'},
          'x1.options[1]': {'en': 'Night', 'fil': 'Gabi'},
          'x1.options[0]': {'en': 'Morning', 'fil': ''},
          'x1.text': {'en': 'Say *Maayong aga* to greet.', 'fil': 'Sabihin ang *Magandang umaga*.'},
        },
      });
      expect(problems.join('\n'), allOf(contains('x9.text: no such text'), contains('x1.hil: "hil" can\'t'),
          contains('x1.options[1]: stale'), contains('x1.options[0]: Filipino is empty'), contains('x1.text: *Hiligaynon* parts changed')));
      expect(
          LessonOverlay.validate(json, {
            'strings': {
              'x1.options[0]': {'en': 'Morning', 'fil': 'Gabi'},
              'x1.options[1]': {'en': 'Evening', 'fil': 'Gabi'},
            },
          }).single,
          contains('two options would be the same'));
    });

    test('the stand-in overlays for all four files pass, like a full translation would', () {
      final settings = pseudo(settingsText, extra: {'speakers.You': 'Ikaw'});
      expect(LessonOverlay.validate(decode(settingsText), settings, speakers: {'You'}), isEmpty);
      for (final e in levelTexts.entries) {
        expect(LessonOverlay.validate(decode(e.value), pseudo(e.value)), isEmpty, reason: e.key);
      }
    });

    test('the overlay files in the app (when there are any) pass', () {
      for (final file in [LessonRepository.settingsFile, ...levelTexts.keys]) {
        final overlay = File('assets/${LessonOverlay.assetFor(file)}');
        if (!overlay.existsSync()) continue;
        final source = file == LessonRepository.settingsFile ? settingsText : levelTexts[file]!;
        expect(LessonOverlay.validate(decode(source), decode(overlay.readAsStringSync())), isEmpty, reason: file);
      }
    });
  });

  group('repository', () {
    test('Filipino text loads in every level; Hiligaynon, answers and avatars stay', () {
      final fil = LessonRepository.parse(settingsText, levelTexts, assets, overlays: pseudoOverlays()).catalog;
      expect(fil.levels.map((l) => l.title), ['(fil) Beginner', '(fil) Intermediate', '(fil) Advanced']);
      expect(fil.settings.resultTiers.last.title, '(fil) Keep practicing');
      for (var i = 0; i < fil.levels.length; i++) {
        final a = english.levels[i].lessons, b = fil.levels[i].lessons;
        expect(b.map((l) => l.id), a.map((l) => l.id));
        for (var j = 0; j < a.length; j++) {
          expect(b[j].title, '(fil) ${a[j].title}');
          expect(b[j].objectives, [for (final o in a[j].objectives) '(fil) $o']);
          expect(b[j].unit?.title, a[j].unit == null ? null : '(fil) ${a[j].unit!.title}');
          expect(b[j].items.map((x) => x.hil), a[j].items.map((x) => x.hil), reason: 'Hiligaynon stays');
          final qa = a[j].quiz?.questions ?? const <QuizQuestion>[], qb = b[j].quiz?.questions ?? const <QuizQuestion>[];
          for (var k = 0; k < qa.length; k++) {
            if (qa[k] case MultipleChoiceData(:final answer)) {
              expect((qb[k] as MultipleChoiceData).answer, answer, reason: qa[k].id);
            }
          }
        }
      }
      final b02q9 = fil.lessonById('b02')!.quiz!.questions.firstWhere((q) => q.id == 'b02_q9') as MultipleChoiceData;
      expect(b02q9.options.first, '(fil) To be polite to an older person');
      expect(fil.settings.avatars.nameFor('You'), 'Ikaw');
      expect(fil.settings.avatars.nameFor('Ana'), 'Ana');
      expect(fil.settings.avatars.avatarFor('You'), english.settings.avatars.avatarFor('You'));
    });

    test('translated files that don\'t fit together fall back to English', () {
      final file = levelTexts.keys.firstWhere((f) => f.contains('intermediate'));
      final overlay = pseudo(levelTexts[file]!);
      // The lesson's unit name no longer matches the unit list: the catalog check fails.
      (overlay['strings'] as Map)['i01.unit.title'] = {'en': 'Everyday life', 'fil': 'Iba'};
      final catalog = LessonRepository.parse(settingsText, levelTexts, assets, overlays: {file: jsonEncode(overlay)}).catalog;
      expect(catalog.lessonById('i01')!.title, english.lessonById('i01')!.title);
    });

    test("the app's Filipino files load; the English catalog stays English", () async {
      final fil = (await LessonRepository.load(rootBundle, filipino: true)).catalog;
      expect(fil.lessonById('b02')!.title, 'Pagbati at Paggalang');
      expect(fil.levels.first.title, 'Baguhan');
      final en = (await LessonRepository.load(rootBundle)).catalog;
      expect(en.lessonById('b02')!.title, 'Greetings & Courtesy');
    });
  });

  group('app', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));
    tearDown(() => AppLanguage.instance.setLanguage('English'));

    testWidgets('Learn search matches the Filipino title', (tester) async {
      final file = levelTexts.keys.firstWhere((f) => f.contains('beginner'));
      final overlay = {
        'strings': {
          'b02.title': {'en': 'Greetings & Courtesy', 'fil': 'Pagbati at Paggalang'},
        },
      };
      final fil = LessonRepository.parse(settingsText, levelTexts, assets, overlays: {file: jsonEncode(overlay)}).catalog;
      tester.view.physicalSize = const Size(375, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: LearningProgress.ready(fil, ProgressSnapshot()),
        child: MaterialApp(
          locale: const Locale('fil'),
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          home: const LearnScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Pagbati at Paggalang'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'pagbati');
      await tester.pump();
      expect(find.text('Pagbati at Paggalang'), findsOneWidget);
      expect(find.text('Letters & Sounds'), findsNothing);

      await tester.enterText(find.byType(TextField), 'greet');
      await tester.pump();
      expect(find.text('Pagbati at Paggalang'), findsNothing, reason: 'the English title isn\'t shown or searched');
    });

    test('changing the app language swaps the lesson text; progress is kept', () async {
      final enRepo = LessonRepository.parse(settingsText, levelTexts, assets);
      final filRepo = LessonRepository.parse(settingsText, levelTexts, assets, overlays: pseudoOverlays());
      final asked = <bool>[];
      final progress = LearningProgress(
        loadLessonsIn: (filipino) async {
          asked.add(filipino);
          return filipino ? filRepo : enRepo;
        },
        language: AppLanguage.instance,
      );
      addTearDown(progress.dispose);
      await progress.load();
      expect(progress.catalog.lessonById('b02')!.title, 'Greetings & Courtesy');

      var changes = 0;
      progress.addListener(() => changes++);
      await AppLanguage.instance.setLanguage('Filipino');
      await pumpEventQueue();
      expect(progress.catalog.lessonById('b02')!.title, '(fil) Greetings & Courtesy');
      expect(changes, greaterThan(0));

      await AppLanguage.instance.setLanguage('Hiligaynon');
      await pumpEventQueue();
      expect(progress.catalog.lessonById('b02')!.title, '(fil) Greetings & Courtesy', reason: 'Hiligaynon shows the Filipino text');

      await AppLanguage.instance.setLanguage('English');
      await pumpEventQueue();
      expect(progress.catalog.lessonById('b02')!.title, 'Greetings & Courtesy');
      expect(asked, [false, true, false], reason: 'Hiligaynon after Filipino needs no reload');
    });

    testWidgets('chat lines show the display name; the JSON name keeps the learner side', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ChatLine(speaker: 'You', displayName: 'Ikaw', avatar: null, bubble: Text('Maayong aga'))),
      ));
      expect(find.text('Ikaw'), findsOneWidget);
      expect(find.text('You'), findsNothing);
      // Learner lines sit on the right.
      expect(tester.getCenter(find.text('Maayong aga')).dx, greaterThan(400));
    });
  });
}
