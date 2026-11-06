// Stage C: the Translate pieces (input, result with skeleton / Listen /
// Copied), the Voice pop-up, and the photo scan inside Translate.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/providers/translator_provider.dart';
import 'package:hibalo_app/screens/translate/scan_pieces.dart';
import 'package:hibalo_app/screens/translate/voice_popup.dart';
import 'package:hibalo_app/screens/translator_screen.dart';
import 'package:hibalo_app/services/translation/scan_translator.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6.dart';
import 'package:hibalo_app/widgets/v6/v6_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 900); // Galaxy A03 width
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLanguage.delegates,
      supportedLocales: AppLanguage.supportedLocales,
      theme: buildAppTheme(),
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(20), children: [child]),
      ),
    ),
  );
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

    testWidgets('clear button: only with text, and it clears', (tester) async {
      var clears = 0;
      Widget card(bool filled) => TranslationInputCard(
        language: 'Filipino',
        textArea: const Text('Magandang umaga'),
        characters: filled ? 15 : 0,
        filled: filled,
        onSpeak: () {},
        onScan: () {},
        onTranslate: () {},
        onClear: () => clears++,
      );
      await _pump(tester, card(false));
      expect(find.byTooltip('Clear text'), findsNothing);
      await _pump(tester, card(true));
      await tester.tap(find.byTooltip('Clear text'));
      expect(clears, 1);
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

  group('Voice pop-up', () {
    test("states: ready, speaking, Didn't catch that, mic off", () {
      expect(voiceViewFor(micOff: false, listening: false, error: ''), VoiceView.ready);
      expect(voiceViewFor(micOff: false, listening: true, error: ''), VoiceView.speaking);
      expect(voiceViewFor(micOff: false, listening: false, error: 'No speech detected. Try again.'), VoiceView.error);
      expect(voiceViewFor(micOff: true, listening: false, error: ''), VoiceView.micOff);
      expect(voiceViewFor(micOff: false, listening: false, error: 'Microphone permission required.'), VoiceView.micOff);
    });

    testWidgets('opens over Translate: Ready, then Cancel closes it', (tester) async {
      final provider = _fakeProvider(tester);
      final outcome = await _openPopup(tester, provider);
      expect(find.text('Hold the mic and speak'), findsOneWidget);
      expect(find.text('Tap to start'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Hold the mic and speak'), findsNothing);
      expect(outcome.done, isTrue);
      expect(outcome.value, isNull);
    });

    testWidgets('mic refused: Microphone access is off, Type instead', (tester) async {
      final provider = _fakeProvider(tester);
      final outcome = await _openPopup(tester, provider, mic: PermissionStatus.permanentlyDenied);
      await tester.tap(find.bySemanticsLabel('Start listening'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Microphone access is off'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
      await tester.tap(find.text('Type instead'));
      await tester.pumpAndSettle();
      expect(outcome.value, VoiceOutcome.typeInstead);
    });

    testWidgets('closes by itself when speech gives text', (tester) async {
      final provider = _fakeProvider(tester);
      final outcome = await _openPopup(tester, provider);
      provider.fakeSpeechResult();
      await tester.pumpAndSettle();
      expect(find.text('Hold the mic and speak'), findsNothing);
      expect(outcome.value, VoiceOutcome.spoke);
    });
  });

  group('Camera inside Translate', () {
    testWidgets('scan options sheet returns the picked source', (tester) async {
      ImageSource? picked;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async => picked = await showScanOptions(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Scan text from a photo'), findsOneWidget);
      expect(find.text('Use your camera'), findsOneWidget);
      expect(find.text('Pick a photo you already have'), findsOneWidget);
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(picked, ImageSource.gallery);
    });

    testWidgets('no Common phrases; No text found shows above the input', (tester) async {
      final provider = _fakeProvider(tester);
      final screen = await _pumpTranslate(tester, provider, read: (_) async => const PhotoText('  ', []));
      expect(find.text('Common phrases'), findsNothing);
      unawaited(screen.scanPhoto(File('x.jpg')));
      await tester.pump();
      await tester.pump();
      expect(find.text('No text found'), findsOneWidget);
      expect(find.text('Type or paste text here'), findsOneWidget, reason: 'the empty input stays below');
      expect(find.text('Take a photo'), findsOneWidget);
    });

    testWidgets("Couldn't read the photo when reading fails", (tester) async {
      final provider = _fakeProvider(tester);
      final screen = await _pumpTranslate(tester, provider, read: (_) async => throw Exception('ocr'));
      unawaited(screen.scanPhoto(File('x.jpg')));
      await tester.pump();
      await tester.pump();
      expect(find.text("Couldn't read the photo"), findsOneWidget);
      expect(find.text('Choose another'), findsOneWidget);
    });

    testWidgets('scanning card, then the text with From your photo', (tester) async {
      final provider = _fakeProvider(tester);
      final reading = Completer<PhotoText>();
      final screen = await _pumpTranslate(tester, provider, read: (_) => reading.future);
      unawaited(screen.scanPhoto(File('x.jpg')));
      await tester.pump();
      expect(find.text('Reading the text…'), findsOneWidget);
      expect(find.text('Type or paste text here'), findsNothing, reason: 'the scanning card replaces the input');
      reading.complete(const PhotoText('Maayong aga', ['Maayong aga']));
      await tester.pump();
      await tester.pump();
      expect(provider.scanned?.text, 'Maayong aga', reason: 'the scan pipeline translates it');
      expect(find.text('From your photo · check for mistakes'), findsOneWidget);
      expect(find.text('Scan again'), findsOneWidget);
    });

    testWidgets('back while scanning cancels the scan', (tester) async {
      final provider = _fakeProvider(tester);
      final reading = Completer<PhotoText>();
      final screen = await _pumpTranslate(tester, provider, read: (_) => reading.future);
      unawaited(screen.scanPhoto(File('x.jpg')));
      await tester.pump();
      expect(TranslatorScreen.handleBack?.call(), isTrue);
      await tester.pump();
      expect(find.text('Reading the text…'), findsNothing);
      reading.complete(const PhotoText('Maayong aga', ['Maayong aga']));
      await tester.pump();
      expect(provider.scanned, isNull, reason: 'a cancelled scan is ignored');
      expect(TranslatorScreen.handleBack?.call(), isFalse);
    });

    testWidgets('message cards: actions', (tester) async {
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
      await tester.tap(find.text('Take a photo'));
      await tester.tap(find.text('Choose from gallery'));
      expect(taps, 2);
    });

    testWidgets('Camera access is off: three choices', (tester) async {
      String? picked;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
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
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Open settings'), findsOneWidget);
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(picked, 'Choose from gallery');
    });
  });
}

/// TranslatorProvider without speech, translation or Firebase.
class _FakeTranslator extends TranslatorProvider {
  int _results = 0;
  PhotoText? scanned;

  @override
  int get speechResults => _results;

  void fakeSpeechResult() {
    _results++;
    notifyListeners();
  }

  @override
  Future<void> showScan(PhotoText scan) async => scanned = scan;

  @override
  Future<void> updateOriginalText(String text) async {}
}

const _speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

_FakeTranslator _fakeProvider(WidgetTester tester) {
  SharedPreferences.setMockInitialValues({});
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(_speechChannel, (call) async => call.method == 'initialize' ? false : null);
  addTearDown(() => messenger.setMockMethodCallHandler(_speechChannel, null));
  return _FakeTranslator();
}

class _Outcome {
  VoiceOutcome? value;
  bool done = false;
}

Future<_Outcome> _openPopup(WidgetTester tester, _FakeTranslator provider, {PermissionStatus? mic}) async {
  final outcome = _Outcome();
  await tester.pumpWidget(
    ChangeNotifierProvider<TranslatorProvider>.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  outcome.value = await showVoicePopup(context, micPermission: mic == null ? null : () async => mic);
                  outcome.done = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return outcome;
}

Future<TranslatorScreenState> _pumpTranslate(
  WidgetTester tester,
  _FakeTranslator provider, {
  required Future<PhotoText> Function(File) read,
}) async {
  tester.view.physicalSize = const Size(360, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<TranslatorProvider>.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        theme: buildAppTheme(),
        home: TranslatorScreen(readPhoto: read),
      ),
    ),
  );
  await tester.pump();
  return tester.state<TranslatorScreenState>(find.byType(TranslatorScreen));
}
