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
      expect(find.text('Intermediate and Advanced: finish Beginner to unlock'),
          findsOneWidget);
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

    testWidgets('after all of Beginner, Intermediate opens (no lessons yet)', (tester) async {
      final lessons = catalog.levels.first.lessons;
      await show(tester, const LearnScreen(), lessons: {
        for (final l in lessons) l.id: l.hasQuiz ? passed(8) : done,
      });

      expect(find.text('Advanced: finish Intermediate to unlock'), findsOneWidget);
      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();
      expect(find.text('Lessons coming soon'), findsOneWidget);
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
