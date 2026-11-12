// Intermediate quizzes: Q11 read + listen, the no-audio fallbacks (Q02 audioText, Q08, Q09, Q10 transcript,
// Q11 listen), the Sample answer transcript, and every Intermediate quiz passing all right.
//   flutter test test/learning/intermediate_quiz_test.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/parts/part_common.dart' show AudioButton;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_player_test.dart' show FakeRecorder;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;
  List<QuizQuestion> quizOf(String id) => lesson(id).quiz!.questions;

  Future<void> frames(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<LearningProgress> open(WidgetTester tester, String lessonId) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(
      catalog,
      ProgressSnapshot(lessons: {
        lessonId: LessonProgress(partsDone: lesson(lessonId).partsCount, completed: true),
      }),
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
      builder: (_) => QuizPlayerScreen(lessonId: lessonId, random: Random(1), recorder: FakeRecorder()),
    ));
    await frames(tester);
    return progress;
  }

  Finder primary() => find.byType(FilledButton).last;

  Future<void> press(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await frames(tester);
  }

  bool hasTimer(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .any((t) => RegExp(r'^\d\d:\d\d$').hasMatch(t.data ?? ''));

  /// Answers the question on screen right, presses the primary button and closes the sheet.
  Future<void> answerRight(WidgetTester tester, QuizQuestion q) async {
    switch (q) {
      case ChoiceQuestion c:
        await press(tester, find.text(c.correctOption).last);
      case BuildSentenceData b:
        for (final w in b.answer) {
          await press(tester, find.text(w).last);
        }
      case MatchPairsData m:
        for (final p in m.pairs) {
          // Left column first, then right (a pair may have the same word on both sides, e.g. ubo = ubo).
          await press(tester, find.text(p.hil).first);
          await press(tester, find.text(p.fil).last);
        }
      case TypeAnswerData t:
        await tester.enterText(find.byType(TextField), t.accepted.first);
        await frames(tester, 2);
      case DictationData d:
        await tester.enterText(find.byType(TextField), d.accepted.first);
        await frames(tester, 2);
      case SpeakingData():
        await press(tester, find.byIcon(Icons.mic_rounded).last);
        await press(tester, find.byIcon(Icons.stop_rounded));
      case OpenAnswerData():
        await tester.enterText(find.byType(TextField), 'Nagatinda si Manang Rosa.');
        await frames(tester, 2);
      case SpotMistakeData s:
        await press(tester, find.text(s.wrongWord).last);
    }
    await press(tester, primary());
    if (q is! SpeakingData) await press(tester, find.text('Continue').last);
  }

  /// Opens [lessonId]'s quiz and answers every question before [index] right.
  Future<QuizQuestion> goTo(WidgetTester tester, String lessonId, int index) async {
    await open(tester, lessonId);
    final qs = quizOf(lessonId);
    for (final q in qs.take(index)) {
      await answerRight(tester, q);
    }
    return qs[index];
  }

  testWidgets('Q11 read: Reading chip, the story, the question, no timer', (tester) async {
    final q = await goTo(tester, 'i01', 8) as ReadAnswerData;
    expect(q.mode, ReadAnswerMode.read);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Read the story'), findsOneWidget);
    expect(find.text(q.passage.first.hil, findRichText: true), findsOneWidget);
    expect(find.text(q.question), findsOneWidget);
    expect(find.text('Read the story, then choose the correct answer.'), findsOneWidget);
    expect(hasTimer(tester), isFalse, reason: 'reading takes time: no timer');

    // Pick the right option, Check → Correct!
    await press(tester, find.text(q.correctOption).last);
    await press(tester, primary());
    expect(find.text('Correct!'), findsOneWidget);
  });

  testWidgets('Q11 read on a dialogue: "Speaker: line"', (tester) async {
    final q = await goTo(tester, 'i08', 8) as ReadAnswerData;
    expect(find.text('Read the conversation'), findsOneWidget);
    final first = q.passage.first;
    expect(find.text('${first.speaker}: ${first.hil}', findRichText: true), findsOneWidget);
    expect(find.text('Read the conversation, then choose the correct answer.'), findsOneWidget);
  });

  testWidgets('Q11 listen without clips: the conversation as text, Audio coming soon', (tester) async {
    final q = await goTo(tester, 'i10', 4) as ReadAnswerData;
    expect(q.mode, ReadAnswerMode.listen);
    expect(q.clips, isEmpty, reason: 'not recorded yet');
    expect(find.text('Listening'), findsOneWidget);
    expect(find.text('Read the conversation'), findsOneWidget);
    expect(find.text('Audio coming soon'), findsOneWidget);
    expect(find.byType(AudioButton), findsNothing);
    expect(find.text('${q.passage.first.speaker}: ${q.passage.first.hil}', findRichText: true), findsOneWidget);
    expect(hasTimer(tester), isFalse);
  });

  testWidgets('Q02 without its clip: the words (audioText) in place of the play button', (tester) async {
    final q = await goTo(tester, 'i01', 5) as ListeningData;
    expect(q.audio, isNull);
    expect(find.text(q.audioText!), findsOneWidget);
    expect(find.text('Audio coming soon'), findsOneWidget);
    expect(find.byType(AudioButton), findsNothing);
    await press(tester, find.text(q.correctOption).last);
    await press(tester, primary());
    expect(find.text('Correct!'), findsOneWidget);
  });

  testWidgets('Q08 without its clip: the sentence to write, then typing it is right', (tester) async {
    final q = await goTo(tester, 'i01', 9) as DictationData;
    expect(q.audio, isNull);
    expect(find.text(q.accepted.first), findsOneWidget);
    expect(find.text('Audio coming soon'), findsOneWidget);
    await tester.enterText(find.byType(TextField), q.accepted.first);
    await frames(tester, 2);
    await press(tester, primary());
    expect(find.text('Correct!'), findsOneWidget);
  });

  testWidgets('Q09 without its clip: Audio coming soon, Native speaker disabled, recording still works', (tester) async {
    final q = await goTo(tester, 'i01', 12) as SpeakingData;
    expect(q.audio, isNull);
    expect(find.text(q.text), findsOneWidget);
    expect(find.text('Audio coming soon'), findsOneWidget);
    expect(find.byType(AudioButton), findsNothing);
    await press(tester, find.byIcon(Icons.mic_rounded).last);
    await press(tester, find.byIcon(Icons.stop_rounded));
    await press(tester, primary());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Q10 about a clip: transcript while it isn\'t recorded, and on the Sample answer sheet', (tester) async {
    final q = await goTo(tester, 'i10', 12) as OpenAnswerData;
    expect(q.audio, isNull);
    expect(q.transcript, isNotNull);
    expect(find.text(q.transcript!), findsOneWidget);
    expect(find.text('Audio coming soon'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Pagod na si Manang Rosa.');
    await frames(tester, 2);
    await press(tester, primary());
    expect(find.text('Sample answer:'), findsOneWidget);
    expect(find.text(q.modelAnswer), findsOneWidget);
    expect(find.text('Transcript'), findsOneWidget);
    expect(find.text(q.transcript!), findsNWidgets(2), reason: 'in the question and on the sheet');
  });

  testWidgets('every Intermediate quiz passes when every answer is right', (tester) async {
    for (final l in catalog.levels[1].lessons) {
      final progress = await open(tester, l.id);
      for (final q in quizOf(l.id)) {
        await answerRight(tester, q);
        expect(tester.takeException(), isNull, reason: '${l.id} ${q.id}');
      }
      await frames(tester);
      expect(find.text('Perpekto!'), findsOneWidget, reason: l.id);
      expect(progress.progressFor(l.id).passed, isTrue, reason: l.id);
      final next = catalog.nextLesson(l.id);
      expect(find.text(next == null ? 'Intermediate complete!' : 'Lesson ${next.order} unlocked'), findsOneWidget,
          reason: l.id);
    }
  });
}
