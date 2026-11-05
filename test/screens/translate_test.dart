// Stage C: the Translate pieces (input, result with skeleton / Listen /
// Copied), the Voice states, the Camera scan sheet and message cards.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/screens/camera_translate_screen.dart';
import 'package:hibalo_app/screens/voice_translate_screen.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6.dart';
import 'package:hibalo_app/widgets/v6/v6_translate.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 900); // Galaxy A03 width
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: ListView(padding: const EdgeInsets.all(20), children: [child])),
  ));
}

void main() {
  group('Translate', () {
    testWidgets('language card: from / to and the swap button', (tester) async {
      var swaps = 0;
      await _pump(tester, LanguageSwitchCard(from: 'Filipino', to: 'Hiligaynon', onSwap: () => swaps++));
      expect(find.text('Filipino'), findsOneWidget);
      expect(find.text('Hiligaynon'), findsOneWidget);
      await tester.tap(find.byTooltip('Swap languages'));
      expect(swaps, 1);
    });

    testWidgets('empty input: Translate disabled; Speak and Scan always there', (tester) async {
      var speak = 0, scan = 0;
      await _pump(
        tester,
        TranslationInputCard(
          language: 'Filipino',
          textArea: const Text('Type or paste text here'),
          characters: 0,
          filled: false,
          onSpeak: () => speak++,
          onScan: () => scan++,
          onTranslate: null,
        ),
      );
      expect(find.text('0 characters'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Translate')).onPressed, isNull);
      await tester.tap(find.byTooltip('Speak'));
      await tester.tap(find.byTooltip('Scan text from a photo'));
      expect((speak, scan), (1, 1));
    });

    testWidgets('translating: the button says Translating…', (tester) async {
      await _pump(
        tester,
        TranslationInputCard(
          language: 'Filipino',
          textArea: const Text('Magandang umaga'),
          characters: 15,
          filled: true,
          translating: true,
          onSpeak: () {},
          onScan: () {},
          onTranslate: () {},
        ),
      );
      expect(find.text('Translating…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('translating: two skeleton lines, Listen and Copy wait', (tester) async {
      await _pump(
        tester,
        TranslationResultCard(language: 'Hiligaynon', text: '', translating: true, onListen: () {}, onCopy: () {}),
      );
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Translating'), findsOneWidget);
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.volume_up_rounded)).onPressed, isNull);
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.content_copy_rounded)).onPressed, isNull);
    });

    testWidgets('result: the text, Listen and Copy; Copied shows a check', (tester) async {
      var listens = 0, copies = 0;
      await _pump(
        tester,
        TranslationResultCard(
          language: 'Hiligaynon',
          text: 'Maayong aga',
          translating: false,
          note: 'Maaaring hindi eksakto ang salin.',
          onListen: () => listens++,
          onCopy: () => copies++,
        ),
      );
      expect(find.text('Maayong aga'), findsOneWidget);
      expect(find.text('Maaaring hindi eksakto ang salin.'), findsOneWidget);
      await tester.tap(find.byTooltip('Listen'));
      await tester.tap(find.byTooltip('Copy'));
      expect((listens, copies), (1, 1));
      expect(find.byIcon(Icons.ios_share_rounded), findsNothing, reason: 'Share is hidden for now');
      expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing, reason: 'Save is hidden for now');

      await _pump(
        tester,
        TranslationResultCard(
          language: 'Hiligaynon',
          text: 'Maayong aga',
          translating: false,
          copied: true,
          onListen: () {},
          onCopy: () {},
        ),
      );
      expect(find.byTooltip('Copied'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('Listen shows preparing and stop states', (tester) async {
      await _pump(
        tester,
        TranslationResultCard(
          language: 'Hiligaynon',
          text: 'Maayong aga',
          translating: false,
          listen: ListenState.speaking,
          onListen: () {},
          onCopy: () {},
        ),
      );
      expect(find.byTooltip('Stop'), findsOneWidget);
    });
  });

  group('Voice states', () {
    VoiceView view({bool micOff = false, bool listening = false, String error = '', bool spoke = false, bool text = false}) =>
        voiceViewFor(micOff: micOff, listening: listening, error: error, spoke: spoke, hasText: text);

    test('ready, then speaking', () {
      expect(view(), VoiceView.ready);
      expect(view(listening: true, spoke: true), VoiceView.speaking);
    });
    test('result after speaking on this screen', () {
      expect(view(spoke: true, text: true), VoiceView.result);
      expect(view(spoke: false, text: true), VoiceView.ready, reason: 'an older translation is not a voice result');
    });
    test('speech error: Didn\'t catch that', () {
      expect(view(spoke: true, error: 'No speech detected. Try again.'), VoiceView.error);
    });
    test('microphone refused: Microphone access is off', () {
      expect(view(micOff: true), VoiceView.micOff);
      expect(view(spoke: true, error: 'Microphone permission required.'), VoiceView.micOff);
    });
  });

  group('Camera', () {
    testWidgets('scan options sheet: Take a photo, Choose from gallery, Cancel', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(child: TextButton(onPressed: () => showScanOptions(context), child: const Text('open'))),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Scan text from a photo'), findsOneWidget);
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Use your camera'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
      expect(find.text('Pick a photo you already have'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Scan text from a photo'), findsNothing);
    });

    testWidgets('message cards: No text found and Couldn\'t read, with their actions', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        V6MessageCard(
          icon: Icons.document_scanner_rounded,
          background: V6Colors.glowContainerSoft,
          title: 'No text found',
          message: 'Try a clearer photo with good light, and keep the words straight and close.',
          actions: [
            V6Button(label: 'Take a photo', style: V6ButtonStyle.secondary, onPressed: () => taps++),
            V6Button(label: 'Choose from gallery', style: V6ButtonStyle.text, onPressed: () => taps++),
          ],
        ),
      );
      expect(find.text('No text found'), findsOneWidget);
      await tester.tap(find.text('Take a photo'));
      await tester.tap(find.text('Choose from gallery'));
      expect(taps, 2);
    });

    testWidgets('Camera access is off: three choices', (tester) async {
      String? picked;
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => picked = await showV6ChoiceDialog(
                  context,
                  title: 'Camera access is off',
                  primaryLabel: 'Open settings',
                  textActions: const ['Choose from gallery', 'Not now'],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Open settings'), findsOneWidget);
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(picked, 'Choose from gallery');
    });
  });
}
