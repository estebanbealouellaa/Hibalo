import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/questions.dart';
import '../services/lesson_audio.dart';
import '../services/pronunciation/clip_decoder.dart';
import '../services/pronunciation/similarity.dart';
import '../services/voice_recorder.dart';
import '../state/learning_progress.dart';

/// Debug builds only (from the Learn bug menu): records the Beginner Q09 phrases and shows
/// the similarity numbers for tuning the thresholds. English on purpose. Recordings stay
/// in memory (one at a time) and are cleared when the screen closes; only the numbers are
/// listed, printed to the log ("[PronTune]") and can be copied as CSV.
class PronunciationTuningScreen extends StatefulWidget {
  const PronunciationTuningScreen({super.key, this.comparer, this.recorder});

  /// For tests; the real MediaCodec decoder / mic recorder when null.
  final PronunciationComparer? comparer;
  final InMemoryVoiceRecorder? recorder;

  @override
  State<PronunciationTuningScreen> createState() => _PronunciationTuningScreenState();
}

class _Phrase {
  const _Phrase(this.lessonTitle, this.data);

  final String lessonTitle;
  final SpeakingData data;
}

class _Row {
  _Row(this.speaker, this.said, this.phrase, this.c);

  final String speaker;
  final String said;
  final String phrase;
  final PronunciationComparison c;

  static const csvHeader = 'speaker,take,phrase,heard,speech_ms,peak_db,distance,relative,rank,of,decode_ms,compute_ms';

  String get csv => [
        speaker,
        said,
        '"$phrase"',
        c.heard,
        c.speech.speechMs,
        c.speech.peakDb.toStringAsFixed(1),
        c.distance?.toStringAsFixed(3) ?? '',
        c.relative?.toStringAsFixed(3) ?? '',
        c.rank ?? '',
        c.compared,
        c.decodeMs,
        c.computeMs,
      ].join(',');
}

const _saidOptions = ['good', 'sloppy', 'wrong word'];

class _PronunciationTuningScreenState extends State<PronunciationTuningScreen> {
  late final PronunciationComparer _comparer;
  late final InMemoryVoiceRecorder _recorder = widget.recorder ?? InMemoryVoiceRecorder();
  final _speaker = TextEditingController(text: 'S1');
  String _said = _saidOptions.first;
  late final List<_Phrase> _phrases;
  late final List<String> _clips;
  final List<_Row> _rows = [];
  final Map<String, PronunciationComparison> _last = {};
  String? _recordingId;
  String? _busyId;

  /// The phrase whose recording is in memory ("You" plays it).
  String? _heldId;
  String? _selfTest;
  bool _selfTesting = false;

  @override
  void initState() {
    super.initState();
    final catalog = context.read<LearningProgress>().catalog;
    final settings = catalog.settings.pronunciation;
    _comparer = widget.comparer ??
        PronunciationComparer(check: SpeechCheck(minSpeechMs: settings.minSpeechMs, minLevelDb: settings.minLevelDb));
    _phrases = [
      for (final level in catalog.levels)
        if (level.id == 'beginner')
          for (final lesson in level.lessons)
            for (final q in lesson.quiz?.questions ?? const <QuizQuestion>[])
              if (q is SpeakingData && q.audio != null) _Phrase(lesson.title, q),
    ];
    _clips = beginnerSpeakingClips(catalog);
  }

  @override
  void dispose() {
    _speaker.dispose();
    _recorder.dispose(); // also clears the recording
    super.dispose();
  }

  Future<void> _tapRecord(_Phrase p) async {
    if (_busyId != null || _selfTesting) return;
    if (_recordingId == p.data.id) {
      await _recorder.stop();
      setState(() {
        _recordingId = null;
        _busyId = p.data.id;
      });
      await _compare(p);
      return;
    }
    if (_recordingId != null) return;
    await LessonAudio.instance.stop();
    if (await _recorder.start()) {
      setState(() => _recordingId = p.data.id);
    } else {
      _snack('Mic not available');
    }
  }

  Future<void> _compare(_Phrase p) async {
    try {
      final bytes = _recorder.recordingBytes ?? Uint8List(0);
      final learner = toMono16k(RawPcm(samples: int16FromBytes(bytes), sampleRate: 16000, channels: 1));
      final c = await _comparer.compare(learner: learner, target: p.data.audio!, others: _clips);
      final row = _Row(_speaker.text.trim().isEmpty ? '?' : _speaker.text.trim(), _said, p.data.text, c);
      debugPrint('[PronTune] ${row.csv}');
      if (!mounted) return;
      setState(() {
        _rows.add(row);
        _last[p.data.id] = c;
        _heldId = p.data.id;
      });
    } catch (e) {
      debugPrint('[PronTune] compare failed: $e');
      _snack('Could not compare: $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  /// Times the comparison without the mic: each native clip is used as the "recording".
  /// Round 1 includes decoding every clip; round 2 uses the cached features.
  Future<void> _runSelfTest() async {
    if (_busyId != null || _recordingId != null || _selfTesting) return;
    setState(() {
      _selfTesting = true;
      _selfTest = 'Running…';
    });
    final lines = <String>[];
    try {
      final decoder = _comparer.decoder;
      for (var round = 1; round <= 2; round++) {
        var decode = 0, compute = 0, worst = 0, rankOne = 0;
        final total = Stopwatch()..start();
        for (final clip in _clips) {
          final watch = Stopwatch()..start();
          final learner = toMono16k(await decoder.decode(clip));
          final prep = watch.elapsedMilliseconds;
          final c = await _comparer.compare(learner: learner, target: clip, others: _clips);
          decode += c.decodeMs;
          compute += c.computeMs;
          final one = prep + c.decodeMs + c.computeMs;
          if (one > worst) worst = one;
          if (c.rank == 1) rankOne++;
          debugPrint('[PronTune] self-test round $round $clip prep=${prep}ms decode=${c.decodeMs}ms '
              'compute=${c.computeMs}ms distance=${c.distance?.toStringAsFixed(3)} rank=${c.rank}/${c.compared}');
        }
        final line = 'Round $round (${_clips.length} clips): total ${total.elapsedMilliseconds} ms · '
            'decode $decode ms · compute avg ${compute ~/ _clips.length} ms · slowest one $worst ms · '
            'self = closest $rankOne/${_clips.length}';
        debugPrint('[PronTune] $line');
        lines.add(line);
      }
    } catch (e) {
      lines.add('Failed: $e');
      debugPrint('[PronTune] self-test failed: $e');
    }
    if (!mounted) return;
    setState(() {
      _selfTesting = false;
      _selfTest = lines.join('\n');
    });
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _copy() async {
    final text = [_Row.csvHeader, for (final r in _rows) r.csv].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    _snack('Copied ${_rows.length} rows');
  }

  String _readout(PronunciationComparison c) {
    final s = c.speech;
    final heard = 'speech ${s.speechMs} ms · peak ${s.peakDb.toStringAsFixed(1)} dB';
    if (!c.heard) return "Couldn't hear ($heard)";
    return 'Distance ${c.distance!.toStringAsFixed(3)} · relative ${c.relative?.toStringAsFixed(3) ?? '–'} '
        '(rank ${c.rank ?? '–'} of ${c.compared})\n$heard · decode ${c.decodeMs} ms · compute ${c.computeMs} ms';
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink(); // never in a release build
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEBUG · Pronunciation tuning'),
        actions: [
          IconButton(
            tooltip: 'Clear results',
            onPressed: _rows.isEmpty ? null : () => setState(() {
              _rows.clear();
              _last.clear();
            }),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _speaker,
                  decoration: const InputDecoration(labelText: 'Speaker', isDense: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: [
                    for (final option in _saidOptions)
                      ChoiceChip(
                        label: Text(option),
                        selected: _said == option,
                        onSelected: (_) => setState(() => _said = option),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${_rows.length} results this session (numbers only; no audio is kept).'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _selfTesting ? null : _runSelfTest,
            child: const Text('Speed test on the native clips (no mic)'),
          ),
          if (_selfTest != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_selfTest!)),
          const Divider(height: 24),
          for (final p in _phrases) _phraseCard(p),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: Text('All results (${_rows.length})', style: const TextStyle(fontWeight: FontWeight.w700))),
              FilledButton.tonalIcon(
                onPressed: _rows.isEmpty ? null : _copy,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy all results'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final r in _rows.reversed) _resultLine(r),
        ],
      ),
    );
  }

  /// One line per recording: speaker, phrase, take, distance, relative score, rank.
  Widget _resultLine(_Row r) {
    final c = r.c;
    final scores = c.heard
        ? 'distance ${c.distance!.toStringAsFixed(3)} · relative ${c.relative?.toStringAsFixed(3) ?? '–'} · rank ${c.rank ?? '–'}/${c.compared}'
        : "Couldn't hear (${c.speech.speechMs} ms, ${c.speech.peakDb.toStringAsFixed(1)} dB)";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('${r.speaker} · ${r.phrase} · ${r.said}\n$scores'),
    );
  }

  Widget _phraseCard(_Phrase p) {
    final recording = _recordingId == p.data.id;
    final busy = _busyId == p.data.id;
    final last = _last[p.data.id];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.data.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('${p.data.meaning} · ${p.lessonTitle}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => LessonAudio.instance.play(p.data.audio),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Native'),
                ),
                FilledButton.icon(
                  onPressed: busy || (_recordingId != null && !recording) ? null : () => _tapRecord(p),
                  icon: Icon(recording ? Icons.stop_rounded : Icons.mic_rounded),
                  label: Text(recording ? 'Stop' : busy ? 'Checking…' : 'Record'),
                ),
                if (_heldId == p.data.id && _recordingId == null)
                  TextButton(onPressed: _recorder.play, child: const Text('You')),
              ],
            ),
            if (last != null) Text(_readout(last)),
          ],
        ),
      ),
    );
  }
}
