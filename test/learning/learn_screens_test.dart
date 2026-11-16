// S01 Learn and S02 Lesson Detail in every state.
//   flutter test test/learning/learn_screens_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/screens/learn_screen.dart';
import 'package:hibalo_app/learning/screens/lesson_detail_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/lesson_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;

  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  const done = LessonProgress(completed: true);
  LessonProgress passed(int best) =>
      LessonProgress(completed: true, passed: true, bestScore: best);

  /// Shows [screen] with the given progress, on a tall phone so every lesson
  /// row is built.
  Future<void> show(
    WidgetTester tester,
    Widget screen, {
    Map<String, LessonProgress> lessons = const {},
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(375, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final progress = LearningProgress.ready(
      catalog,
      ProgressSnapshot(lessons: {...lessons}),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          // A route below, so the screen has a Back button like in the app.
          home: const Scaffold(),
        ),
      ),
    );
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(builder: (_) => screen));
    await tester.pumpAndSettle();
  }

  group('S01 Learn', () {
    testWidgets('fresh start: Lesson 1 current, the rest locked', (tester) async {
      await show(tester, const LearnScreen());

      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Explore Hiligaynon through bite-sized lessons!'), findsOneWidget);
      expect(find.text('Letters & Sounds'), findsOneWidget);
      expect(find.text('8 parts • 8 min'), findsOneWidget);
      expect(find.text('Finish Lesson\u00A01 to unlock'), findsOneWidget);
      expect(find.text('Pass Lesson\u00A02 quiz to unlock'), findsOneWidget);
      expect(find.text('Pass Lesson\u00A012 quiz to unlock'), findsOneWidget);
      // No hint line under the level tabs; tabs stay locked.
      expect(find.textContaining('finish Beginner to unlock'), findsNothing);
      // Rows keep their numbers.
      for (var n = 1; n <= 13; n++) {
        expect(find.text('$n'), findsOneWidget, reason: 'row $n');
      }
    });

    testWidgets('Completed, Quiz pending and Locked rows', (tester) async {
      await show(tester, const LearnScreen(), lessons: {'b01': done, 'b02': done});

      expect(find.text('8 parts • 8 min'), findsOneWidget); // Lesson 1 completed
      expect(find.text('Take the quiz to unlock Lesson\u00A03'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      expect(find.text('Pass Lesson\u00A02 quiz to unlock'), findsOneWidget);
    });

    testWidgets('a locked row and a locked level tab explain themselves', (tester) async {
      await show(tester, const LearnScreen());

      await tester.tap(find.text('Pronouns & Identity'));
      await tester.pump();
      expect(find.descendant(of: find.byType(SnackBar), matching: find.text('Pass Lesson\u00A02 quiz to unlock')),
          findsOneWidget);

      await tester.tap(find.text('Intermediate'));
      await tester.pump();
      expect(find.text('Finish Beginner to unlock Intermediate'), findsOneWidget);
      // The tab didn't switch: the Beginner lessons are still listed.
      expect(find.text('Letters & Sounds'), findsOneWidget);
    });

    testWidgets('search filters the tab and shows an empty state', (tester) async {
      await show(tester, const LearnScreen());

      await tester.enterText(find.byType(TextField), 'greet');
      await tester.pump();
      expect(find.text('Greetings & Courtesy'), findsOneWidget);
      expect(find.text('Letters & Sounds'), findsNothing);

      await tester.enterText(find.byType(TextField), 'isda');
      await tester.pump();
      expect(find.text("No lessons found for 'isda'"), findsOneWidget);
    });

    testWidgets('after all of Beginner, Intermediate opens with Lesson 1 open', (tester) async {
      final lessons = catalog.levels.first.lessons;
      await show(tester, const LearnScreen(), lessons: {
        for (final l in lessons) l.id: l.hasQuiz ? passed(8) : done,
      });

      expect(find.textContaining('to unlock'), findsNothing, reason: 'no hint line');
      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();
      expect(find.text('Feelings, Health & Weather'), findsOneWidget);
      expect(find.text('15 parts • 16 min'), findsOneWidget);
    });

    testWidgets('Advanced stays locked until every Intermediate quiz is passed', (tester) async {
      final beforeAdvanced = [...catalog.levels[0].lessons, ...catalog.levels[1].lessons];
      await show(tester, const LearnScreen(), lessons: {
        for (final l in beforeAdvanced.take(beforeAdvanced.length - 1)) l.id: l.hasQuiz ? passed(8) : done,
      });
      await tester.ensureVisible(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));
      await tester.pump();
      expect(find.text('Finish Intermediate to unlock Advanced'), findsOneWidget);
    });

    testWidgets('after all of Intermediate, Advanced opens with Lesson 1 open', (tester) async {
      await show(tester, const LearnScreen(), lessons: {
        for (final l in [...catalog.levels[0].lessons, ...catalog.levels[1].lessons])
          l.id: l.hasQuiz ? passed(8) : done,
      });
      await tester.ensureVisible(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('Unit 1 · Sounding natural'), findsOneWidget);
      expect(find.text('Who Did What, Part 2'), findsOneWidget);
      expect(find.text('17 parts • ${catalog.levels[2].lessons.first.estMinutes} min'), findsOneWidget);
    });

    testWidgets('a current row opens Lesson Detail', (tester) async {
      await show(tester, const LearnScreen());
      await tester.tap(find.text('Letters & Sounds'));
      await tester.pumpAndSettle();
      expect(find.byType(LessonDetailScreen), findsOneWidget);
      expect(find.text('Lesson 1'), findsOneWidget);
    });

    testWidgets('app words follow the app language, lesson content does not', (tester) async {
      await show(tester, const LearnScreen(), locale: const Locale('fil'));
      expect(find.text('Matuto'), findsOneWidget);
      expect(find.text('Letters & Sounds'), findsOneWidget);

      await show(tester, const LearnScreen(), locale: const Locale('hil'));
      expect(find.text('Magtuon'), findsOneWidget);
      expect(find.text('Greetings & Courtesy'), findsOneWidget);
    });
  });

  group('S01 Learn · Intermediate', () {
    Map<String, LessonProgress> beginnerDone() => {
          for (final l in catalog.levels.first.lessons) l.id: l.hasQuiz ? passed(8) : done,
        };

    Future<void> openIntermediate(WidgetTester tester, {Map<String, LessonProgress>? lessons}) async {
      await show(tester, const LearnScreen(), lessons: lessons ?? beginnerDone());
      await tester.tap(find.text('Intermediate')); // level titles come from the lesson files
      await tester.pumpAndSettle();
    }

    Color badgeColor(WidgetTester tester, int number) {
      final box = tester.widget<Container>(find.ancestor(of: find.text('$number'), matching: find.byType(Container)).first);
      return (box.decoration! as BoxDecoration).color!;
    }

    testWidgets('a unit header above the first lesson of each unit', (tester) async {
      await openIntermediate(tester);
      for (final header in [
        'Unit 1 · Everyday life',
        'Unit 2 · Building sentences',
        'Unit 3 · Real life',
        'Unit 4 · Putting it together',
      ]) {
        expect(find.text(header), findsOneWidget, reason: header);
      }
      // In order: Unit 1, then its lessons, then Unit 2.
      final y = tester.getTopLeft;
      expect(y(find.text('Unit 1 · Everyday life')).dy, lessThan(y(find.text('Feelings, Health & Weather')).dy));
      expect(y(find.text('Past, Now & Later')).dy, lessThan(y(find.text('Unit 2 · Building sentences')).dy));
      expect(y(find.text('Unit 2 · Building sentences')).dy, lessThan(y(find.text('Who Did What')).dy));
    });

    testWidgets('rows: Lesson N numbers, meta, locked messages, lesson pictures', (tester) async {
      await openIntermediate(tester);
      expect(find.text('15 parts • 16 min'), findsOneWidget, reason: 'i01 is open');
      expect(find.text('Pass Lesson 1 quiz to unlock'), findsOneWidget, reason: 'i02 waits for i01');
      expect(find.text('Pass Lesson 11 quiz to unlock'), findsOneWidget, reason: 'i12 waits for i11');
      for (var n = 1; n <= 12; n++) {
        expect(find.text('$n'), findsOneWidget, reason: 'number $n');
      }
      // Every row shows its own icon, no placeholder.
      expect(find.byWidgetPredicate((w) => w.runtimeType.toString() == '_PlaceholderThumbnail'), findsNothing);
      final paths = tester.widgetList<LessonImage>(find.byType(LessonImage)).map((w) => w.path).toList();
      expect(paths, [for (final l in catalog.levels[1].lessons) l.icon]);
    });

    testWidgets('locked number badge is #79718B, on every level', (tester) async {
      await openIntermediate(tester);
      expect(badgeColor(tester, 1), isNot(const Color(0xFF79718B)), reason: 'i01 is current');
      expect(badgeColor(tester, 2), const Color(0xFF79718B));

      await show(tester, const LearnScreen());
      expect(badgeColor(tester, 3), const Color(0xFF79718B), reason: 'Beginner Lesson 3 is locked');
    });

    testWidgets('passing a quiz opens the next lesson', (tester) async {
      final i01 = catalog.levels[1].lessons.first.id;
      await openIntermediate(tester, lessons: {...beginnerDone(), i01: passed(10)});
      expect(find.text('13 parts • 16 min'), findsOneWidget, reason: 'i02 is open and shows its meta');
      expect(find.text('Pass Lesson 1 quiz to unlock'), findsNothing);
      expect(find.text('Pass Lesson 2 quiz to unlock'), findsOneWidget);
    });

    testWidgets('search keeps the unit header of the lessons it finds', (tester) async {
      await openIntermediate(tester);
      await tester.enterText(find.byType(TextField), 'reading');
      await tester.pump();
      expect(find.text('Reading a Story'), findsOneWidget);
      expect(find.text('Unit 3 · Real life'), findsOneWidget);
      expect(find.text('Unit 1 · Everyday life'), findsNothing);
    });

    testWidgets('Beginner shows its 4 unit headers above the right lessons', (tester) async {
      await show(tester, const LearnScreen());
      for (final header in [
        'Unit 1 · First steps',
        'Unit 2 · Numbers and time',
        'Unit 3 · People and places',
        'Unit 4 · Making sentences',
      ]) {
        expect(find.text(header), findsOneWidget, reason: header);
      }
      final lessons = catalog.levels.first.lessons;
      final y = tester.getTopLeft;
      // Unit 2 starts at Lesson 5, Unit 4 at Lesson 10.
      expect(y(find.text(lessons[3].title)).dy, lessThan(y(find.text('Unit 2 · Numbers and time')).dy));
      expect(y(find.text('Unit 2 · Numbers and time')).dy, lessThan(y(find.text(lessons[4].title)).dy));
      expect(y(find.text('Unit 4 · Making sentences')).dy, lessThan(y(find.text(lessons[9].title)).dy));
    });

    testWidgets('unit header in Filipino and Hiligaynon; the unit title stays as it is', (tester) async {
      for (final code in ['fil', 'hil']) {
        await show(tester, const LearnScreen(), lessons: beginnerDone(), locale: Locale(code));
        await tester.tap(find.text('Intermediate'));
        await tester.pumpAndSettle();
        expect(find.text('Yunit 1 · Everyday life'), findsOneWidget, reason: code);
      }
    });
  });

  group('S01 Learn · Advanced', () {
    List<Lesson> advancedLessons() => catalog.levels[2].lessons;
    Map<String, LessonProgress> intermediateDone() => {
          for (final l in [...catalog.levels[0].lessons, ...catalog.levels[1].lessons])
            l.id: l.hasQuiz ? passed(8) : done,
        };

    Future<void> openAdvanced(WidgetTester tester, {Map<String, LessonProgress>? lessons}) async {
      await show(tester, const LearnScreen(), lessons: lessons ?? intermediateDone());
      await tester.ensureVisible(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
    }

    testWidgets('unit headers, Lesson N numbers, lesson pictures, locked messages', (tester) async {
      await openAdvanced(tester);
      for (final header in [
        'Unit 1 · Sounding natural',
        'Unit 2 · Right words, right people',
        'Unit 3 · Telling and explaining',
        'Unit 4 · Hiligaynon in real life',
      ]) {
        expect(find.text(header), findsOneWidget, reason: header);
      }
      final first = advancedLessons().first;
      expect(find.text(first.title), findsOneWidget);
      expect(find.text('${first.partsCount} parts • ${first.estMinutes} min'), findsOneWidget);
      for (var n = 1; n <= 10; n++) {
        expect(find.text('$n'), findsOneWidget, reason: 'number $n');
      }
      expect(find.text('Pass Lesson 1 quiz to unlock'), findsOneWidget);
      expect(find.text('Pass Lesson 9 quiz to unlock'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w.runtimeType.toString() == '_PlaceholderThumbnail'), findsNothing);
      final paths = tester.widgetList<LessonImage>(find.byType(LessonImage)).map((w) => w.path).toList();
      expect(paths, [for (final l in advancedLessons()) l.icon]);
      // Unit 2 starts at Lesson 4.
      final y = tester.getTopLeft;
      expect(y(find.text(advancedLessons()[2].title)).dy, lessThan(y(find.text('Unit 2 · Right words, right people')).dy));
      expect(y(find.text('Unit 2 · Right words, right people')).dy, lessThan(y(find.text(advancedLessons()[3].title)).dy));
    });

    testWidgets('passing Lesson 1 quiz opens Lesson 2', (tester) async {
      final a = advancedLessons();
      await openAdvanced(tester, lessons: {...intermediateDone(), a[0].id: passed(14)});
      expect(find.text('${a[1].partsCount} parts • ${a[1].estMinutes} min'), findsWidgets);
      expect(find.text('Pass Lesson 1 quiz to unlock'), findsNothing);
      expect(find.text('Pass Lesson 2 quiz to unlock'), findsOneWidget);
    });

    testWidgets('search keeps the unit header of the lessons it finds', (tester) async {
      await openAdvanced(tester);
      await tester.enterText(find.byType(TextField), 'idioms');
      await tester.pump();
      expect(find.text('Idioms & Expressions'), findsOneWidget);
      expect(find.text('Unit 1 · Sounding natural'), findsOneWidget);
      expect(find.text('Unit 4 · Hiligaynon in real life'), findsNothing);
    });

    testWidgets('debug presets: Advanced Lesson 3 current', (tester) async {
      await show(tester, const LearnScreen());
      await tester.tap(find.byTooltip('Debug: set progress'));
      await tester.pumpAndSettle();
      final preset = find.text('Advanced: Lesson 3 current');
      await tester.scrollUntilVisible(preset, 200, scrollable: find.byType(Scrollable).last);
      await tester.tap(preset);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      final a = advancedLessons();
      expect(find.text('${a[2].partsCount} parts • ${a[2].estMinutes} min'), findsWidgets, reason: 'Lesson 3 is open');
      expect(find.text('Pass Lesson 3 quiz to unlock'), findsOneWidget, reason: 'Lesson 4 waits');
    });
  });

  group('S02 Lesson Detail', () {
    testWidgets('not started', (tester) async {
      await show(tester, const LessonDetailScreen(lessonId: 'b02'),
          lessons: {'b01': done});
      expect(find.text('Lesson 2'), findsOneWidget);
      expect(find.text('Greetings & Courtesy'), findsOneWidget);
      expect(find.text('12 parts • 10 min'), findsOneWidget);
      expect(find.text('In this lesson:'), findsOneWidget);
      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.text('0 / 12 parts'), findsOneWidget);
      expect(find.text('Retake the quiz'), findsNothing);
    });

    testWidgets('in progress', (tester) async {
      await show(tester, const LessonDetailScreen(lessonId: 'b02'),
          lessons: {'b01': done, 'b02': const LessonProgress(partsDone: 4)});
      expect(find.text('Continue lesson'), findsOneWidget);
      expect(find.text('4 / 12 parts'), findsOneWidget);
    });

    testWidgets('completed: best score chip, Review, Retake, no progress card', (tester) async {
      await show(tester, const LessonDetailScreen(lessonId: 'b02'),
          lessons: {'b01': done, 'b02': passed(7)});
      expect(find.text('Completed · Quiz 7/8'), findsOneWidget);
      expect(find.text('Review lesson'), findsOneWidget);
      expect(find.text('Retake the quiz'), findsOneWidget);
      expect(find.text('Lesson progress'), findsNothing);
    });

    testWidgets('letters version, not started and completed', (tester) async {
      await show(tester, const LessonDetailScreen(lessonId: 'b01'));
      expect(find.text('Lesson 1'), findsOneWidget);
      expect(find.text('8 parts • 8 min'), findsOneWidget);
      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.text('0 / 8 parts'), findsOneWidget);

      await show(tester, const LessonDetailScreen(lessonId: 'b01'), lessons: {'b01': done});
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Review lesson'), findsOneWidget);
      expect(find.text('Retake the quiz'), findsNothing);
    });

    testWidgets('the banner comes from coverImage', (tester) async {
      await show(tester, const LessonDetailScreen(lessonId: 'b02'), lessons: {'b01': done});
      final banner = tester.widget<Image>(find.byType(Image).first);
      expect((banner.image as AssetImage).assetName,
          'assets/images/lessons/lesson-02-greetings-hero.webp');
    });
  });

  testWidgets('a missing picture shows firefly_reading', (tester) async {
    // All banners and icons exist today, so check the fallback directly.
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: LessonImage(path: null, fallback: catalog.settings.missingPicture),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName,
        'assets/images/mascots/firefly_reading.webp');
  });
}
