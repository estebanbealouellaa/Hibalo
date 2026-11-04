import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../models/catalog.dart';
import '../models/parts.dart';
import '../services/lesson_audio.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';
import '../widgets/feedback_sheet.dart';
import '../widgets/leave_dialog.dart';
import '../widgets/learning_snack_bar.dart';
import '../widgets/parts/bridge_mistakes_part.dart';
import '../widgets/parts/culture_note_part.dart';
import '../widgets/parts/dialogue_part.dart';
import '../widgets/parts/key_idea_part.dart';
import '../widgets/parts/letters_part.dart';
import '../widgets/parts/pattern_part.dart';
import '../widgets/parts/quick_check_part.dart';
import '../widgets/parts/reading_part.dart';
import '../widgets/parts/table_part.dart';
import '../widgets/parts/words_part.dart';
import '../widgets/segmented_progress.dart';

/// The lesson part player: shows a lesson's parts in order, each with the
/// widget for its template (P01–P10).
///
/// - Top: X (→ Leave pop-up), the segmented bar, the lesson's XP so far.
/// - Under it: "Lesson N · Part X of Y" on every part.
/// - Bottom: Back + Next. A step is a card (P04), a letter (P05) or a part;
///   Back goes one step back and is disabled only on the very first step
///   (§1.2). On the last part Next reads "Finish & practice" or
///   "Finish lesson" (§1.7).
/// - Each finished part is saved when Next leaves it. Leaving drops only the
///   part in progress.
class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    this.startPart = 0,
    this.review = false,
  });

  final String lessonId;

  /// Part to open first (0-based): 0 to start or review, the first
  /// unfinished part to continue.
  final int startPart;

  /// Replaying a finished lesson: nothing new is paid.
  final bool review;

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late final Lesson _lesson;
  late int _part;
  int _step = 0;
  bool _busy = false;

  /// Letters seen in each P05 part (part id → letter indexes).
  final Map<String, Set<int>> _seen = {};

  /// Quick check answers (part id → chosen option), kept while the lesson
  /// is open so going back shows the answer instead of a second try.
  final Map<String, int> _answers = {};

  /// Shuffled option order per quick check, made once per visit.
  final Map<String, List<int>> _orders = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    final progress = context.read<LearningProgress>();
    _lesson = progress.catalog.lessonById(widget.lessonId)!;
    _part = widget.startPart.clamp(0, _lesson.partsCount - 1);
    _enterStep();
  }

  @override
  void dispose() {
    LessonAudio.instance.stop();
    super.dispose();
  }

  LessonPart get _current => _lesson.parts[_part];
  bool get _isFirstStep => _part == 0 && _step == 0;
  bool get _isLastPart => _part == _lesson.partsCount - 1;
  bool get _isLastStep => _step >= _current.stepCount - 1;

  /// Next is disabled on a quick check until it is answered.
  bool get _canGoNext {
    final part = _current;
    return !_busy && (part is! QuickCheckPartData || _answers.containsKey(part.id));
  }

  /// Bookkeeping when a step is shown: letters count as seen.
  void _enterStep() {
    final part = _current;
    if (part is LettersPartData) (_seen[part.id] ??= {}).add(_step);
  }

  // ── Back / Next ─────────────────────────────────────────────────────────

  Future<void> _next() async {
    if (!_canGoNext) return;
    if (!_isLastStep) {
      setState(() {
        _step++;
        _enterStep();
      });
      return;
    }
    // Leaving the part: it is finished, so save it.
    setState(() => _busy = true);
    final progress = context.read<LearningProgress>();
    await progress.savePartDone(_lesson, _part);
    if (!mounted) return;
    if (_isLastPart) {
      await _finishLesson(progress);
      return;
    }
    LessonAudio.instance.stop();
    setState(() {
      _busy = false;
      _part++;
      _step = 0;
      _enterStep();
    });
  }

  void _back() {
    if (_isFirstStep || _busy) return;
    LessonAudio.instance.stop();
    setState(() {
      if (_step > 0) {
        _step--;
      } else {
        // First card or letter: back to the previous part, at its last step.
        _part--;
        _step = _current.stepCount - 1;
      }
      _enterStep();
    });
  }

  /// P05: a swipe or a chip tap jumps straight to that letter.
  void _jumpToLetter(int index) {
    setState(() {
      _step = index;
      _enterStep();
    });
  }

  Future<void> _finishLesson(LearningProgress progress) async {
    // Paid once: a review pays nothing again.
    await progress.payLessonComplete(_lesson);
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final note = AppLocalizations.of(context).lessonFinishedNote;
    // TODO(step 5): open S03 Lesson complete instead of going back to S02.
    navigator.pop();
    showLearningSnackBar(navigator.context, note);
  }

  // ── Leaving ─────────────────────────────────────────────────────────────

  Future<void> _confirmLeave() async {
    final leave = await showLeaveLessonDialog(context);
    if (!leave || !mounted) return;
    // Finished parts are already saved; the part in progress is dropped.
    Navigator.of(context).popUntil(
      (route) => route.settings.name == LearningRoutes.learnRoute || route.isFirst,
    );
  }

  /// Android back = the on-screen Back; on the very first step it asks to
  /// leave instead.
  void _onSystemBack() => _isFirstStep ? _confirmLeave() : _back();

  // ── Quick check ─────────────────────────────────────────────────────────

  List<int> _orderFor(QuickCheckPartData part) {
    return _orders.putIfAbsent(part.id, () {
      final order = List.generate(part.options.length, (i) => i);
      final settings = context.read<LearningProgress>().catalog.settings;
      if (settings.shuffleOptions) order.shuffle(_random);
      return order;
    });
  }

  Future<void> _answerQuickCheck(QuickCheckPartData part, int chosen) async {
    if (_answers.containsKey(part.id)) return; // one try only
    setState(() => _answers[part.id] = chosen);
    final progress = context.read<LearningProgress>();
    final right = chosen == part.answer;
    int? paid;
    if (right) {
      final xp = progress.catalog.settings.xp.quickCheck;
      final first = await progress.payXpOnce(LearningProgress.quickCheckPaidId(part.id), xp);
      if (first) paid = xp;
    }
    if (!mounted) return;
    await showFeedbackSheet(
      context,
      type: right ? FeedbackType.correct : FeedbackType.wrong,
      xp: paid,
      answer: right ? null : part.options[part.answer],
      detail: part.explain,
    );
    // Continue on the sheet goes to the next part.
    if (mounted && _current == part) await _next();
  }

  // ── Building ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgress>();
    final t = AppLocalizations.of(context);
    final nextLabel = !(_isLastPart && _isLastStep)
        ? t.nextButton
        : _lesson.hasQuiz
            ? t.finishAndPractice
            : t.finishLesson;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onSystemBack();
      },
      child: LearningTheme(
        child: Scaffold(
          backgroundColor: V6Colors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(t, progress.lessonXp(_lesson)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    t.partCaption(_lesson.order, _part + 1, _lesson.partsCount),
                    style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
                  ),
                ),
                Expanded(
                  // A new key per part, so each part starts fresh.
                  child: KeyedSubtree(
                    key: ValueKey(_current.id),
                    child: _partWidget(progress),
                  ),
                ),
                _bottomButtons(t, nextLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _partWidget(LearningProgress progress) {
    final settings = progress.catalog.settings;
    return switch (_current) {
      KeyIdeaPartData p => KeyIdeaPart(data: p),
      TablePartData p => TablePart(data: p),
      PatternPartData p => PatternPart(data: p),
      WordsPartData p => WordsPart(data: p, index: _step, fallbackPicture: settings.missingPicture),
      LettersPartData p => LettersPart(
          data: p,
          index: _step,
          seen: _seen[p.id] ?? const {},
          onIndexChanged: _jumpToLetter,
        ),
      QuickCheckPartData p => QuickCheckPart(
          data: p,
          order: _orderFor(p),
          chosen: _answers[p.id],
          onChoose: (i) => _answerQuickCheck(p, i),
        ),
      DialoguePartData p => DialoguePart(data: p, avatars: settings.avatars),
      ReadingPartData p => ReadingPart(data: p),
      BridgeMistakesPartData p => BridgeMistakesPart(data: p),
      CultureNotePartData p => CultureNotePart(data: p, fallbackPicture: settings.missingPicture),
    };
  }

  Widget _topBar(AppLocalizations t, int xp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _confirmLeave,
            tooltip: t.leaveLessonTooltip,
            icon: const Icon(Icons.close_rounded, color: V6Colors.textPrimary),
          ),
          const SizedBox(width: 4),
          Expanded(child: SegmentedProgress(count: _lesson.partsCount, current: _part)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: const ShapeDecoration(color: V6Colors.citrus, shape: StadiumBorder()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: V6Colors.onCitrus),
                const SizedBox(width: 2),
                Text(t.xpChip(xp), style: V6Text.labelXp.copyWith(color: V6Colors.onCitrus)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons(AppLocalizations t, String nextLabel) {
    final backEnabled = !_isFirstStep && !_busy;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // Disabled = 38% opacity, not tappable (§1.2).
          Opacity(
            opacity: backEnabled ? 1 : 0.38,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Material(
                color: V6Colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: V6Colors.borderDivider),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: backEnabled ? _back : null,
                  child: Tooltip(
                    message: t.back,
                    child: const Icon(Icons.arrow_back_rounded, color: V6Colors.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _canGoNext ? _next : null,
                style: FilledButton.styleFrom(
                  backgroundColor: V6Colors.primary,
                  foregroundColor: V6Colors.onPrimary,
                  disabledBackgroundColor: V6Colors.stateDisabled,
                  disabledForegroundColor: V6Colors.textDisabled,
                  textStyle: V6Text.button,
                  shape: const StadiumBorder(),
                ),
                child: Text(nextLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
