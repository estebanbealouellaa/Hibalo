import 'package:flutter/material.dart';

import 'logic/quiz_logic.dart';
import 'models/catalog.dart';
import 'screens/lesson_complete_screen.dart';
import 'screens/lesson_detail_screen.dart';
import 'screens/lesson_player_screen.dart';
import 'screens/quiz_player_screen.dart';
import 'screens/quiz_result_screen.dart';
import 'screens/quiz_review_screen.dart';
import 'state/learning_progress.dart';

/// Every way into and around the learning module, in one place, so the
/// screens don't need to know about each other.
abstract final class LearningRoutes {
  /// Route name of S01 when it is pushed as its own page (tests); in the
  /// app S01 is the Learn tab under the bottom bar.
  static const String learnRoute = '/learn';

  static VoidCallback? showLearnTab;

  /// S02 Lesson Detail.
  static Future<void> openLessonDetail(BuildContext context, Lesson lesson) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LessonDetailScreen(lessonId: lesson.id)),
    );
  }

  /// The lesson part player, opened at part [startPart] (0-based).
  /// [review] replays a finished lesson without paying XP again.
  static Future<void> openLessonPlayer(
    BuildContext context,
    Lesson lesson, {
    required int startPart,
    bool review = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonPlayerScreen(
          lessonId: lesson.id,
          startPart: startPart,
          review: review,
        ),
      ),
    );
  }

  /// The quiz player, from the first question (also "Retake the quiz").
  static Future<void> openQuiz(BuildContext context, Lesson lesson) => startQuiz(context, lesson);

  /// Starts the quiz from question 1 with a fresh score and a new shuffle.
  /// [replace] swaps it for the current screen (S03, S04, Try again).
  static Future<void> startQuiz(BuildContext context, Lesson lesson, {bool replace = false}) {
    final route = MaterialPageRoute<void>(builder: (_) => QuizPlayerScreen(lessonId: lesson.id));
    final navigator = Navigator.of(context);
    return replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  /// S03 Lesson complete; [xpJustPaid] shows "+20 XP", otherwise "Already earned".
  static Future<void> openLessonComplete(
    BuildContext context,
    Lesson lesson, {
    bool replace = false,
    bool xpJustPaid = false,
  }) {
    final route = MaterialPageRoute<void>(
      builder: (_) => LessonCompleteScreen(lessonId: lesson.id, xpJustPaid: xpJustPaid),
    );
    final navigator = Navigator.of(context);
    return replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  /// S04 Quiz result, in place of the quiz player.
  static void showQuizResult(
    BuildContext context,
    Lesson lesson,
    QuizAttemptResult result,
    List<AnsweredQuestion> answers,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(lessonId: lesson.id, result: result, answers: answers),
      ),
    );
  }

  /// S05 Quiz review over S04. Completes with true for "Try again".
  static Future<bool?> openQuizReview(
    BuildContext context,
    Lesson lesson,
    QuizAttemptResult result,
    List<AnsweredQuestion> answers,
  ) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizReviewScreen(result: result, answers: answers),
      ),
    );
  }

  /// Back to S01 ("Back to lessons", Continue, Leave): closes the lesson,
  /// quiz or result screens and shows the Learn tab.
  static void backToLearn(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == learnRoute || route.isFirst);
    showLearnTab?.call();
  }

  /// S03 Letters "Continue to Lesson 2": back to S01, then S02 of [lesson].
  static void openLessonDetailFromLearn(BuildContext context, Lesson lesson) {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.settings.name == learnRoute || route.isFirst);
    showLearnTab?.call();
    navigator.push(MaterialPageRoute(builder: (_) => LessonDetailScreen(lessonId: lesson.id)));
  }
}
