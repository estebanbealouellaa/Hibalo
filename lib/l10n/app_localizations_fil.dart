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
}
