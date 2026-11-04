// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hiligaynon (`hil`).
class AppLocalizationsHil extends AppLocalizations {
  AppLocalizationsHil([String locale = 'hil']) : super(locale);

  @override
  String get learnTitle => 'Magtuon';

  @override
  String get learnSubtitle =>
      'Tun-i ang Hiligaynon paagi sa malip-ot nga mga leksyon!';

  @override
  String get learnSearchHint => 'Pangita sang leksyon...';

  @override
  String get learnLessonsHeading => 'Mga Leksyon';

  @override
  String learnLockedLevelsHint(String levels, String previous) {
    return '$levels: tapusa ang $previous para mabuksan';
  }

  @override
  String get listAnd => 'kag';

  @override
  String learnLevelLocked(String previous, String level) {
    return 'Tapusa ang $previous para mabuksan ang $level';
  }

  @override
  String learnNoResultsTitle(String query) {
    return 'Wala sing leksyon nga nakita para sa \'$query\'';
  }

  @override
  String get learnNoResultsHint =>
      'Tilawi ang iban nga tinaga, pareho sang \'greetings\' ukon \'numbers\'.';

  @override
  String get learnComingSoon => 'Madali na lang ang mga leksyon';

  @override
  String get learnLoadError => 'Indi ma-load ang mga leksyon.';

  @override
  String get tryAgain => 'Tilawi liwat';

  @override
  String get back => 'Balik';

  @override
  String lessonMeta(int parts, int minutes) {
    return '$parts ka bahin • $minutes min';
  }

  @override
  String rowQuizPending(int next) {
    return 'Kuhaa ang quiz para mabuksan ang Leksyon $next';
  }

  @override
  String rowQuizPendingLast(String level) {
    return 'Kuhaa ang quiz para matapos ang $level';
  }

  @override
  String rowLockedPassQuiz(int lesson) {
    return 'Ipasar ang quiz sang Leksyon $lesson para mabuksan';
  }

  @override
  String rowLockedFinish(int lesson) {
    return 'Tapusa ang Leksyon $lesson para mabuksan';
  }

  @override
  String get rowCompleted => 'Natapos na';

  @override
  String get rowLocked => 'Nakandaduhan';

  @override
  String lessonNumber(int number) {
    return 'Leksyon $number';
  }

  @override
  String get inThisLesson => 'Sa sini nga leksyon:';

  @override
  String get startLesson => 'Umpisahan ang leksyon';

  @override
  String get continueLesson => 'Padayunon ang leksyon';

  @override
  String get reviewLesson => 'Balikan ang leksyon';

  @override
  String get retakeQuiz => 'Liwaton ang quiz';

  @override
  String get lessonProgressTitle => 'Progreso sang leksyon';

  @override
  String partsProgress(int done, int total) {
    return '$done / $total ka bahin';
  }

  @override
  String completedQuizChip(int score, int total) {
    return 'Natapos na · Quiz $score/$total';
  }

  @override
  String get completedChip => 'Natapos na';

  @override
  String get comingNextStep =>
      'Ang lesson player maabot sa masunod nga lakang.';

  @override
  String partCaption(int lesson, int part, int total) {
    return 'Leksyon $lesson · Bahin $part sang $total';
  }

  @override
  String xpChip(int xp) {
    return '$xp XP';
  }

  @override
  String get leaveLessonTooltip => 'Bayaan ang leksyon';

  @override
  String get nextButton => 'Sunod';

  @override
  String get finishAndPractice => 'Tapusa kag mag-ensayo';

  @override
  String get finishLesson => 'Tapusa ang leksyon';

  @override
  String get leaveLessonTitle => 'Bayaan ini nga leksyon?';

  @override
  String get leaveLessonText => 'Liwaton mo ini nga bahin sa masunod.';

  @override
  String get keepGoing => 'Padayon';

  @override
  String get leave => 'Bayai';

  @override
  String get newWordChip => 'Bag-o nga tinaga';

  @override
  String get hiligaynonLabel => 'Hiligaynon';

  @override
  String alsoSaid(String alt) {
    return 'Ginahambal man: $alt';
  }

  @override
  String get playAudio => 'Patokara';

  @override
  String get playSlow => 'Patokara sing mahinay';

  @override
  String get exampleLabel => 'Halimbawa';

  @override
  String get noteLabel => 'NOTA';

  @override
  String get filipinoLabel => 'FILIPINO';

  @override
  String lettersSeen(int seen, int total) {
    return '$seen / $total nakita';
  }

  @override
  String get lettersHint =>
      'I-swipe ang mga letra. Hambala sing mabaskog ang kada halimbawa nga tinaga.';

  @override
  String get calledLabel => 'GINATAWAG';

  @override
  String letterPosition(int position, int total) {
    return '$position / $total';
  }

  @override
  String get quickCheckChip => 'Dali nga pamangkot · ensayo';

  @override
  String get quickCheckNote => 'Wala sang timer, wala sang iskor. Ensayo lang.';

  @override
  String get feedbackCorrect => 'Husto!';

  @override
  String get feedbackWrong => 'Indi pa husto';

  @override
  String get correctAnswerLabel => 'Husto nga sabat:';

  @override
  String xpGain(int xp) {
    return '+$xp XP';
  }

  @override
  String get continueButton => 'Padayon';

  @override
  String get showAllFilipino => 'Ipakita tanan nga Filipino';

  @override
  String get dialogueHint =>
      'Basaha sing mabaskog ang kada linya, dayon i-tap para makita ang Filipino.';

  @override
  String get readingHint =>
      'Basaha sing mabaskog ang kada sentence, dayon i-tap para makita ang Filipino.';

  @override
  String get tapToSeeFilipino => 'I-tap para makita ang Filipino';

  @override
  String get tapToHideFilipino => 'I-tap para taguon ang Filipino';

  @override
  String get commonMistakes => 'Kasagaran nga sala';

  @override
  String get moreExamples => 'Iban pa nga halimbawa';

  @override
  String get cultureNoteLabel => 'Nota sa kultura';

  @override
  String get lessonFinishedNote =>
      'Natapos ang leksyon! Ang Lesson complete screen maabot sa lakang 5.';
}
