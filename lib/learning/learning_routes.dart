import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'models/catalog.dart';
import 'screens/learn_screen.dart';
import 'screens/lesson_detail_screen.dart';
import 'screens/lesson_player_screen.dart';
import 'screens/quiz_done_screen.dart';
import 'screens/quiz_player_screen.dart';
import 'state/learning_progress.dart';
import 'widgets/learning_snack_bar.dart';

/// Every way into and around the learning module, in one place, so the
/// screens don't need to know about each other.
abstract final class LearningRoutes {
  /// Route name of S01, so Leave can go back to it.
  static const String learnRoute = '/learn';

  /// S01 Learn.
  static Future<void> openLearn(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: learnRoute),
        builder: (_) => const LearnScreen(),
      ),
    );
  }

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
  static Future<void> openQuiz(BuildContext context, Lesson lesson) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizPlayerScreen(lessonId: lesson.id)),
    );
  }

  /// S03 Lesson complete (also where a "Quiz pending" row goes).
  // TODO(step 5): open S03. Until then its "Take the lesson quiz" button is
  // stood in for: a lesson with a quiz goes straight to the quiz.
  static void openLessonComplete(BuildContext context, Lesson lesson, {bool replace = false}) {
    if (!lesson.hasQuiz) {
      showLearningSnackBar(
        context,
        AppLocalizations.of(context).lessonFinishedNote,
      );
      return;
    }
    final route = MaterialPageRoute<void>(builder: (_) => QuizPlayerScreen(lessonId: lesson.id));
    final navigator = Navigator.of(context);
    replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  /// TEMPORARY result after the last question, until S04 (step 5).
  static void showQuizDone(BuildContext context, Lesson lesson, QuizAttemptResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => QuizDoneScreen(result: result)),
    );
  }
}
