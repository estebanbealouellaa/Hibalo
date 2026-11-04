import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'models/catalog.dart';
import 'screens/learn_screen.dart';
import 'screens/lesson_detail_screen.dart';
import 'screens/lesson_player_screen.dart';
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

  /// The quiz player, from the first question.
  // TODO(step 4): open the quiz player.
  static void openQuiz(BuildContext context, Lesson lesson) {
    _notBuiltYet(context);
  }

  /// S03 Lesson complete (also where a "Quiz pending" row goes).
  // TODO(step 5): open S03.
  static void openLessonComplete(BuildContext context, Lesson lesson) {
    _notBuiltYet(context);
  }

  static void _notBuiltYet(BuildContext context) {
    showLearningSnackBar(
      context,
      AppLocalizations.of(context).comingNextStep,
      icon: Icons.construction_rounded,
    );
  }
}
