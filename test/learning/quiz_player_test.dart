// The quiz player (§4, §5, S06): seeded shuffling, the Q07 no-wrong-taps
// rule, the timer pausing for S06 and the sheets, time out = wrong, Leave
// dropping the attempt, a full Lesson 2 quiz (score without the unscored
// question, XP paid once), and Q09 when the mic isn't available.
//   flutter test test/learning/quiz_player_test.dart
//
// No pumpAndSettle while a timed question is open: its 30 s timer keeps
// ticking, so settling would run it down to "Time's up!".

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/logic/quiz_logic.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/screens/quiz_result_screen.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/services/voice_recorder.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/quiz/choice_questions.dart';
import 'package:hibalo_app/learning/widgets/quiz/practice_questions.dart';
import 'package:hibalo_app/learning/widgets/quiz/question_contract.dart';
import 'package:hibalo_app/learning/widgets/quiz/tile_questions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A recorder that never touches the mic or storage.
class FakeRecorder implements VoiceRecorder {
  FakeRecorder({this.available = true});

  final bool available;
  bool recording = false;
  bool _has = false;
  bool cleared = false;

  @override
  Future<bool> start() async {
    if (!available) return false;
    recording = true;
    return true;
  }

  @override
  Future<void> stop() async {
    if (recording) _has = true;
    recording = false;
  }

  @override
  bool get hasRecording => _has;

  @override
  Future<void> play() async {}

  @override
  Future<void> clear() async {
    _has = false;
    cleared = true;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;
  List<QuizQuestion> quizOf(String id) => lesson(id).quiz!.questions;

  Widget app(Widget home) => MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: home)),
      );

  Future<void> frames(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Opens the quiz over a stand-in "Learn" page on a small phone.
  Future<(LearningProgress, FakeRecorder)> open(
    WidgetTester tester,
    String lessonId, {
    int seed = 1,
    bool micAvailable = true,
  }) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(
      catalog,
      ProgressSnapshot(lessons: {
        'b01': const LessonProgress(partsDone: 8, completed: true),
        lessonId: LessonProgress(partsDone: lesson(lessonId).partsCount, completed: true),
      }),
    );
    final recorder = FakeRecorder(available: micAvailable);
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
      builder: (_) => QuizPlayerScreen(lessonId: lessonId, random: Random(seed), recorder: recorder),
    ));
    await frames(tester);
    return (progress, recorder);
  }

  Finder primary() => find.byType(FilledButton).last;

  /// What the timer chip shows ("00:24").
  String timerText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((s) => RegExp(r'^\d\d:\d\d$').hasMatch(s));

  Future<void> press(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await frames(tester);
  }

  /// Answers the question on screen (right or wrong), presses the primary
  /// button and closes the sheet with Continue.
  Future<void> answer(WidgetTester tester, QuizQuestion q, {required bool right}) async {
    switch (q) {
      case ChoiceQuestion c:
        final wrong = c.options.firstWhere((o) => o != c.correctOption);
        await press(tester, find.text(right ? c.correctOption : wrong).first);
      case BuildSentenceData b:
        final words = right ? b.answer : b.answer.reversed.toList();
        for (final w in words) {
          await press(tester, find.text(w).last);
        }
      case MatchPairsData m:
        if (!right) {
          // One wrong pair first: the question is then wrong (§7).
          await press(tester, find.text(m.pairs[0].hil));
          await press(tester, find.text(m.pairs[1].fil));
          await tester.pump(const Duration(milliseconds: 700));
        }
        for (final p in m.pairs) {
          await press(tester, find.text(p.hil));
          await press(tester, find.text(p.fil));
        }
      case TypeAnswerData t:
        await tester.enterText(find.byType(TextField), right ? t.accepted.first : 'mali');
        await frames(tester, 2);
      case DictationData d:
        await tester.enterText(find.byType(TextField), right ? d.accepted.first : 'mali');
        await frames(tester, 2);
      case SpeakingData():
        await press(tester, find.byIcon(Icons.mic_rounded).last);
        await press(tester, find.byIcon(Icons.stop_rounded));
      case OpenAnswerData():
        await tester.enterText(find.byType(TextField), 'Maayong aga!');
        await frames(tester, 2);
    }
    await press(tester, primary());
    if (q is! SpeakingData) await press(tester, find.text('Continue').last);
  }

  // ── Shuffling and the right answer ─────────────────────────────────────

  testWidgets('options are shown in the seeded order and the right one is tracked', (tester) async {
    final q = quizOf('b02').first as MultipleChoiceData;
    final order = shuffledOrder(q.options.length, Random(42));
    AnswerState? last;
    await tester.pumpWidget(app(MultipleChoiceQuestion(
      data: q,
      order: order,
      phase: QuestionPhase.answering,
      onChanged: (s) => last = s,
    )));
    final ys = [for (final i in order) tester.getTopLeft(find.text(q.options[i])).dy];
    expect(ys, [...ys]..sort(), reason: 'cards appear in the shuffled order');

    await tester.tap(find.text(q.options[order.firstWhere((i) => i != q.answer)]));
    await tester.pump();
    final wrong = q.options[order.firstWhere((i) => i != q.answer)];
    expect(last, AnswerState(ready: true, correct: false, text: wrong));
    await tester.tap(find.text(q.correctOption));
    await tester.pump();
    expect(last, AnswerState(ready: true, correct: true, text: q.correctOption));
  });

  // ── Q07 ────────────────────────────────────────────────────────────────

  group('Q07 match pairs', () {
    MatchPairsData q() => quizOf('b02').whereType<MatchPairsData>().first;

    Future<List<AnswerState>> play(WidgetTester tester, {required bool wrongTapFirst}) async {
      final states = <AnswerState>[];
      final data = q();
      await tester.pumpWidget(app(MatchPairsQuestion(
        data: data,
        rightOrder: [for (var i = data.pairs.length - 1; i >= 0; i--) i],
        phase: QuestionPhase.answering,
        onChanged: states.add,
        flash: const Duration(milliseconds: 100),
      )));
      if (wrongTapFirst) {
        await tester.tap(find.text(data.pairs[0].hil));
        await tester.tap(find.text(data.pairs[1].fil));
        await tester.pump(const Duration(milliseconds: 200));
      }
      for (final p in data.pairs) {
        await tester.tap(find.text(p.hil));
        await tester.pump();
        await tester.tap(find.text(p.fil));
        await tester.pump();
      }
      return states;
    }

    testWidgets('all matched with no wrong taps is right', (tester) async {
      final states = await play(tester, wrongTapFirst: false);
      expect(states.last, AnswerState(ready: true, correct: true, pairsRight: q().pairs.length));
      expect(states.where((s) => s.ready), hasLength(1), reason: 'Check only when all are matched');
    });

    testWidgets('one wrong tap makes it wrong even when all are matched later', (tester) async {
      final states = await play(tester, wrongTapFirst: true);
      // The two pairs in the wrong pick don't count for "N of M pairs".
      expect(states.last, AnswerState(ready: true, correct: false, pairsRight: q().pairs.length - 2));
    });
  });

  // ── Timer ──────────────────────────────────────────────────────────────

  testWidgets('S06: the timer pauses, Keep going keeps the answer and the time', (tester) async {
    await open(tester, 'b02');
    final q = quizOf('b02').first as MultipleChoiceData;
    expect(find.text('00:30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('00:25'), findsOneWidget);
    await press(tester, find.text(q.correctOption));

    // The chip text once S06 is open (the taps above take a little time).
    await press(tester, find.byTooltip('Leave the quiz'));
    final atLeave = timerText(tester);
    expect(find.text('Leave the quiz?'), findsOneWidget);
    expect(find.text("Your answers won't be saved."), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
    expect(timerText(tester), atLeave, reason: 'paused while S06 is open');

    await press(tester, find.text('Keep going'));
    // Same time as before (the 0.6 s of test frames may let one tick in).
    int secs(String s) => int.parse(s.substring(3));
    expect(secs(atLeave) - secs(timerText(tester)), lessThanOrEqualTo(1));
    expect(tester.widget<FilledButton>(primary()).onPressed, isNotNull,
        reason: 'the chosen answer is still there');
    await tester.pump(const Duration(seconds: 2));
    expect(timerText(tester), isNot(atLeave), reason: 'running again');
  });

  testWidgets('a sheet holds the quiz: the next timer starts only after Continue', (tester) async {
    await open(tester, 'b02');
    final q = quizOf('b02').first as MultipleChoiceData;
    await press(tester, find.text(q.correctOption));
    await press(tester, primary());
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('+10 XP'), findsWidgets);

    await tester.pump(const Duration(seconds: 40));
    expect(find.text('Correct!'), findsOneWidget, reason: 'nothing runs out behind the sheet');
    await press(tester, find.text('Continue').last);
    expect(find.text('2 / 9'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
  });

  testWidgets("time out: input locks, F03 shows the answer, it counts as wrong", (tester) async {
    final (progress, _) = await open(tester, 'b02');
    final questions = quizOf('b02');
    final first = questions.first as MultipleChoiceData;

    await tester.pump(const Duration(seconds: 30));
    await frames(tester);
    expect(find.text("Time's up!"), findsOneWidget);
    expect(find.text('Correct answer:'), findsOneWidget);
    expect(find.text(first.correctOption), findsWidgets);
    await press(tester, find.text('Continue').last);

    for (final q in questions.skip(1)) {
      await answer(tester, q, right: true);
    }
    await frames(tester);
    expect(find.byType(QuizResultScreen), findsOneWidget);
    final total = questions.where((q) => q.scored).length;
    // 7 of 8 passes (≥ 80%): the passed line ends with "!".
    expect(find.text('You got ${total - 1} out of $total correct!'), findsOneWidget);
    expect(progress.progressFor('b02').bestScore, total - 1);
    expect(progress.xp, 10 * (total - 1), reason: 'no XP for the timed-out question');
  });

  // ── Leave ──────────────────────────────────────────────────────────────

  testWidgets('Leave drops the attempt: back to Learn, no score, no XP', (tester) async {
    final (progress, recorder) = await open(tester, 'b02');
    final q = quizOf('b02').first as MultipleChoiceData;
    await press(tester, find.text(q.correctOption));
    await press(tester, primary());
    await press(tester, find.text('Continue').last);

    await press(tester, find.byTooltip('Leave the quiz'));
    await press(tester, find.text('Leave'));
    expect(find.text('LEARN'), findsOneWidget);
    expect(progress.xp, 0);
    expect(progress.progressFor('b02').bestScore, isNull);
    expect(progress.progressFor('b02').passed, isFalse);
    expect(recorder.cleared, isTrue);
  });

  testWidgets('Android back opens Leave quiz', (tester) async {
    await open(tester, 'b02');
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    await nav.maybePop();
    await frames(tester);
    expect(find.text('Leave the quiz?'), findsOneWidget);
  });

  // ── A whole quiz ───────────────────────────────────────────────────────

  testWidgets('Lesson 2: every question right passes, pays XP once, unlocks Lesson 3', (tester) async {
    final (progress, recorder) = await open(tester, 'b02');
    final questions = quizOf('b02');
    final total = questions.where((q) => q.scored).length;
    expect(total, lessThan(questions.length), reason: 'Q09 is not scored');

    for (final q in questions) {
      await answer(tester, q, right: true);
    }
    await frames(tester);
    expect(find.text('Perpekto!'), findsOneWidget);
    expect(find.text('You got $total out of $total correct!'), findsOneWidget);
    expect(find.text('+${10 * total} XP'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(progress.xp, 10 * total);
    expect(progress.progressFor('b02').passed, isTrue);
    expect(progress.rules.isLessonUnlocked(lesson('b03')), isTrue);
    expect(recorder.hasRecording, isFalse, reason: 'the Q09 recording is deleted at the end');

    // Continue (→ S01), then a retake: all right again pays nothing new.
    await press(tester, find.text('Continue'));
    expect(find.text('LEARN'), findsOneWidget);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(
      builder: (_) => QuizPlayerScreen(lessonId: 'b02', random: Random(9), recorder: FakeRecorder()),
    ));
    await frames(tester);
    // F01 shows no "+10 XP" for a question already paid.
    final q1 = questions.first as MultipleChoiceData;
    await press(tester, find.text(q1.correctOption));
    await press(tester, primary());
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('+10 XP')), findsNothing);
    await press(tester, find.text('Continue').last);
    for (final q in questions.skip(1)) {
      await answer(tester, q, right: true);
    }
    await frames(tester);
    expect(find.text('+0 XP'), findsOneWidget);
    expect(progress.xp, 10 * total);
  });

  testWidgets('wrong answers show F02 with the answer and are not paid', (tester) async {
    final (progress, _) = await open(tester, 'b02');
    final questions = quizOf('b02');
    final first = questions.first as MultipleChoiceData;
    final wrong = first.options.firstWhere((o) => o != first.correctOption);
    await press(tester, find.text(wrong));
    await press(tester, primary());
    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('Correct answer:'), findsOneWidget);
    // F02 has an audio button because this question has answerAudio.
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.byIcon(Icons.volume_up_rounded)),
        findsOneWidget);
    await press(tester, find.text('Continue').last);

    // Q07 wrong: F02 lists the pairs.
    for (final q in questions.skip(1)) {
      if (q is MatchPairsData) {
        await answer(tester, q, right: false);
        continue;
      }
      await answer(tester, q, right: true);
    }
    await frames(tester);
    final total = questions.where((q) => q.scored).length;
    expect(find.text('You got ${total - 2} out of $total correct.'), findsOneWidget);
    expect(progress.xp, 10 * (total - 2));
    expect(progress.progressFor('b02').passed, (total - 2) / total >= 0.8);
  });

  // ── Q09 ────────────────────────────────────────────────────────────────

  testWidgets('Q09: mic not available shows the message and allows Continue', (tester) async {
    final q = quizOf('b02').whereType<SpeakingData>().first;
    AnswerState? last;
    await tester.pumpWidget(app(SpeakingQuestion(
      data: q,
      recorder: FakeRecorder(available: false),
      onChanged: (s) => last = s,
    )));
    expect(find.text('Mic not available. You can skip this one.'), findsNothing);
    await tester.tap(find.byIcon(Icons.mic_rounded).last);
    await tester.pump();
    expect(find.text('Mic not available. You can skip this one.'), findsOneWidget);
    expect(last, const AnswerState(ready: true));
  });

  testWidgets('Q09: Continue only after a recording, and not while recording', (tester) async {
    final q = quizOf('b02').whereType<SpeakingData>().first;
    final recorder = FakeRecorder();
    final states = <AnswerState>[];
    await tester.pumpWidget(app(SpeakingQuestion(data: q, recorder: recorder, onChanged: states.add)));
    await tester.tap(find.byIcon(Icons.mic_rounded).last);
    await tester.pump();
    expect(states.last.ready, isFalse);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pump();
    expect(states.last.ready, isTrue);
    expect(recorder.hasRecording, isTrue);
  });
}
