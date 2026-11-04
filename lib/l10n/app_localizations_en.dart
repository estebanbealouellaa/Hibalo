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

  @override
  String partCaption(int lesson, int part, int total) {
    return 'Lesson $lesson · Part $part of $total';
  }

  @override
  String xpChip(int xp) {
    return '$xp XP';
  }

  @override
  String get leaveLessonTooltip => 'Leave the lesson';

  @override
  String get nextButton => 'Next';

  @override
  String get finishAndPractice => 'Finish & practice';

  @override
  String get finishLesson => 'Finish lesson';

  @override
  String get leaveLessonTitle => 'Leave this lesson?';

  @override
  String get leaveLessonText => 'You\'ll restart this part next time.';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get leave => 'Leave';

  @override
  String get newWordChip => 'New word';

  @override
  String get hiligaynonLabel => 'Hiligaynon';

  @override
  String alsoSaid(String alt) {
    return 'Also said: $alt';
  }

  @override
  String get playAudio => 'Play';

  @override
  String get playSlow => 'Play slowly';

  @override
  String get exampleLabel => 'Example';

  @override
  String get noteLabel => 'NOTE';

  @override
  String get filipinoLabel => 'FILIPINO';

  @override
  String lettersSeen(int seen, int total) {
    return '$seen / $total seen';
  }

  @override
  String get lettersHint =>
      'Swipe through the letters. Say each example word out loud.';

  @override
  String get calledLabel => 'CALLED';

  @override
  String letterPosition(int position, int total) {
    return '$position / $total';
  }

  @override
  String get quickCheckChip => 'Quick check · practice';

  @override
  String get quickCheckNote => 'No timer, no score. Just practice.';

  @override
  String get feedbackCorrect => 'Correct!';

  @override
  String get feedbackWrong => 'Not quite';

  @override
  String get correctAnswerLabel => 'Correct answer:';

  @override
  String xpGain(int xp) {
    return '+$xp XP';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get showAllFilipino => 'Show all Filipino';

  @override
  String get dialogueHint =>
      'Read each line aloud, then tap it to check the Filipino.';

  @override
  String get readingHint =>
      'Read each sentence aloud, then tap it to check the Filipino.';

  @override
  String get tapToSeeFilipino => 'Tap to see Filipino';

  @override
  String get tapToHideFilipino => 'Tap to hide Filipino';

  @override
  String get commonMistakes => 'Common mistakes';

  @override
  String get moreExamples => 'More examples';

  @override
  String get cultureNoteLabel => 'Culture note';

  @override
  String get lessonFinishedNote =>
      'Lesson finished! The Lesson complete screen comes in step 5.';
}
