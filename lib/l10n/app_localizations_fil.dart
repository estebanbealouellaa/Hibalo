// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get learnTitle => 'Matuto';

  @override
  String get learnSubtitle => 'Tuklasin ang Hiligaynon sa maiikling aralin!';

  @override
  String get learnSearchHint => 'Maghanap ng aralin...';

  @override
  String get learnLessonsHeading => 'Mga Aralin';

  @override
  String learnLockedLevelsHint(String levels, String previous) {
    return '$levels: tapusin ang $previous para mabuksan';
  }

  @override
  String get listAnd => 'at';

  @override
  String learnLevelLocked(String previous, String level) {
    return 'Tapusin ang $previous para mabuksan ang $level';
  }

  @override
  String learnNoResultsTitle(String query) {
    return 'Walang nakitang aralin para sa \'$query\'';
  }

  @override
  String get learnNoResultsHint =>
      'Sumubok ng ibang salita, tulad ng \'greetings\' o \'numbers\'.';

  @override
  String get learnComingSoon => 'Malapit nang dumating ang mga aralin';

  @override
  String get learnLoadError => 'Hindi ma-load ang mga aralin.';

  @override
  String get tryAgain => 'Subukan ulit';

  @override
  String get back => 'Bumalik';

  @override
  String lessonMeta(int parts, int minutes) {
    return '$parts bahagi • $minutes min';
  }

  @override
  String rowQuizPending(int next) {
    return 'Kunin ang pagsusulit para mabuksan ang Aralin $next';
  }

  @override
  String rowQuizPendingLast(String level) {
    return 'Kunin ang pagsusulit para matapos ang $level';
  }

  @override
  String rowLockedPassQuiz(int lesson) {
    return 'Ipasa ang pagsusulit ng Aralin $lesson para mabuksan';
  }

  @override
  String rowLockedFinish(int lesson) {
    return 'Tapusin ang Aralin $lesson para mabuksan';
  }

  @override
  String get rowCompleted => 'Tapos na';

  @override
  String get rowLocked => 'Nakakandado';

  @override
  String lessonNumber(int number) {
    return 'Aralin $number';
  }

  @override
  String get inThisLesson => 'Sa araling ito:';

  @override
  String get startLesson => 'Simulan ang aralin';

  @override
  String get continueLesson => 'Ituloy ang aralin';

  @override
  String get reviewLesson => 'Balikan ang aralin';

  @override
  String get retakeQuiz => 'Ulitin ang pagsusulit';

  @override
  String get lessonProgressTitle => 'Progreso ng aralin';

  @override
  String partsProgress(int done, int total) {
    return '$done / $total bahagi';
  }

  @override
  String completedQuizChip(int score, int total) {
    return 'Tapos na · Pagsusulit $score/$total';
  }

  @override
  String get completedChip => 'Tapos na';

  @override
  String get comingNextStep =>
      'Darating ang lesson player sa susunod na hakbang.';

  @override
  String partCaption(int lesson, int part, int total) {
    return 'Aralin $lesson · Bahagi $part ng $total';
  }

  @override
  String xpChip(int xp) {
    return '$xp XP';
  }

  @override
  String get leaveLessonTooltip => 'Umalis sa aralin';

  @override
  String get nextButton => 'Susunod';

  @override
  String get finishAndPractice => 'Tapusin at magsanay';

  @override
  String get finishLesson => 'Tapusin ang aralin';

  @override
  String get leaveLessonTitle => 'Aalis sa araling ito?';

  @override
  String get leaveLessonText => 'Uulitin mo ang bahaging ito sa susunod.';

  @override
  String get keepGoing => 'Ituloy';

  @override
  String get leave => 'Umalis';

  @override
  String get newWordChip => 'Bagong salita';

  @override
  String get hiligaynonLabel => 'Hiligaynon';

  @override
  String alsoSaid(String alt) {
    return 'Sinasabi rin: $alt';
  }

  @override
  String get playAudio => 'I-play';

  @override
  String get playSlow => 'I-play nang mabagal';

  @override
  String get exampleLabel => 'Halimbawa';

  @override
  String get noteLabel => 'TALA';

  @override
  String get filipinoLabel => 'FILIPINO';

  @override
  String lettersSeen(int seen, int total) {
    return '$seen / $total nakita';
  }

  @override
  String get lettersHint =>
      'I-swipe ang mga titik. Bigkasin nang malakas ang bawat halimbawang salita.';

  @override
  String get calledLabel => 'TAWAG';

  @override
  String letterPosition(int position, int total) {
    return '$position / $total';
  }

  @override
  String get quickCheckChip => 'Mabilis na tanong · pagsasanay';

  @override
  String get quickCheckNote => 'Walang timer, walang iskor. Pagsasanay lang.';

  @override
  String get feedbackCorrect => 'Tama!';

  @override
  String get feedbackWrong => 'Hindi pa tama';

  @override
  String get correctAnswerLabel => 'Tamang sagot:';

  @override
  String xpGain(int xp) {
    return '+$xp XP';
  }

  @override
  String get continueButton => 'Magpatuloy';

  @override
  String get showAllFilipino => 'Ipakita lahat ng Filipino';

  @override
  String get dialogueHint =>
      'Basahin nang malakas ang bawat linya, saka i-tap para makita ang Filipino.';

  @override
  String get readingHint =>
      'Basahin nang malakas ang bawat pangungusap, saka i-tap para makita ang Filipino.';

  @override
  String get tapToSeeFilipino => 'I-tap para makita ang Filipino';

  @override
  String get tapToHideFilipino => 'I-tap para itago ang Filipino';

  @override
  String get commonMistakes => 'Karaniwang mali';

  @override
  String get moreExamples => 'Iba pang halimbawa';

  @override
  String get cultureNoteLabel => 'Tala sa kultura';

  @override
  String get lessonFinishedNote =>
      'Tapos ang aralin! Darating ang Lesson complete screen sa hakbang 5.';

  @override
  String get qtChoose => 'Pumili';

  @override
  String get qtListening => 'Pakikinig';

  @override
  String get qtFillBlank => 'Punan ang patlang';

  @override
  String get qtTypeAnswer => 'I-type ang sagot';

  @override
  String get qtBuildSentence => 'Buuin ang pangungusap';

  @override
  String get qtRealSituation => 'Totoong sitwasyon';

  @override
  String get qtMatchPairs => 'Pagtapatin';

  @override
  String get qtDictation => 'Diktasyon';

  @override
  String get qtSpeaking => 'Pagsasalita';

  @override
  String get qtOpenAnswer => 'Malayang sagot';

  @override
  String get checkButton => 'Suriin';

  @override
  String get submitButton => 'Ipasa';

  @override
  String get q01Hint => 'Piliin ang tamang sagot.';

  @override
  String get q02Hint => 'Makinig, saka piliin ang sagot.';

  @override
  String get q03Title => 'Kumpletuhin ang pangungusap:';

  @override
  String get q03Hint => 'Piliin ang nawawalang salita.';

  @override
  String get q04TitleToHil => 'I-type ito sa Hiligaynon';

  @override
  String get q04TitleToFil => 'I-type ito sa Filipino';

  @override
  String get q04HintToHil => 'Isulat ang salita o parirala sa Hiligaynon.';

  @override
  String get q04HintToFil => 'Isulat ang salita o parirala sa Filipino.';

  @override
  String get yourAnswer => 'Ang sagot mo';

  @override
  String get q05Title => 'Buuin ang pangungusap';

  @override
  String get q05Hint => 'I-tap ang mga salita sa tamang ayos.';

  @override
  String get q06Title => 'Ano ang sasabihin mo?';

  @override
  String get q08Hint => 'Makinig, saka i-type sa Hiligaynon.';

  @override
  String get wordBankLabel => 'Mga salita (opsyonal)';

  @override
  String get q09Hint => 'Sanayin ang pagsabi ng parirala. Walang iskor.';

  @override
  String get nativeSpeaker => 'Katutubong nagsasalita';

  @override
  String get youLabel => 'Ikaw';

  @override
  String get recordTooltip => 'I-record';

  @override
  String get stopRecordingTooltip => 'Itigil ang pag-record';

  @override
  String get micUnavailable =>
      'Hindi magamit ang mic. Puwede mo itong laktawan.';

  @override
  String charCount(int count, int max) {
    return '$count / $max na titik';
  }

  @override
  String get feedbackTimeUp => 'Ubos na ang oras!';

  @override
  String get sampleAnswerTitle => 'Halimbawang sagot:';

  @override
  String get correctPairsLabel => 'Tamang pares:';

  @override
  String get leaveQuizTooltip => 'Umalis sa pagsusulit';

  @override
  String get leaveQuizTitle => 'Aalis sa pagsusulit?';

  @override
  String get leaveQuizText => 'Hindi mase-save ang mga sagot mo.';

  @override
  String timeLeft(int seconds) {
    return '$seconds segundo pa';
  }

  @override
  String get quizDoneTitle => 'Tapos ang pagsusulit';

  @override
  String quizDoneScore(int correct, int total) {
    return 'Tama ang $correct sa $total.';
  }

  @override
  String get quizDoneAccuracy => 'Katumpakan';

  @override
  String get quizDoneXp => 'Nakuhang XP';

  @override
  String get quizDonePassed => 'Pasado! Bukas na ang susunod na aralin.';

  @override
  String get quizDoneNotPassed =>
      'Ipasa ang pagsusulit para mabuksan ang susunod na aralin.';

  @override
  String get quizDoneNote => 'Darating ang Quiz result screen sa hakbang 5.';

  @override
  String get backToLessons => 'Bumalik sa mga aralin';

  @override
  String get filipinoName => 'Filipino';
}
