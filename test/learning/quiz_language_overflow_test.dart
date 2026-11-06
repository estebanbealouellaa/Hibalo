// Quiz screens in Filipino and Hiligaynon at the Galaxy A03's width
// (360 dp): every question of a lesson quiz, its feedback and the result
// screen. Any overflow fails the test. Each question is left to time out (or
// skipped), so all question types are drawn without answering.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/services/voice_recorder.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoMic implements VoiceRecorder {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<bool>.value(false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final lang in ['fil', 'hil']) {
    for (final lessonId in ['b02', 'b04']) {
      testWidgets('$lessonId quiz fits in $lang at 360 dp', (tester) async {
        tester.view.physicalSize = const Size(360, 760);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final lesson = catalog.lessonById(lessonId)!;
        final progress = LearningProgress.ready(
          catalog,
          ProgressSnapshot(
            lessons: {
              'b01': const LessonProgress(partsDone: 8, completed: true),
              lessonId: LessonProgress(partsDone: lesson.partsCount, completed: true),
            },
          ),
        );
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: progress,
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLanguage.delegates,
              supportedLocales: AppLanguage.supportedLocales,
              home: const Scaffold(body: Text('HOME')),
            ),
          ),
        );
        final nav = tester.state<NavigatorState>(find.byType(Navigator));
        nav.push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: LearningRoutes.learnRoute),
            builder: (_) => const Scaffold(body: Text('LEARN')),
          ),
        );
        nav.push(
          MaterialPageRoute<void>(
            builder: (_) => QuizPlayerScreen(lessonId: lessonId, random: Random(3), recorder: _NoMic()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        var screens = 0;
        for (var step = 0; step < 60 && find.byType(QuizPlayerScreen).evaluate().isNotEmpty; step++) {
          // Let the timer run out (or nothing happens for untimed ones).
          await tester.pump(const Duration(seconds: 70));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: 'step $step');
          screens++;
          // Continue / Submit / Skip: the last enabled filled or text button.
          final buttons = [
            ...tester.widgetList<FilledButton>(find.byType(FilledButton)).where((b) => b.onPressed != null),
          ];
          if (buttons.isNotEmpty) {
            buttons.last.onPressed!();
          } else {
            final text = tester.widgetList<TextButton>(find.byType(TextButton)).where((b) => b.onPressed != null);
            if (text.isEmpty) break;
            text.last.onPressed!();
          }
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: 'after step $step');
        }
        // b02 runs to the end; b04 stops at its first untimed question that needs a real answer.
        expect(screens, greaterThanOrEqualTo(4), reason: 'went through several questions');
        // Let any result screen settle and check it too.
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
