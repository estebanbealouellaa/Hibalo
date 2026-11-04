// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnSubtitle => 'Explore Hiligaynon through bite-sized lessons!';

  @override
  String get learnSearchHint => 'Search lessons...';

  @override
  String get learnLessonsHeading => 'Lessons';

  @override
  String learnLockedLevelsHint(String levels, String previous) {
    return '$levels: finish $previous to unlock';
  }

  @override
  String get listAnd => 'and';

  @override
  String learnLevelLocked(String previous, String level) {
    return 'Finish $previous to unlock $level';
  }

  @override
  String learnNoResultsTitle(String query) {
    return 'No lessons found for \'$query\'';
  }

  @override
  String get learnNoResultsHint =>
      'Try another word, like \'greetings\' or \'numbers\'.';

  @override
  String get learnComingSoon => 'Lessons coming soon';

  @override
  String get learnLoadError => 'The lessons couldn\'t be loaded.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get back => 'Back';

  @override
  String lessonMeta(int parts, int minutes) {
    return '$parts parts • $minutes min';
  }

  @override
  String rowQuizPending(int next) {
    return 'Take the quiz to unlock Lesson $next';
  }

  @override
  String rowQuizPendingLast(String level) {
    return 'Take the quiz to finish $level';
  }

  @override
  String rowLockedPassQuiz(int lesson) {
    return 'Pass Lesson $lesson quiz to unlock';
  }

  @override
  String rowLockedFinish(int lesson) {
    return 'Finish Lesson $lesson to unlock';
  }

  @override
  String get rowCompleted => 'Completed';

  @override
  String get rowLocked => 'Locked';

  @override
  String lessonNumber(int number) {
    return 'Lesson $number';
  }

  @override
  String get inThisLesson => 'In this lesson:';

  @override
  String get startLesson => 'Start lesson';

  @override
  String get continueLesson => 'Continue lesson';

  @override
  String get reviewLesson => 'Review lesson';

  @override
  String get retakeQuiz => 'Retake the quiz';

  @override
  String get lessonProgressTitle => 'Lesson progress';

  @override
  String partsProgress(int done, int total) {
    return '$done / $total parts';
  }

  @override
  String completedQuizChip(int score, int total) {
    return 'Completed · Quiz $score/$total';
  }

  @override
  String get completedChip => 'Completed';

  @override
  String get comingNextStep =>
      'The lesson player comes in the next build step.';
}
