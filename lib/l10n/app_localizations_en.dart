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
  String get qtChoose => 'Choose';

  @override
  String get qtListening => 'Listening';

  @override
  String get qtFillBlank => 'Fill in the blank';

  @override
  String get qtTypeAnswer => 'Type the answer';

  @override
  String get qtBuildSentence => 'Build the sentence';

  @override
  String get qtRealSituation => 'Real situation';

  @override
  String get qtMatchPairs => 'Match pairs';

  @override
  String get qtDictation => 'Dictation';

  @override
  String get qtSpeaking => 'Speaking';

  @override
  String get qtOpenAnswer => 'Open answer';

  @override
  String get checkButton => 'Check';

  @override
  String get submitButton => 'Submit';

  @override
  String get q01Hint => 'Choose the correct answer.';

  @override
  String get q02Hint => 'Listen, then choose the answer.';

  @override
  String get q03Title => 'Complete the sentence:';

  @override
  String get q03Hint => 'Choose the missing word.';

  @override
  String get q04TitleToHil => 'Type this in Hiligaynon';

  @override
  String get q04TitleToFil => 'Type this in Filipino';

  @override
  String get q04HintToHil => 'Write the Hiligaynon word or phrase.';

  @override
  String get q04HintToFil => 'Write the Filipino word or phrase.';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get q05Title => 'Build the sentence';

  @override
  String get q05Hint => 'Tap the words in the right order.';

  @override
  String get q06Title => 'What would you say?';

  @override
  String get q08Hint => 'Listen, then type it in Hiligaynon.';

  @override
  String get wordBankLabel => 'Word bank (optional)';

  @override
  String get q09Hint => 'Practice saying the phrase. There is no score.';

  @override
  String get nativeSpeaker => 'Native speaker';

  @override
  String get youLabel => 'You';

  @override
  String get recordTooltip => 'Record';

  @override
  String get stopRecordingTooltip => 'Stop recording';

  @override
  String get micUnavailable => 'Mic not available. You can skip this one.';

  @override
  String charCount(int count, int max) {
    return '$count / $max characters';
  }

  @override
  String get feedbackTimeUp => 'Time\'s up!';

  @override
  String get sampleAnswerTitle => 'Sample answer:';

  @override
  String get correctPairsLabel => 'Correct pairs:';

  @override
  String get leaveQuizTooltip => 'Leave the quiz';

  @override
  String get leaveQuizTitle => 'Leave the quiz?';

  @override
  String get leaveQuizText => 'Your answers won\'t be saved.';

  @override
  String timeLeft(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String get backToLessons => 'Back to lessons';

  @override
  String get filipinoName => 'Filipino';

  @override
  String get lessonCompleteTitle => 'Lesson complete!';

  @override
  String lessonCompleteLine(int number, String title) {
    return 'You finished Lesson $number: $title.';
  }

  @override
  String statXpPlus(int xp) {
    return '+$xp';
  }

  @override
  String get statXpLabel => 'XP';

  @override
  String get xpAlreadyEarned => 'XP · Already earned';

  @override
  String get newWordsLabel => 'New words';

  @override
  String get lettersLabel => 'Letters';

  @override
  String lessonUnlockedChip(int number) {
    return 'Lesson $number unlocked';
  }

  @override
  String levelCompleteChip(String level) {
    return '$level complete!';
  }

  @override
  String passToUnlockChip(int number) {
    return 'Pass this quiz to unlock Lesson $number';
  }

  @override
  String passToFinishLevelChip(String level) {
    return 'Pass this quiz to complete $level';
  }

  @override
  String get takeLessonQuiz => 'Take the lesson quiz';

  @override
  String continueToLesson(int number) {
    return 'Continue to Lesson $number';
  }

  @override
  String quizScoreLine(int correct, int total) {
    return 'You got $correct out of $total correct.';
  }

  @override
  String quizScoreLinePassed(int correct, int total) {
    return 'You got $correct out of $total correct!';
  }

  @override
  String get xpEarnedLabel => 'XP earned';

  @override
  String get accuracyLabel => 'Accuracy';

  @override
  String accuracyValue(int percent) {
    return '$percent%';
  }

  @override
  String get reviewAnswers => 'Review answers';

  @override
  String reviewQuestion(int number, String text) {
    return '$number. $text';
  }

  @override
  String reviewTyped(String type, String text) {
    return '$type: $text';
  }

  @override
  String get rvListening => 'Listening';

  @override
  String get rvFillBlank => 'Fill in the blank';

  @override
  String get rvType => 'Type';

  @override
  String get rvBuild => 'Build';

  @override
  String get rvRealSituation => 'Real situation';

  @override
  String get rvMatchPairs => 'Match the pairs';

  @override
  String get rvDictation => 'Dictation';

  @override
  String get rvSpeaking => 'Speaking';

  @override
  String get rvOpenAnswer => 'Open answer';

  @override
  String yourAnswerIs(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String correctAnswerIs(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get timeUpAnswer => '(time\'s up)';

  @override
  String pairsScore(int right, int total) {
    return '$right of $total pairs';
  }

  @override
  String get practiceTag => 'Practice';

  @override
  String get practiceNote => 'Saved for practice only. No score.';
}
