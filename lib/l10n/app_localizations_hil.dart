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
}
