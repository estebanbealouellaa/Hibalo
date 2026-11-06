// The lesson part player: Back/Next, last-part button, Leave, saving parts, quick check XP once, and every part of every lesson.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/parts.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/screens/lesson_player_screen.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/feedback_sheet.dart';
import 'package:hibalo_app/learning/widgets/segmented_progress.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;

  /// Opens the player over a stand-in "Learn" page (named like the real S01
  /// route, so Leave can find it), on a small phone (360 × 760).
  Future<LearningProgress> open(
    WidgetTester tester,
    String lessonId, {
    int startPart = 0,
    Map<String, LessonProgress> lessons = const {},
    Set<String> paid = const {},
  }) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final progress = LearningProgress.ready(
      catalog,
      ProgressSnapshot(lessons: {...lessons}, paid: {...paid}),
    );
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: progress,
      child: MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        home: const Scaffold(body: Text('HOME')),
      ),
    ));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: LearningRoutes.learnRoute),
      builder: (_) => const Scaffold(body: Text('LEARN')),
    ));
    nav.push(MaterialPageRoute<void>(
      builder: (_) => LessonPlayerScreen(lessonId: lessonId, startPart: startPart),
    ));
    await tester.pumpAndSettle();
    return progress;
  }

  Finder caption(int lessonNo, int part, int total) =>
      find.text('Lesson $lessonNo · Part $part of $total');

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  Future<void> tapBack(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
  }

  double backOpacity(WidgetTester tester) => tester
      .widget<Opacity>(find.ancestor(
        of: find.byIcon(Icons.arrow_back_rounded),
        matching: find.byType(Opacity),
      ))
      .opacity;

  testWidgets('bar, caption and the Back/Next rule through cards', (tester) async {
    final progress = await open(tester, 'b02');

    expect(tester.widget<SegmentedProgress>(find.byType(SegmentedProgress)).count, 12);
    expect(caption(2, 1, 12), findsOneWidget);
    expect(backOpacity(tester), 0.38); // very first step: Back disabled

    await tapNext(tester); // part 1 done → words part, card 1
    expect(caption(2, 2, 12), findsOneWidget);
    expect(find.text('1 / 4'), findsOneWidget);
    expect(progress.progressFor('b02').partsDone, 1); // saved
    expect(backOpacity(tester), 1);

    await tapNext(tester); // card 2, same part: the bar doesn't move
    expect(find.text('2 / 4'), findsOneWidget);
    expect(caption(2, 2, 12), findsOneWidget);
    expect(tester.widget<SegmentedProgress>(find.byType(SegmentedProgress)).current, 1);

    await tapBack(tester);
    expect(find.text('1 / 4'), findsOneWidget);
    await tapBack(tester); // card 1 → previous part
    expect(caption(2, 1, 12), findsOneWidget);
  });

  testWidgets('Back from a part opens the previous part at its last step', (tester) async {
    await open(tester, 'b02', startPart: 2);
    expect(caption(2, 3, 12), findsOneWidget);
    await tapBack(tester);
    expect(caption(2, 2, 12), findsOneWidget);
    expect(find.text('4 / 4'), findsOneWidget);
  });

  group('quick check', () {
    QuickCheckPartData check() => lesson('b02').parts[2] as QuickCheckPartData;

    testWidgets('right answer: green, +5 XP once, Continue goes on', (tester) async {
      final progress = await open(tester, 'b02', startPart: 2);
      final part = check();

      // No Next before answering.
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

      await tester.tap(find.text(part.options[part.answer]));
      await tester.pumpAndSettle();
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('+5 XP'), findsOneWidget);
      expect(find.text(part.explain), findsOneWidget);
      expect(progress.xp, 5);
      expect(find.text('5 XP'), findsOneWidget); // the lesson XP chip

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(caption(2, 4, 12), findsOneWidget);
      expect(progress.progressFor('b02').partsDone, 3);
    });

    testWidgets('a right answer already paid shows no XP', (tester) async {
      final part = check();
      final progress = await open(tester, 'b02',
          startPart: 2, paid: {LearningProgress.quickCheckPaidId(part.id)});
      await tester.tap(find.text(part.options[part.answer]));
      await tester.pumpAndSettle();
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('+5 XP'), findsNothing);
      expect(progress.xp, 0);
    });

    testWidgets('wrong answer: Not quite with the correct answer, no XP', (tester) async {
      final progress = await open(tester, 'b02', startPart: 2);
      final part = check();
      final wrong = part.options[(part.answer + 1) % part.options.length];
      await tester.tap(find.text(wrong));
      await tester.pumpAndSettle();
      expect(find.text('Not quite'), findsOneWidget);
      expect(find.text('Correct answer:'), findsOneWidget);
      expect(find.text(part.options[part.answer]), findsNWidgets(2)); // card + sheet
      expect(progress.xp, 0);
    });
  });

  testWidgets('last part: Finish & practice saves the lesson and pays 20 XP once', (tester) async {
    final progress = await open(tester, 'b02', startPart: 11,
        lessons: {'b02': const LessonProgress(partsDone: 11)});
    expect(find.text('Finish & practice'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // S03 Lesson complete, with the lesson XP just paid.
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('You finished Lesson 2: ${lesson('b02').title}.'), findsOneWidget);
    expect(find.text('+20'), findsOneWidget);
    expect(find.text('${lesson('b02').items.length}'), findsOneWidget);
    expect(find.text('New words'), findsOneWidget);
    final p = progress.progressFor('b02');
    expect(p.completed, isTrue);
    expect(p.partsDone, 12);
    expect(progress.xp, 20);
    expect(progress.lessonsCompleted, 1);
    expect(progress.streak, 1);

    // "Take the lesson quiz" → question 1.
    await tester.tap(find.text('Take the lesson quiz'));
    // (No pumpAndSettle: the quiz's 30 s timer keeps ticking.)
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(QuizPlayerScreen), findsOneWidget);
    expect(find.text('1 / 9'), findsOneWidget);
  });

  testWidgets('Lesson 1 ends with Finish lesson', (tester) async {
    await open(tester, 'b01', startPart: 7);
    expect(find.text('Finish lesson'), findsOneWidget);
  });

  testWidgets('X: Keep going keeps the state, Leave goes to Learn', (tester) async {
    final progress = await open(tester, 'b02', startPart: 1);
    await tapNext(tester); // card 2 of the words part
    expect(find.text('2 / 4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Leave this lesson?'), findsOneWidget);
    expect(find.text("You'll restart this part next time."), findsOneWidget);
    await tester.tap(find.text('Keep going'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('LEARN'), findsOneWidget);
    // The part in progress was not saved.
    expect(progress.progressFor('b02').partsDone, 0);
  });

  testWidgets('system back: one step back, or Leave on the very first step', (tester) async {
    await open(tester, 'b02');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Leave this lesson?'), findsOneWidget);
    await tester.tap(find.text('Keep going'));
    await tester.pumpAndSettle();

    await tapNext(tester);
    await tapNext(tester);
    expect(find.text('2 / 4'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('1 / 4'), findsOneWidget);
  });

  testWidgets('letters: seen count, chips jump, Back from letter 1 leaves the part', (tester) async {
    await open(tester, 'b01', startPart: 2);
    expect(find.text('1 / 19 seen'), findsOneWidget);
    await tapNext(tester);
    expect(find.text('2 / 19 seen'), findsOneWidget);
    expect(caption(1, 3, 8), findsOneWidget);

    await tester.ensureVisible(find.text('NG'));
    await tester.tap(find.text('NG'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 19 seen'), findsOneWidget);
    expect(find.text('11 / 19'), findsOneWidget);
    // The card moved too: its big tile shows NG next to the chip.
    expect(find.text('NG'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Aa').last);
    await tester.tap(find.text('Aa').last);
    await tester.pumpAndSettle();
    await tapBack(tester);
    expect(caption(1, 2, 8), findsOneWidget);
  });

  testWidgets('letters: a swipe changes the card and counts as seen', (tester) async {
    await open(tester, 'b01', startPart: 2);
    await tester.drag(find.text('Aa').first, const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 19 seen'), findsOneWidget);
    expect(find.text('Bb'), findsNWidgets(2)); // card tile + chip
    // The speaker is there even before the clip is recorded; tapping it
    // plays nothing and doesn't fail.
    await tester.tap(find.byIcon(Icons.volume_up_rounded).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('letters: only the current card shows, full width, no peek', (tester) async {
    await open(tester, 'b01', startPart: 2);
    final card = find.byWidgetPredicate((w) => w.runtimeType.toString() == '_LetterCard');
    // One card on screen, 20 px in from each side of the 360 px phone.
    expect(card, findsOneWidget);
    final rect = tester.getRect(card);
    expect(rect.left, 20);
    expect(rect.right, 340);
    // The next letter appears only as its chip, never as a card at the edge.
    expect(find.text('Bb'), findsOneWidget);

    await tapNext(tester);
    expect(card, findsOneWidget);
    expect(tester.getRect(card).left, 20);
    expect(find.text('Aa'), findsOneWidget); // letter 1 is a chip again
  });

  testWidgets('feedback sheets use the Figma mascots', (tester) async {
    // F01 firefly_celebrate, F02/F03 firefly_wrong, F04 firefly_reading.
    const expected = {
      FeedbackType.correct: 'firefly_celebrate',
      FeedbackType.wrong: 'firefly_wrong',
      FeedbackType.timeout: 'firefly_wrong',
      FeedbackType.info: 'firefly_reading',
    };
    for (final MapEntry(key: type, value: mascot) in expected.entries) {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        home: Scaffold(body: FeedbackSheet(type: type, answer: 'Palihog')),
      ));
      final image = tester.widget<Image>(find.byType(Image)).image as AssetImage;
      expect(image.assetName, 'assets/images/mascots/$mascot.webp', reason: '$type');
    }
  });

  testWidgets('word card: audio buttons show without a recording', (tester) async {
    await open(tester, 'b02', startPart: 1);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await tester.tap(find.byIcon(Icons.hourglass_top_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialogue: avatars, tap a bubble, Show all Filipino', (tester) async {
    final index = lesson('b02').parts.indexWhere((p) => p is DialoguePartData);
    final part = lesson('b02').parts[index] as DialoguePartData;
    await open(tester, 'b02', startPart: index);

    expect(find.byType(SvgPicture), findsNWidgets(part.lines.length));
    expect(find.text(part.lines.first.fil), findsNothing);
    await tester.tap(find.text(part.lines.first.hil));
    await tester.pumpAndSettle();
    expect(find.text(part.lines.first.fil), findsOneWidget);
    expect(find.text('Tap to hide Filipino'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    for (final line in part.lines.take(2)) {
      expect(find.text(line.fil), findsOneWidget);
    }
  });

  testWidgets('every part of every lesson draws on a small phone', (tester) async {
    for (final l in catalog.levels.first.lessons) {
      for (var i = 0; i < l.partsCount; i++) {
        await open(tester, l.id, startPart: i);
        expect(tester.takeException(), isNull, reason: '${l.id} part ${i + 1}');
        expect(caption(l.order, i + 1, l.partsCount), findsOneWidget,
            reason: '${l.id} part ${i + 1}');
        // Step through multi-step parts too (cards and letters).
        for (var s = 1; s < l.parts[i].stepCount; s++) {
          if (l.parts[i] is LettersPartData) break; // tested above
          await tapNext(tester);
          expect(tester.takeException(), isNull, reason: '${l.id} part ${i + 1} step $s');
        }
      }
    }
  });
}
