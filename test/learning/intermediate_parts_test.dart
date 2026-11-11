// Intermediate parts in the lesson player: P11 role-play, P12 verb forms, listening dialogues,
// term examples, key-idea tips and pattern sentences.
//   flutter test test/learning/intermediate_parts_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/parts.dart';
import 'package:hibalo_app/learning/screens/lesson_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/theme/v6_colors.dart';
import 'package:hibalo_app/learning/widgets/parts/dialogue_part.dart';
import 'package:hibalo_app/learning/widgets/parts/role_play_part.dart';
import 'package:hibalo_app/learning/widgets/parts/verb_forms_part.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  int partIndex(String lessonId, String partId) =>
      catalog.lessonById(lessonId)!.parts.indexWhere((p) => p.id == partId);

  /// Opens the player at [partId] on a small phone (360 × 760), like lesson_player_test.
  Future<void> open(WidgetTester tester, String lessonId, String partId) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(catalog, ProgressSnapshot());
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
      builder: (_) => LessonPlayerScreen(lessonId: lessonId, startPart: partIndex(lessonId, partId)),
    ));
    await tester.pumpAndSettle();
  }

  FilledButton nextButton(WidgetTester tester) => tester.widget<FilledButton>(
      find.ancestor(of: find.text('Next'), matching: find.byType(FilledButton)));

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  /// A right reply: green for a moment, then the next turn (or Done).
  Future<void> answerRight(WidgetTester tester, String text) async {
    await tapText(tester, text);
    await tester.pump(RolePlayPart.rightPause);
    await tester.pumpAndSettle();
  }

  group('P11 role-play (i01 At the Clinic)', () {
    testWidgets('choose, not quite, right choice, done', (tester) async {
      await open(tester, 'i01', 'i01_p13');
      expect(find.text('At the Clinic'), findsOneWidget);
      expect(find.text('You feel sick and visit the clinic.'), findsOneWidget);
      expect(find.text('Choose your reply.'), findsOneWidget);
      // The speaker's line with its Filipino; the replies with theirs.
      expect(find.text('Maayong aga! Ano ang ginabatyag mo?'), findsOneWidget);
      expect(find.text('Magandang umaga! Ano ang nararamdaman mo?'), findsOneWidget);
      expect(find.text('Masaya ako ngayon.'), findsOneWidget);
      expect(nextButton(tester).onPressed, isNull, reason: 'Next waits for the chat');

      // Wrong: red, the hint, try again (no reply bubble yet).
      await tapText(tester, 'Nalipay ako subong.');
      expect(find.text("Not quite: that means you're happy. Try another reply."), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsWidgets);
      expect(find.text('Halin san-o pa?'), findsNothing);

      // Right: Ana's bubble + the green card, then the next turn.
      await tapText(tester, 'Ginahilanat ako kag nagaubo.');
      expect(find.text('Ginahilanat ako kag nagaubo.'), findsNWidgets(2), reason: 'bubble and green card');
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.textContaining('Not quite'), findsNothing);
      await tester.pump(RolePlayPart.rightPause);
      await tester.pumpAndSettle();
      expect(find.text('Ginahilanat ako kag nagaubo.'), findsOneWidget, reason: 'only the bubble now');
      expect(find.text('Halin san-o pa?'), findsOneWidget);
      expect(find.text('Halin pa kahapon.'), findsOneWidget);
      expect(nextButton(tester).onPressed, isNull);

      await answerRight(tester, 'Halin pa kahapon.');
      await tapText(tester, 'Salamat gid!');
      // The closing line shows with the green card; Next still waits.
      expect(find.text('Wala sing anuman. Pahuway ka, ha?'), findsOneWidget);
      expect(nextButton(tester).onPressed, isNull);
      await tester.pump(RolePlayPart.rightPause);
      await tester.pumpAndSettle();

      // Done: whole chat, tip, no instruction, Next enabled.
      expect(find.text('Choose your reply.'), findsNothing);
      expect(find.textContaining('since yesterday', findRichText: true), findsOneWidget);
      expect(find.byType(ReplyOption), findsNothing);
      expect(nextButton(tester).onPressed, isNotNull);
      expect(find.text('Ana'), findsNWidgets(3), reason: 'three replies by Ana');
    });

    testWidgets('going back and forward keeps the finished chat', (tester) async {
      await open(tester, 'i01', 'i01_p13');
      await answerRight(tester, 'Ginahilanat ako kag nagaubo.');
      await answerRight(tester, 'Halin pa kahapon.');
      await answerRight(tester, 'Salamat gid!');
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('At the Clinic'), findsNothing);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('At the Clinic'), findsOneWidget);
      expect(find.text('Wala sing anuman. Pahuway ka, ha?'), findsOneWidget);
      expect(nextButton(tester).onPressed, isNotNull);
    });

    testWidgets('a role-play that ends on the learner\'s reply (i12) is done after it', (tester) async {
      await open(tester, 'i12', 'i12_p09');
      await answerRight(tester, 'Huo, bag-o lang ako. Ako si Ana.');
      await answerRight(tester, 'Taga-Batangas ako.');
      await answerRight(tester, 'Kay gusto ko makig-istorya kay Lola.');
      // The last turn offers one reply to tap.
      expect(find.byType(ReplyOption), findsOneWidget);
      await answerRight(tester, 'Salamat sa istorya. Hasta buwas!');
      expect(nextButton(tester).onPressed, isNotNull);
      expect(find.byType(ReplyOption), findsNothing);
    });

    testWidgets('cue above the choices and the talking-fast label (i12 Manong)', (tester) async {
      await open(tester, 'i12', 'i12_p10');
      expect(find.text('Talking fast'), findsOneWidget);
      await answerRight(tester, 'Hinay-hinay lang, palihog.');
      expect(find.text('You forgot the word "hospital".'), findsOneWidget);
    });

    testWidgets('no overflow in Filipino and Hiligaynon', (tester) async {
      for (final code in ['fil', 'hil']) {
        await open(tester, 'i01', 'i01_p13');
        await tester.binding.setLocale(code, '');
        await tester.pumpAndSettle();
        await tapText(tester, 'Nalipay ako subong.');
        expect(tester.takeException(), isNull, reason: code);
      }
    });
  });

  group('P12 verb forms', () {
    testWidgets('i03: one column of forms, chips switch the root', (tester) async {
      await open(tester, 'i03', 'i03_p04');
      expect(find.text('Tap a root word to see how its forms change.'), findsOneWidget);
      expect(find.text('When'), findsOneWidget);
      expect(find.text('Form'), findsOneWidget);
      expect(find.text('Who does it'), findsNothing);
      for (final label in ['Done', 'Ongoing / every day', 'Not yet']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('nagkaon', findRichText: true), findsOneWidget);
      expect(find.text('Nagkaon na ako.'), findsOneWidget);

      await tester.tap(find.text('inom').first);
      await tester.pumpAndSettle();
      expect(find.text('nag-inom', findRichText: true), findsOneWidget);
      expect(find.text('Naga-inom siya sang tubig.'), findsOneWidget);
      // The note is a tip card.
      expect(find.textContaining('kaunon', findRichText: true), findsOneWidget);
    });

    testWidgets('i04: Who does it and What it happens to', (tester) async {
      await open(tester, 'i04', 'i04_p07');
      expect(find.text('Who does it'), findsOneWidget);
      expect(find.text('What it happens to'), findsOneWidget);
      expect(find.text('nagluto', findRichText: true), findsOneWidget);
      expect(find.text('ginluto', findRichText: true), findsOneWidget);
      expect(find.text('lutuon', findRichText: true), findsOneWidget);
      await tester.tap(find.text('palit'));
      await tester.pumpAndSettle();
      expect(find.text('paliton', findRichText: true), findsOneWidget);
      expect(find.text('Ginpalit ko ang manok.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('the changing part is violet', () {
      List<(String, bool)> parts(String form, String root) {
        final span = verbFormSpan(form, root);
        return [
          for (final c in span.children ?? [span])
            ((c as TextSpan).text!, (c.style ?? span.style)?.color == V6Colors.primary),
        ];
      }

      expect(parts('nagkaon', 'kaon'), [('nag', true), ('kaon', false)]);
      expect(parts('nag-inom', 'inom'), [('nag-', true), ('inom', false)]);
      expect(parts('kaunon', 'kaon'), [('kaun', false), ('on', true)]);
      expect(parts('paliton', 'palit'), [('palit', false), ('on', true)]);
      expect(parts('magbasa', 'basa'), [('mag', true), ('basa', false)]);
    });
  });

  group('dialogue with clips', () {
    testWidgets('listening mode with clips: placeholders, Show text / Hide text, no switch (Figma)', (tester) async {
      // The Intermediate clips aren't recorded yet, so this uses two real Beginner clips.
      final part = DialoguePartData(
        'test_listening',
        title: 'Test',
        icon: 'chat_bubble',
        setting: 'Ana meets Manang Rosa.',
        lines: const [
          DialogueLine(speaker: 'Ana', hil: 'Maayong aga!', fil: 'Magandang umaga!',
              audio: 'assets/audio/b02/b02_maayong_aga.m4a', hasClip: true),
          DialogueLine(speaker: 'Manang Rosa', hil: 'Kamusta ka?', fil: 'Kumusta ka?',
              audio: 'assets/audio/b02/b02_kamusta_ka.m4a', hasClip: true),
        ],
        tip: null,
        listening: true,
      );
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        home: Scaffold(body: DialoguePart(data: part, avatars: catalog.settings.avatars)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Play conversation'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('Show text'), findsOneWidget);
      expect(find.text('Listen first, then check the text.'), findsOneWidget);
      expect(find.text('Maayong aga!'), findsNothing, reason: 'placeholders until played');
      expect(find.text('Ana'), findsOneWidget, reason: 'speaker names stay');
      expect(find.byType(Switch), findsNothing);

      await tester.tap(find.text('Show text'));
      await tester.pumpAndSettle();
      expect(find.text('Maayong aga!'), findsOneWidget);
      expect(find.text('Hide text'), findsOneWidget);
      expect(find.text('Tap a line to see the Filipino.'), findsOneWidget);
      await tester.tap(find.text('Maayong aga!'));
      await tester.pumpAndSettle();
      expect(find.text('Magandang umaga!'), findsOneWidget);

      await tester.tap(find.text('Hide text'));
      await tester.pumpAndSettle();
      expect(find.text('Maayong aga!'), findsNothing);
    });

    testWidgets('listening dialogue with no clips yet: text shown, Audio coming soon', (tester) async {
      final part = catalog.lessonById('i10')!.parts[partIndex('i10', 'i10_p05')] as DialoguePartData;
      expect(part.listening, isTrue);
      await open(tester, 'i10', 'i10_p05');
      expect(find.text('Audio coming soon'), findsOneWidget);
      expect(find.text('Play conversation'), findsNothing);
      expect(find.text('Show text'), findsNothing);
      expect(find.text(part.lines.first.hil), findsOneWidget);
    });

    testWidgets('"You" sits on the learner\'s side (i08)', (tester) async {
      await open(tester, 'i08', 'i08_p01');
      final you = tester.getTopRight(find.text('You').first).dx;
      final server = tester.getTopLeft(find.text('Server').first).dx;
      expect(you, greaterThan(250), reason: 'right side (name ends by the avatar)');
      expect(server, lessThan(100), reason: 'left side');
    });
  });

  group('key idea and pattern', () {
    testWidgets('term examples inside the term card (Filipino may be missing)', (tester) async {
      await open(tester, 'i05', 'i05_p09');
      expect(find.text('Basi indi siya mag-abot.'), findsOneWidget);
      expect(find.text('Baka hindi siya dumating.'), findsOneWidget);
      await open(tester, 'i03', 'i03_p07');
      expect(find.text('Nagkaon na ako.'), findsOneWidget);
      expect(find.text('Example'), findsWidgets);
    });

    testWidgets('a key idea tip shows as a tip card', (tester) async {
      await open(tester, 'i04', 'i04_p10');
      expect(find.textContaining('strong habit', findRichText: true), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_rounded), findsNWidgets(2), reason: 'header icon + tip bulb');
    });

    testWidgets('pattern sentence under the slots, above the meaning', (tester) async {
      await open(tester, 'i01', 'i01_p04');
      final sentence = find.text('Nalipay ako.', findRichText: true);
      expect(sentence, findsOneWidget);
      expect(tester.getTopLeft(sentence).dy, lessThan(tester.getTopLeft(find.text('= Natuwa ako.')).dy));
    });
  });
}
