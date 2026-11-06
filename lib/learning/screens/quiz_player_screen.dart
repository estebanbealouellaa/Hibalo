import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../logic/quiz_logic.dart';
import '../logic/quiz_timer.dart';
import '../models/catalog.dart';
import '../models/questions.dart';
import '../services/lesson_audio.dart';
import '../services/voice_recorder.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';
import '../widgets/feedback_sheet.dart';
import '../widgets/leave_dialog.dart';
import '../widgets/quiz/choice_questions.dart';
import '../widgets/quiz/practice_questions.dart';
import '../widgets/quiz/question_contract.dart';
import '../widgets/quiz/quiz_common.dart';
import '../widgets/quiz/tile_questions.dart';
import '../widgets/quiz/typed_questions.dart';

/// Quiz player (Q01–Q10), then the result; no Back, Android back opens Leave quiz.
class QuizPlayerScreen extends StatefulWidget {
  const QuizPlayerScreen({
    super.key,
    required this.lessonId,
    this.random,
    this.recorder,
  });

  final String lessonId;

  /// Shuffles options, tiles and the match column. Seeded in tests.
  final Random? random;

  /// Q09 recorder; the real in-memory one when null.
  final VoiceRecorder? recorder;

  /// Makes the shuffle for each new attempt when [random] is null, so every
  /// start (and Try again) gets a new order. Swapped in tests.
  @visibleForTesting
  static Random Function() newRandom = Random.new;

  @override
  State<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends State<QuizPlayerScreen> {
  late final Lesson _lesson;
  late final List<QuizQuestion> _questions;
  late final VoiceRecorder _recorder = widget.recorder ?? InMemoryVoiceRecorder();

  /// Display order per question: options (Q01/Q02/Q03/Q06), bank tiles
  /// (Q05) or the right column (Q07). Made once, when the quiz starts.
  final Map<String, List<int>> _orders = {};
  final Map<String, QuestionOutcome> _outcomes = {};

  final Map<String, AnswerState> _given = {};

  int _index = 0;
  QuestionPhase _phase = QuestionPhase.answering;
  AnswerState _answer = AnswerState.empty;
  QuizTimer? _timer;
  bool _busy = false;

  QuizQuestion get _question => _questions[_index];
  LearningSettings get _settings => context.read<LearningProgress>().catalog.settings;

  @override
  void initState() {
    super.initState();
    final progress = context.read<LearningProgress>();
    _lesson = progress.catalog.lessonById(widget.lessonId)!;
    _questions = _lesson.quiz!.questions;
    _makeOrders(progress.catalog.settings, widget.random ?? QuizPlayerScreen.newRandom());
    _startQuestion();
  }

  /// Shuffled at runtime (§1.8): `answer` stays the JSON index, and the
  /// widgets find where it landed through these orders.
  void _makeOrders(LearningSettings s, Random random) {
    for (final q in _questions) {
      _orders[q.id] = switch (q) {
        ChoiceQuestion c => shuffledOrder(c.options.length, random, shuffle: s.shuffleOptions),
        BuildSentenceData b => tileOrder(b, random, shuffle: s.shuffleBuildTiles),
        MatchPairsData m => shuffledOrder(m.pairs.length, random, shuffle: s.shuffleMatchRightColumn),
        _ => const [],
      };
    }
  }

  @override
  void dispose() {
    _timer?.dispose();
    LessonAudio.instance.stop();
    // Q09 recordings never outlive the quiz.
    _recorder.dispose();
    super.dispose();
  }

  void _startQuestion() {
    _timer?.dispose();
    _timer = null;
    _phase = QuestionPhase.answering;
    _answer = AnswerState.empty;
    if (_settings.timedTypes.contains(_question.type)) {
      _timer = QuizTimer(seconds: _settings.timerSeconds, onTimeout: _onTimeout)
        ..addListener(_onTick)
        ..start();
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _onAnswer(AnswerState state) {
    if (_phase != QuestionPhase.answering) return;
    if (state != _answer) setState(() => _answer = state);
  }

  bool get _canPress => !_busy && _phase == QuestionPhase.answering && _answer.ready;

  Future<void> _onPrimary() async {
    if (!_canPress) return;
    final q = _question;
    FocusScope.of(context).unfocus();
    LessonAudio.instance.stop();
    _timer?.stop();
    _given[q.id] = _answer;
    setState(() => _busy = true);

    switch (q) {
      case SpeakingData():
        // Continue goes straight on, with no sheet.
        _outcomes[q.id] = QuestionOutcome.practice;
      case OpenAnswerData():
        _outcomes[q.id] = QuestionOutcome.practice;
        setState(() => _phase = QuestionPhase.checked);
        await _sheet(type: FeedbackType.info, answer: q.modelAnswer);
      default:
        final right = _answer.correct;
        _outcomes[q.id] = right ? QuestionOutcome.right : QuestionOutcome.wrong;
        setState(() => _phase = QuestionPhase.checked);
        if (right) {
          final paidBefore = context.read<LearningProgress>().isPaid(
                LearningProgress.questionPaidId(_lesson.id, q.id),
              );
          await _sheet(type: FeedbackType.correct, xp: paidBefore ? null : _settings.xp.perCorrect);
        } else {
          await _wrongSheet(q, FeedbackType.wrong);
        }
    }
    await _next();
  }

  /// The timer reached 0: the input locks and F03 opens; it counts as wrong.
  Future<void> _onTimeout() async {
    if (!mounted || _phase != QuestionPhase.answering) return;
    final q = _question;
    FocusScope.of(context).unfocus();
    LessonAudio.instance.stop();
    _outcomes[q.id] = QuestionOutcome.timeout;
    setState(() {
      _phase = QuestionPhase.timedOut;
      _busy = true;
    });
    // A Leave pop-up may be open: the sheet waits until it's closed.
    await _wrongSheet(q, FeedbackType.timeout);
    await _next();
  }

  Future<void> _wrongSheet(QuizQuestion q, FeedbackType type) {
    return _sheet(
      type: type,
      answer: correctAnswerText(q),
      answerAudio: q.answerAudio,
      pairs: q is MatchPairsData ? [for (final p in q.pairs) (p.hil, p.fil)] : null,
    );
  }

  Future<void> _sheet({
    required FeedbackType type,
    int? xp,
    String? answer,
    String? answerAudio,
    List<(String, String)>? pairs,
  }) async {
    if (!mounted) return;
    _timer?.pause();
    try {
      await showFeedbackSheet(
        context,
        type: type,
        xp: xp,
        answer: answer,
        answerAudio: answerAudio,
        pairs: pairs,
      );
    } finally {
      _timer?.resume();
    }
  }

  Future<void> _next() async {
    if (!mounted) return;
    LessonAudio.instance.stop();
    if (_index == _questions.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _index++;
      _busy = false;
      _startQuestion();
    });
  }

  /// The attempt ends: save it (and sync it), delete any recording, show
  /// S04 with the answers for S05.
  Future<void> _finish() async {
    final progress = context.read<LearningProgress>();
    final score = QuizScore.of(_questions, _outcomes);
    final rightIds = [
      for (final q in _questions)
        if (q.scored && _outcomes[q.id] == QuestionOutcome.right) q.id,
    ];
    final result = await progress.saveQuizResult(
      _lesson,
      correct: score.correct,
      total: score.total,
      rightIds: rightIds,
    );
    await _recorder.clear();
    if (!mounted) return;
    final answers = [
      for (final q in _questions)
        AnsweredQuestion(
          question: q,
          outcome: _outcomes[q.id] ?? QuestionOutcome.wrong,
          answer: _given[q.id]?.text,
          pairsRight: _given[q.id]?.pairsRight,
        ),
    ];
    LearningRoutes.showQuizResult(context, _lesson, result, answers);
  }

  /// S06 Leave quiz. The timer pauses while it is open; Keep going keeps
  /// the exact state. Leave drops the attempt: no score, no XP.
  Future<void> _confirmLeave() async {
    _timer?.pause();
    final leave = await showLeaveQuizDialog(context);
    _timer?.resume();
    if (!leave || !mounted) return;
    _timer?.stop();
    await _recorder.clear();
    if (!mounted) return;
    LearningRoutes.backToLearn(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final q = _question;
    final label = switch (q) {
      SpeakingData() => t.continueButton,
      OpenAnswerData() => t.submitButton,
      _ => t.checkButton,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: LearningTheme(
        child: Scaffold(
          backgroundColor: V6Colors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(t),
                Expanded(
                  child: SingleChildScrollView(
                    // Figma "Body": padding 12 / 20, 12 between blocks.
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _metaRow(q),
                        const SizedBox(height: 12),
                        // A new key per question, so each starts fresh.
                        KeyedSubtree(key: ValueKey(q.id), child: _questionWidget(q)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _canPress ? _onPrimary : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: V6Colors.primary,
                        foregroundColor: V6Colors.onPrimary,
                        disabledBackgroundColor: V6Colors.stateDisabled,
                        disabledForegroundColor: V6Colors.textDisabled,
                        textStyle: V6Text.button,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(label),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _questionWidget(QuizQuestion q) {
    final order = _orders[q.id]!;
    return switch (q) {
      MultipleChoiceData d =>
        MultipleChoiceQuestion(data: d, order: order, phase: _phase, onChanged: _onAnswer),
      ListeningData d => ListeningQuestion(data: d, order: order, phase: _phase, onChanged: _onAnswer),
      FillBlankData d => FillBlankQuestion(data: d, order: order, phase: _phase, onChanged: _onAnswer),
      TypeAnswerData d => TypeAnswerQuestion(data: d, phase: _phase, onChanged: _onAnswer),
      BuildSentenceData d =>
        BuildSentenceQuestion(data: d, order: order, phase: _phase, onChanged: _onAnswer),
      RealSituationData d => RealSituationQuestion(
          data: d,
          order: order,
          phase: _phase,
          onChanged: _onAnswer,
          fallbackPicture: _settings.missingPicture,
        ),
      MatchPairsData d =>
        MatchPairsQuestion(data: d, rightOrder: order, phase: _phase, onChanged: _onAnswer),
      DictationData d => DictationQuestion(data: d, phase: _phase, onChanged: _onAnswer),
      SpeakingData d => SpeakingQuestion(data: d, recorder: _recorder, onChanged: _onAnswer),
      OpenAnswerData d => OpenAnswerQuestion(data: d, phase: _phase, onChanged: _onAnswer),
    };
  }

  Widget _metaRow(QuizQuestion q) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: QuestionTypeChip(question: q)),
        if (q.scored) ...[
          const SizedBox(width: 8),
          QuizXpChip(xp: _settings.xp.perCorrect),
        ],
      ],
    );
  }

  /// Figma "Quiz Top Bar": 56 high, X, progress, step, optional timer.
  Widget _topBar(AppLocalizations t) {
    final timer = _timer;
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 8, right: 20),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: _confirmLeave,
              tooltip: t.leaveQuizTooltip,
              icon: const Icon(Icons.close_rounded, color: V6Colors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _ProgressBar(value: (_index + 1) / _questions.length)),
          const SizedBox(width: 12),
          Text(
            '${_index + 1} / ${_questions.length}',
            style: V6Text.labelLargeBold.copyWith(color: V6Colors.primary),
          ),
          if (timer != null) ...[
            const SizedBox(width: 12),
            Semantics(
              label: t.timeLeft(timer.secondsLeft),
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const ShapeDecoration(color: V6Colors.glowTonal, shape: StadiumBorder()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 16, color: V6Colors.glowText),
                    const SizedBox(width: 4),
                    Text(timer.label, style: V6Text.labelMediumBold.copyWith(color: V6Colors.glowText)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The smooth 8 px bar: Primary on Primary Container, animated per step.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(V6Spacing.radiusFull),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 8,
          backgroundColor: V6Colors.primaryContainer,
          color: V6Colors.primary,
        ),
      ),
    );
  }
}
