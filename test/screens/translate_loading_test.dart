// Translate while the offline models are still loading: "Preparing translator…" from app
// start until they're ready; typing works, and Translate shows "Preparing…" and then the result.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/providers/translator_provider.dart';
import 'package:hibalo_app/screens/translator_screen.dart';
import 'package:hibalo_app/services/translation/offline_translator.dart';
import 'package:hibalo_app/services/translation_store.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Translation waits for the models, like the real one: it finishes once [status] is ready.
class _LoadingTranslator extends TranslatorProvider {
  _LoadingTranslator(TranslatorLoad start) : status = ValueNotifier(start);

  final ValueNotifier<TranslatorLoad> status;

  @override
  ValueListenable<TranslatorLoad> get modelStatus => status;

  @override
  Future<(String, bool)> runTranslation(
    String text,
    String sourceLanguage,
    void Function(String textSoFar) onPartial,
  ) async {
    if (status.value != TranslatorLoad.ready) {
      final ready = Completer<void>();
      void listener() {
        if (status.value == TranslatorLoad.ready && !ready.isCompleted) ready.complete();
      }

      status.addListener(listener);
      await ready.future;
      status.removeListener(listener);
    }
    return ('HIL($text)', false);
  }
}

const _speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

void main() {
  Future<_LoadingTranslator> pump(WidgetTester tester, TranslatorLoad start) async {
    SharedPreferences.setMockInitialValues({});
    TranslationStore.instance.resetForTest();
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_speechChannel, (call) async => call.method == 'initialize' ? false : null);
    addTearDown(() => messenger.setMockMethodCallHandler(_speechChannel, null));
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final provider = _LoadingTranslator(start);
    await tester.pumpWidget(
      ChangeNotifierProvider<TranslatorProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          theme: buildAppTheme(),
          home: const TranslatorScreen(),
        ),
      ),
    );
    await tester.pump();
    return provider;
  }

  testWidgets('while loading: the banner shows, typing works, Translate says Preparing… then translates', (tester) async {
    final p = await pump(tester, TranslatorLoad.loading);
    expect(find.text('Preparing translator…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'the banner has a spinner');

    await tester.enterText(find.byType(TextField), 'Magandang umaga po');
    await tester.pump();
    expect(find.text('Magandang umaga po'), findsOneWidget, reason: 'typing is not blocked');

    await tester.tap(find.widgetWithText(FilledButton, 'Translate'));
    await tester.pump();
    expect(find.text('Preparing…'), findsOneWidget, reason: 'the button says why it waits');
    expect(find.text('Translating…'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

    p.status.value = TranslatorLoad.ready;
    await tester.pumpAndSettle();
    expect(find.text('Preparing translator…'), findsNothing);
    expect(find.text('Preparing…'), findsNothing);
    expect(find.text('HIL(Magandang umaga po)'), findsOneWidget);
  });

  testWidgets('ready: no banner, the button says Translating…', (tester) async {
    await pump(tester, TranslatorLoad.ready);
    expect(find.text('Preparing translator…'), findsNothing);
  });

  testWidgets('failed to load: no endless banner (the translation falls back as before)', (tester) async {
    await pump(tester, TranslatorLoad.failed);
    expect(find.text('Preparing translator…'), findsNothing);
  });
}
