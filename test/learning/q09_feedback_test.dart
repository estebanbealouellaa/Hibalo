// Q09 pronunciation feedback (Stage 2): Checking → Very close / Almost / Try again,
// Couldn't hear, Record again, No clip, and the flag switched off.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/services/pronunciation/clip_decoder.dart';
import 'package:hibalo_app/learning/services/pronunciation/similarity.dart';
import 'package:hibalo_app/learning/services/voice_recorder.dart';
import 'package:hibalo_app/learning/widgets/quiz/practice_questions.dart';
import 'package:hibalo_app/learning/widgets/quiz/question_contract.dart';

import 'pronunciation_fixtures.dart';

/// Records [next] (made-up PCM) instead of using the mic; nothing is stored.
class _Recorder implements VoiceRecorder {
  Float64List next = Float64List(0);
  Uint8List? _kept;
  bool recording = false;
  int starts = 0;
  int plays = 0;

  @override
  Future<bool> start() async {
    starts++;
    recording = true;
    return true;
  }

  @override
  Future<void> stop() async {
    if (recording) _kept = pcmBytes(next);
    recording = false;
  }

  @override
  bool get hasRecording => _kept != null && _kept!.isNotEmpty;

  @override
  Uint8List? get recordingBytes => _kept;

  @override
  Future<void> play() async => plays++;

  @override
  Future<void> clear() async => _kept = null;

  @override
  Future<void> dispose() async {}
}

/// Holds every decode until [open] is called (to see the Checking state).
class _GatedDecoder implements ClipDecoder {
  _GatedDecoder(this.inner);

  final ClipDecoder inner;
  final Completer<void> _gate = Completer<void>();

  void open() => _gate.complete();

  @override
  Future<RawPcm> decode(String assetPath) async {
    await _gate.future;
    return inner.decode(assetPath);
  }
}

const _on = PronunciationSettings(enabled: true, veryClose: 0.82, almost: 0.95, minSpeechMs: 250, minLevelDb: -40);

Map<String, Float64List> _clips() => {'a': wordA(), 'b': wordB(), 'c': wordC()};

SpeakingData _question({String? audio = 'a'}) =>
    SpeakingData('q9', prompt: 'Listen, then say it', text: 'Kamusta ka?', meaning: 'Kumusta ka?', audio: audio);

void main() {
  late _Recorder recorder;
  late AnswerState answer;
  var recordLabel = 'Record';
  var stopLabel = 'Stop recording';

  Future<void> pump(
    WidgetTester tester, {
    SpeakingData? data,
    PronunciationSettings feedback = _on,
    ClipDecoder? decoder,
    String? lang,
  }) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    recorder = _Recorder();
    answer = const AnswerState(ready: false);
    (recordLabel, stopLabel) = switch (lang) {
      'fil' => ('I-record', 'Itigil ang pag-record'),
      'hil' => ('I-record', 'Untati ang pag-record'),
      _ => ('Record', 'Stop recording'),
    };
    final comparer = PronunciationComparer(decoder: decoder ?? FakeClipDecoder(_clips()), useIsolate: false);
    await tester.pumpWidget(MaterialApp(
      locale: lang == null ? null : Locale(lang),
      localizationsDelegates: AppLanguage.delegates,
      supportedLocales: AppLanguage.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SpeakingQuestion(
            key: UniqueKey(), // a fresh question on every pump
            data: data ?? _question(),
            recorder: recorder,
            onChanged: (a) => answer = a,
            feedback: feedback,
            comparer: comparer,
            otherClips: const ['a', 'b', 'c'],
          ),
        ),
      ),
    ));    await tester.pumpAndSettle(); // the fil/hil strings load asynchronously
  }

  Future<void> record(WidgetTester tester, Float64List sound) async {
    recorder.next = sound;
    await tester.tap(find.bySemanticsLabel(recordLabel));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(stopLabel));
    await tester.pumpAndSettle();
  }

  testWidgets('saying the native phrase: Very close, Play mine / Play native, Record again', (tester) async {
    await pump(tester);
    await record(tester, wordA());
    expect(find.text('Very close'), findsOneWidget);
    expect(find.text('You sound very close to the native speaker.'), findsOneWidget);
    expect(find.text('Play mine'), findsOneWidget);
    expect(find.text('Play native'), findsOneWidget);
    expect(find.text('Record again'), findsOneWidget);
    expect(find.bySemanticsLabel('Record'), findsNothing, reason: 'the mic is replaced by Record again');
    expect(answer.ready, isTrue);

    await tester.tap(find.text('Play mine'));
    expect(recorder.plays, 1);
  });

  testWidgets('a different word: Try again', (tester) async {
    await pump(tester);
    await record(tester, wordB());
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Listen to the native speaker, then try again.'), findsOneWidget);
  });

  testWidgets('Almost between the two thresholds', (tester) async {
    // Saying the clip itself scores 0; thresholds below 0 and above it put it in Almost.
    await pump(tester, feedback: const PronunciationSettings(
        enabled: true, veryClose: -1, almost: 10, minSpeechMs: 250, minLevelDb: -40));
    await record(tester, wordA());
    expect(find.text('Almost'), findsOneWidget);
    expect(find.text('Almost there. Listen again and try once more.'), findsOneWidget);
  });

  testWidgets('silence: We couldn\'t hear you + Record again, Continue still allowed', (tester) async {
    await pump(tester);
    await record(tester, silence(1.5));
    expect(find.text("We couldn't hear you"), findsOneWidget);
    expect(find.text('Hold the phone closer and try again.'), findsOneWidget);
    expect(find.text('Record again'), findsOneWidget);
    expect(find.text('Play mine'), findsNothing, reason: 'no compare row in Couldn\'t hear');
    expect(answer.ready, isTrue);
  });

  testWidgets('Checking: spinner button, Continue disabled until the result', (tester) async {
    final gated = _GatedDecoder(FakeClipDecoder(_clips()));
    await pump(tester, decoder: gated);
    recorder.next = wordA();
    await tester.tap(find.bySemanticsLabel('Record'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Stop recording'));
    await tester.pump();
    expect(find.text('Checking…'), findsOneWidget);
    expect(answer.ready, isFalse, reason: 'Continue is disabled during Checking');

    gated.open();
    await tester.pumpAndSettle();
    expect(find.text('Checking…'), findsNothing);
    expect(find.text('Very close'), findsOneWidget);
    expect(answer.ready, isTrue);
  });

  testWidgets('Record again starts a new recording that replaces the old one', (tester) async {
    await pump(tester);
    await record(tester, wordB());
    expect(find.text('Try again'), findsOneWidget);

    recorder.next = wordA();
    await tester.tap(find.text('Record again'));
    await tester.pump();
    expect(recorder.starts, 2);
    expect(answer.ready, isFalse, reason: 'recording');
    await tester.tap(find.bySemanticsLabel('Stop recording'));
    await tester.pumpAndSettle();
    expect(find.text('Very close'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('no native clip: No clip state, no Checking, Comparison coming soon', (tester) async {
    await pump(tester, data: _question(audio: null));
    expect(find.text('Audio coming soon'), findsOneWidget);
    expect(find.text('Comparison coming soon'), findsOneWidget);
    expect(find.text('Play mine'), findsOneWidget);
    expect(find.text('Play native'), findsNothing);
    expect(find.text('Recorded · tap to record again'), findsNothing);

    await record(tester, wordA());
    expect(find.text('Checking…'), findsNothing);
    expect(find.text('Very close'), findsNothing);
    expect(find.text('Recorded · tap to record again'), findsOneWidget);
    expect(answer.ready, isTrue);
  });

  testWidgets('flag off: Q09 works as before (no check, no result)', (tester) async {
    await pump(tester, feedback: PronunciationSettings.off);
    await record(tester, wordA());
    expect(find.text('Checking…'), findsNothing);
    expect(find.text('Very close'), findsNothing);
    expect(find.text('Native speaker'), findsWidgets);
    expect(find.text('You'), findsOneWidget);
    expect(answer.ready, isTrue);
  });

  testWidgets('a clip that can\'t be decoded: no feedback, Q09 still works', (tester) async {
    await pump(tester, decoder: FakeClipDecoder({}));
    await record(tester, wordA());
    expect(find.text('Very close'), findsNothing);
    expect(find.text("We couldn't hear you"), findsNothing);
    expect(answer.ready, isTrue);
  });

  for (final lang in ['fil', 'hil']) {
    testWidgets("$lang at 360 dp: result, Couldn't hear and No clip fit", (tester) async {
      await pump(tester, lang: lang);
      await record(tester, wordB()); // Try again
      expect(tester.takeException(), isNull);
      await pump(tester, lang: lang);
      await record(tester, silence(1.2)); // Couldn't hear
      expect(tester.takeException(), isNull);
      await pump(tester, lang: lang, data: _question(audio: null));
      await record(tester, wordA()); // No clip
      expect(tester.takeException(), isNull);
    });
  }
}
