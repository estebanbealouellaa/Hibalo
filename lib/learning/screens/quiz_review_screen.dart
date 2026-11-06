import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../logic/quiz_logic.dart';
import '../models/questions.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';
import '../widgets/result_parts.dart';

/// S05 Quiz review: every question in quiz order with its real number.
class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({super.key, required this.result, required this.answers});

  final QuizAttemptResult result;
  final List<AnsweredQuestion> answers;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LearningTheme(
      child: Scaffold(
        backgroundColor: V6Colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Figma "Top app bar": 64 high, Back 48, title.
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        tooltip: t.back,
                        icon: const Icon(Icons.arrow_back_rounded, color: V6Colors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        t.reviewAnswers,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: V6Text.appBarTitle.copyWith(color: V6Colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.quizScoreLine(result.correct, result.total),
                        style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: _ReviewList(answers: answers)),
                      const SizedBox(height: 10),
                      if (result.passed)
                        ResultPrimaryButton(
                          label: t.continueButton,
                          onPressed: () => LearningRoutes.backToLearn(context),
                        )
                      else
                        ResultPrimaryButton(label: t.tryAgain, onPressed: () => Navigator.of(context).pop(true)),
                      const SizedBox(height: 10),
                      Center(
                        child: ResultTextButton(
                          label: t.backToLessons,
                          onPressed: () => LearningRoutes.backToLearn(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The scrolling list with a 64 px fade into the background at the bottom.
class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.answers});

  final List<AnsweredQuestion> answers;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.only(bottom: 48),
          itemCount: answers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => ReviewRow(number: i + 1, answered: answers[i]),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 64,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [V6Colors.background.withValues(alpha: 0), V6Colors.background],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One "Review" row: mark, "N. question", and the answer lines.
class ReviewRow extends StatelessWidget {
  const ReviewRow({super.key, required this.number, required this.answered});

  final int number;
  final AnsweredQuestion answered;

  /// "What does…?", "Listening: What does the speaker say?", "Type: …".
  static String titleOf(AppLocalizations t, QuizQuestion q) {
    String typed(String type, String text) => t.reviewTyped(type, text);
    return switch (q) {
      MultipleChoiceData q => q.prompt,
      ListeningData q => typed(t.rvListening, q.prompt),
      FillBlankData q => typed(t.rvFillBlank, q.sentence),
      TypeAnswerData q => typed(t.rvType, q.text),
      BuildSentenceData q => typed(t.rvBuild, q.prompt),
      RealSituationData q => typed(t.rvRealSituation, q.situation),
      MatchPairsData() => t.rvMatchPairs,
      DictationData q => typed(t.rvDictation, q.accepted.first),
      SpeakingData q => typed(t.rvSpeaking, q.text),
      OpenAnswerData q => typed(t.rvOpenAnswer, q.prompt),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final q = answered.question;
    final outcome = answered.outcome;
    final practice = outcome == QuestionOutcome.practice;
    final right = outcome == QuestionOutcome.right;

    final (markBackground, markIcon, markColor, iconSize) = practice
        ? (
            V6Colors.lagoonContainer,
            q is SpeakingData ? Icons.mic_rounded : Icons.edit_note_rounded,
            V6Colors.lagoonText,
            16.0,
          )
        : right
        ? (V6Colors.successContainer, Icons.check_circle_rounded, V6Colors.success, 18.0)
        : (V6Colors.errorContainer, Icons.close_rounded, V6Colors.error, 18.0);

    final pairs = q is MatchPairsData ? q.pairs.length : 0;
    final given = outcome == QuestionOutcome.timeout
        ? t.timeUpAnswer
        : q is MatchPairsData
        ? t.pairsScore(answered.pairsRight ?? 0, pairs)
        : answered.answer ?? '';
    final correct = q is MatchPairsData ? t.pairsScore(pairs, pairs) : correctAnswerText(q);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: markBackground, shape: BoxShape.circle),
            child: Icon(markIcon, size: iconSize, color: markColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.reviewQuestion(number, titleOf(t, q)),
                        style: V6Text.labelLargeBold.copyWith(color: V6Colors.textPrimary),
                      ),
                    ),
                    if (practice) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: const ShapeDecoration(color: V6Colors.lagoonContainer, shape: StadiumBorder()),
                        child: Text(t.practiceTag, style: V6Text.labelMediumBold.copyWith(color: V6Colors.lagoonText)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                if (practice)
                  Text(t.practiceNote, style: V6Text.caption.copyWith(color: V6Colors.textMuted))
                else ...[
                  Text(
                    t.yourAnswerIs(given),
                    style: V6Text.captionSemiBold.copyWith(color: right ? V6Colors.success : V6Colors.error),
                  ),
                  if (!right && correct != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      t.correctAnswerIs(correct),
                      style: V6Text.captionSemiBold.copyWith(color: V6Colors.textSecondary),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
