// The 4-tab shell, the Continue card and the Phrase of the day.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/logic/unlocking.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/screens/learn_screen.dart';
import 'package:hibalo_app/learning/screens/lesson_detail_screen.dart';
import 'package:hibalo_app/learning/screens/lesson_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/screens/home/home_logic.dart';
import 'package:hibalo_app/screens/home/home_tab.dart';
import 'package:hibalo_app/screens/home_screen.dart';
import 'package:hibalo_app/screens/profile_screen.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A tab that counts taps, to show its state survives tab switches.
class _CounterTab extends StatefulWidget {
  const _CounterTab(this.name);
  final String name;
  @override
  State<_CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<_CounterTab> {
  int taps = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(onPressed: () => setState(() => taps++), child: Text('${widget.name} $taps')),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;
  List<Lesson> beginner() => catalog.levels.first.lessons;

  Future<HomeScreenState> shell(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        theme: buildAppTheme(),
        home: HomeScreen(
          onLogout: () {},
          userDoc: Stream.value({'username': 'Ana'}),
          tabs: const [_CounterTab('Home'), _CounterTab('Translate'), _CounterTab('Learn'), _CounterTab('Me')],
        ),
      ),
    );
    await tester.pump();
    return tester.state<HomeScreenState>(find.byType(HomeScreen));
  }

  group('Tab shell', () {
    testWidgets('4 tabs; each keeps its state when switching', (tester) async {
      await shell(tester);
      for (final label in ['Home', 'Translate', 'Learn', 'Me']) {
        expect(find.text(label), findsOneWidget, reason: 'nav item $label');
      }
      await tester.tap(find.text('Home 0'));
      await tester.pump();
      await tester.tap(find.text('Home 1'));
      await tester.pump();
      expect(find.text('Home 2'), findsOneWidget);

      await tester.tap(find.text('Translate'));
      await tester.pump();
      await tester.tap(find.text('Translate 0'));
      await tester.pump();
      await tester.tap(find.text('Learn'));
      await tester.pump();
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(find.text('Home 2'), findsOneWidget, reason: 'Home kept its count');
      await tester.tap(find.text('Translate'));
      await tester.pump();
      expect(find.text('Translate 1'), findsOneWidget, reason: 'Translate kept its count');
    });

    testWidgets('a tab the user leaves goes back to its first page', (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: LearningProgress.ready(catalog, ProgressSnapshot()),
          child: MaterialApp(
            localizationsDelegates: AppLanguage.delegates,
            supportedLocales: AppLanguage.supportedLocales,
            theme: buildAppTheme(),
            home: HomeScreen(
              onLogout: () {},
              userDoc: Stream.value({'username': 'Ana'}),
              tabs: [
                const _CounterTab('Home'),
                const _CounterTab('Translate'),
                const _CounterTab('Learn'),
                MeTab(userName: 'Ana', photoUrl: null, onLogout: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final state = tester.state<HomeScreenState>(find.byType(HomeScreen));

      // Me › Settings, then Home, then Me again: the Me page, not Settings.
      state.select(HomeScreen.meTab);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Clear translation history'), findsOneWidget);
      state.select(HomeScreen.homeTab);
      await tester.pumpAndSettle();
      state.select(HomeScreen.meTab);
      await tester.pumpAndSettle();
      expect(find.text('Clear translation history'), findsNothing);
      expect(find.text('Account'), findsOneWidget, reason: 'back on the Me page');
      expect(MeTab.handleBack(), isFalse, reason: 'nothing left open');

      // Learn is rebuilt fresh after it is left.
      state.select(HomeScreen.learnTab);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Learn 0'));
      await tester.pump();
      expect(find.text('Learn 1'), findsOneWidget);
      state.select(HomeScreen.homeTab);
      await tester.pumpAndSettle();
      state.select(HomeScreen.learnTab);
      await tester.pumpAndSettle();
      expect(find.text('Learn 0'), findsOneWidget, reason: 'a fresh lesson list');

      // Re-selecting the open tab changes nothing.
      await tester.tap(find.text('Learn 0'));
      await tester.pump();
      state.select(HomeScreen.learnTab);
      await tester.pumpAndSettle();
      expect(find.text('Learn 1'), findsOneWidget);
    });

    testWidgets('Android back: other tabs go to Home; on Home the app may close', (tester) async {
      final state = await shell(tester);
      for (final tab in [HomeScreen.translateTab, HomeScreen.learnTab, HomeScreen.meTab]) {
        state.select(tab);
        await tester.pump();
        expect(tester.widget<PopScope>(find.byWidgetPredicate((w) => w is PopScope)).canPop, isFalse);
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(state.tab, HomeScreen.homeTab, reason: 'back from tab $tab');
      }
      // On Home the shell lets the pop through (the system closes the app).
      expect(tester.widget<PopScope>(find.byWidgetPredicate((w) => w is PopScope)).canPop, isTrue);
    });

    testWidgets('Back to lessons / Leave show the Learn tab', (tester) async {
      final state = await shell(tester);
      expect(state.tab, HomeScreen.homeTab);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('LESSON'))));
      await tester.pumpAndSettle();
      LearningRoutes.backToLearn(tester.element(find.text('LESSON')));
      await tester.pumpAndSettle();
      expect(find.text('LESSON'), findsNothing);
      expect(state.tab, HomeScreen.learnTab);
    });
  });

  testWidgets('Learn tab: S01 has no back arrow, also after a lesson opens and closes', (tester) async {
    tester.view.physicalSize = const Size(375, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(catalog, ProgressSnapshot());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: MaterialApp(
          theme: buildAppTheme(),
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          home: HomeScreen(
            onLogout: () {},
            userDoc: Stream.value({'username': 'Ana'}),
            tabs: const [_CounterTab('Home'), _CounterTab('Translate'), LearnScreen(), _CounterTab('Me')],
          ),
        ),
      ),
    );
    final state = tester.state<HomeScreenState>(find.byType(HomeScreen));
    state.select(HomeScreen.learnTab);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back'), findsNothing);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('LESSON'))));
    await tester.pumpAndSettle();
    await progress.savePartDone(lesson('b01'), 0); // rebuilds S01 underneath
    LearningRoutes.backToLearn(tester.element(find.text('LESSON')));
    await tester.pumpAndSettle();
    expect(state.tab, HomeScreen.learnTab);
    expect(find.byTooltip('Back'), findsNothing);
  });

  group('Continue card choice', () {
    ContinuePick pick(Map<String, LessonProgress> p) => pickContinue(catalog, LearningRules(catalog, p));
    const done = LessonProgress(partsDone: 8, completed: true);
    LessonProgress passed(Lesson l) =>
        LessonProgress(partsDone: l.partsCount, completed: true, passed: true, bestScore: 8);

    test('first time: Lesson 1', () {
      final p = pick({});
      expect((p.kind, p.lesson.id, p.partsDone), (ContinueKind.firstTime, 'b01', 0));
    });

    test('in progress: that lesson at the next part', () {
      final p = pick({'b01': done, 'b02': const LessonProgress(partsDone: 4)});
      expect((p.kind, p.lesson.id, p.nextPart, p.partsCount), (ContinueKind.inProgress, 'b02', 5, 12));
    });

    test('next lesson not started yet', () {
      final p = pick({'b01': done});
      expect((p.kind, p.lesson.id), (ContinueKind.notStarted, 'b02'));
    });

    test('quiz pending', () {
      final p = pick({'b01': done, 'b02': const LessonProgress(partsDone: 12, completed: true)});
      expect((p.kind, p.lesson.id), (ContinueKind.quizPending, 'b02'));
    });

    test('all done', () {
      final p = pick({for (final l in beginner()) l.id: passed(l)});
      expect(p.kind, ContinueKind.allDone);
    });
  });

  Future<LearningProgress> home(WidgetTester tester, Map<String, LessonProgress> lessons, {DateTime? now}) async {
    tester.view.physicalSize = const Size(375, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(catalog, ProgressSnapshot(lessons: {...lessons}, xp: 120, streak: 3));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: MaterialApp(
          theme: buildAppTheme(),
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          home: Scaffold(
            body: HomeTab(
              userName: 'Ana',
              photoUrl: null,
              onOpenLearn: () {},
              clock: () => now ?? DateTime(2026, 11, 6, 9),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return progress;
  }

  group('Home tab', () {
    testWidgets('first time: greeting, stats, Start Lesson 1 → Lesson 1 S02', (tester) async {
      await home(tester, {});
      expect(find.text('Maayong aga,\nAna.'), findsOneWidget);
      expect(find.text('DAY STREAK'), findsOneWidget);
      expect(find.text('LESSONS'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('Lesson 1: ${lesson('b01').title}'), findsOneWidget);
      expect(find.text('0 of 8 parts'), findsOneWidget);
      expect(find.text('Beginner · Level 1'), findsOneWidget);
      await tester.tap(find.text('Start Lesson 1'));
      await tester.pumpAndSettle();
      expect(tester.widget<LessonDetailScreen>(find.byType(LessonDetailScreen)).lessonId, 'b01');
      expect(tester.takeException(), isNull);
    });

    testWidgets('in progress: Part X of Y; Continue lesson opens the first unfinished part', (tester) async {
      await home(tester, {
        'b01': const LessonProgress(partsDone: 8, completed: true),
        'b02': const LessonProgress(partsDone: 4),
      });
      expect(find.text('1'), findsWidgets);
      expect(find.text('LESSON'), findsOneWidget);
      expect(find.text('Part 5 of 12'), findsOneWidget);
      await tester.tap(find.text('Continue lesson'));
      await tester.pumpAndSettle();
      final player = tester.widget<LessonPlayerScreen>(find.byType(LessonPlayerScreen));
      expect((player.lessonId, player.startPart), ('b02', 4));
    });

    testWidgets('all done: Beginner complete!', (tester) async {
      await home(tester, {
        for (final l in beginner())
          l.id: LessonProgress(partsDone: l.partsCount, completed: true, passed: true, bestScore: 8),
      });
      expect(find.text('Beginner complete!'), findsOneWidget);
      expect(find.text('Review lessons'), findsOneWidget);
    });

    testWidgets('greeting follows the time of day', (tester) async {
      await home(tester, {}, now: DateTime(2026, 11, 6, 15));
      expect(find.text('Maayong hapon,\nAna.'), findsOneWidget);
      await home(tester, {}, now: DateTime(2026, 11, 6, 20));
      expect(find.text('Maayong gab-i,\nAna.'), findsOneWidget);
    });
  });

  group('Phrase of the day', () {
    test('the same all day, a different one the next day', () {
      final morning = phraseOfTheDay(catalog, DateTime(2026, 11, 6, 0, 5))!;
      final night = phraseOfTheDay(catalog, DateTime(2026, 11, 6, 23, 55))!;
      final tomorrow = phraseOfTheDay(catalog, DateTime(2026, 11, 7, 0, 5))!;
      expect(night.id, morning.id);
      expect(tomorrow.id, isNot(morning.id));
      final items = {for (final l in catalog.allLessons) ...l.items.map((i) => i.id)};
      expect(items, contains(morning.id), reason: 'a lessons.json item');
    });

    testWidgets('the card shows Hiligaynon, Filipino and the example', (tester) async {
      final now = DateTime(2026, 11, 6, 9);
      final item = phraseOfTheDay(catalog, now)!;
      await home(tester, {}, now: now);
      expect(find.text('Phrase of the day'), findsOneWidget);
      expect(find.text(item.hil), findsOneWidget);
      expect(find.text(item.fil), findsOneWidget);
      expect(find.byTooltip('Listen'), findsOneWidget);
      if (item.example != null) expect(find.text(item.example!.fil), findsOneWidget);
    });
  });
}
