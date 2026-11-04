import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_hil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fil'),
    Locale('hil'),
  ];

  /// S01 title.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// S01 line under the title.
  ///
  /// In en, this message translates to:
  /// **'Explore Hiligaynon through bite-sized lessons!'**
  String get learnSubtitle;

  /// S01 search field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search lessons...'**
  String get learnSearchHint;

  /// S01 heading above the lesson list.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get learnLessonsHeading;

  /// S01 hint under the level tabs while later levels are locked, e.g. 'Intermediate and Advanced: finish Beginner to unlock'.
  ///
  /// In en, this message translates to:
  /// **'{levels}: finish {previous} to unlock'**
  String learnLockedLevelsHint(String levels, String previous);

  /// Joins the last two names in a list: 'Intermediate and Advanced'.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get listAnd;

  /// S01 snackbar when a locked level tab is tapped.
  ///
  /// In en, this message translates to:
  /// **'Finish {previous} to unlock {level}'**
  String learnLevelLocked(String previous, String level);

  /// S01 empty search result.
  ///
  /// In en, this message translates to:
  /// **'No lessons found for \'{query}\''**
  String learnNoResultsTitle(String query);

  /// S01 empty search result, second line.
  ///
  /// In en, this message translates to:
  /// **'Try another word, like \'greetings\' or \'numbers\'.'**
  String get learnNoResultsHint;

  /// S01 when an unlocked level has no lessons yet.
  ///
  /// In en, this message translates to:
  /// **'Lessons coming soon'**
  String get learnComingSoon;

  /// S01 when lessons.json fails to load.
  ///
  /// In en, this message translates to:
  /// **'The lessons couldn\'t be loaded.'**
  String get learnLoadError;

  /// Retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Back button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Lesson row meta line and S02 chip.
  ///
  /// In en, this message translates to:
  /// **'{parts} parts • {minutes} min'**
  String lessonMeta(int parts, int minutes);

  /// S01 row meta when the lesson is finished but its quiz isn't passed.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz to unlock Lesson {next}'**
  String rowQuizPending(int next);

  /// Quiz pending on the last lesson of a level (no next lesson).
  ///
  /// In en, this message translates to:
  /// **'Take the quiz to finish {level}'**
  String rowQuizPendingLast(String level);

  /// S01 locked row: needs the quiz of an earlier lesson.
  ///
  /// In en, this message translates to:
  /// **'Pass Lesson {lesson} quiz to unlock'**
  String rowLockedPassQuiz(int lesson);

  /// S01 locked row: needs an earlier lesson finished (Lesson 2).
  ///
  /// In en, this message translates to:
  /// **'Finish Lesson {lesson} to unlock'**
  String rowLockedFinish(int lesson);

  /// Screen reader label for a completed lesson row.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rowCompleted;

  /// Screen reader label for a locked row or level tab.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get rowLocked;

  /// S02 top bar title.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonNumber(int number);

  /// S02 heading above the objectives.
  ///
  /// In en, this message translates to:
  /// **'In this lesson:'**
  String get inThisLesson;

  /// S02 primary button, not started.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get startLesson;

  /// S02 primary button, in progress.
  ///
  /// In en, this message translates to:
  /// **'Continue lesson'**
  String get continueLesson;

  /// S02 primary button, completed.
  ///
  /// In en, this message translates to:
  /// **'Review lesson'**
  String get reviewLesson;

  /// S02 text button, completed.
  ///
  /// In en, this message translates to:
  /// **'Retake the quiz'**
  String get retakeQuiz;

  /// S02 progress card title.
  ///
  /// In en, this message translates to:
  /// **'Lesson progress'**
  String get lessonProgressTitle;

  /// S02 progress card count.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} parts'**
  String partsProgress(int done, int total);

  /// S02 chip on a completed lesson: best quiz score.
  ///
  /// In en, this message translates to:
  /// **'Completed · Quiz {score}/{total}'**
  String completedQuizChip(int score, int total);

  /// S02 chip on a completed lesson with no quiz (Lesson 1).
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedChip;

  /// Temporary: shown until the lesson and quiz players exist.
  ///
  /// In en, this message translates to:
  /// **'The lesson player comes in the next build step.'**
  String get comingNextStep;

  /// Caption under the segmented bar on every part.
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson} · Part {part} of {total}'**
  String partCaption(int lesson, int part, int total);

  /// XP earned in this lesson so far (top right).
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpChip(int xp);

  /// X button tooltip on lesson parts.
  ///
  /// In en, this message translates to:
  /// **'Leave the lesson'**
  String get leaveLessonTooltip;

  /// Primary button on lesson parts.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// Last part when the lesson has a quiz (settings.lessonButtons.lastPartWithQuiz).
  ///
  /// In en, this message translates to:
  /// **'Finish & practice'**
  String get finishAndPractice;

  /// Last part when the lesson has no quiz (settings.lessonButtons.lastPartNoQuiz).
  ///
  /// In en, this message translates to:
  /// **'Finish lesson'**
  String get finishLesson;

  /// S06 title, lesson version.
  ///
  /// In en, this message translates to:
  /// **'Leave this lesson?'**
  String get leaveLessonTitle;

  /// S06 text, lesson version.
  ///
  /// In en, this message translates to:
  /// **'You\'ll restart this part next time.'**
  String get leaveLessonText;

  /// S06 primary button.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// S06 text button.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// P04 chip.
  ///
  /// In en, this message translates to:
  /// **'New word'**
  String get newWordChip;

  /// Label above a Hiligaynon word and on term cards.
  ///
  /// In en, this message translates to:
  /// **'Hiligaynon'**
  String get hiligaynonLabel;

  /// P04 line for another Hiligaynon way to say the word.
  ///
  /// In en, this message translates to:
  /// **'Also said: {alt}'**
  String alsoSaid(String alt);

  /// Audio button label for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playAudio;

  /// Slow audio button label for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Play slowly'**
  String get playSlow;

  /// P04 example box label.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get exampleLabel;

  /// P01 term card row label.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get noteLabel;

  /// P01 term card row label.
  ///
  /// In en, this message translates to:
  /// **'FILIPINO'**
  String get filipinoLabel;

  /// P05 header count.
  ///
  /// In en, this message translates to:
  /// **'{seen} / {total} seen'**
  String lettersSeen(int seen, int total);

  /// P05 instruction.
  ///
  /// In en, this message translates to:
  /// **'Swipe through the letters. Say each example word out loud.'**
  String get lettersHint;

  /// P05 label above the letter name.
  ///
  /// In en, this message translates to:
  /// **'CALLED'**
  String get calledLabel;

  /// P05 progress under the carousel.
  ///
  /// In en, this message translates to:
  /// **'{position} / {total}'**
  String letterPosition(int position, int total);

  /// P06 chip.
  ///
  /// In en, this message translates to:
  /// **'Quick check · practice'**
  String get quickCheckChip;

  /// P06 line under the question.
  ///
  /// In en, this message translates to:
  /// **'No timer, no score. Just practice.'**
  String get quickCheckNote;

  /// F01 title.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get feedbackCorrect;

  /// F02 title.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get feedbackWrong;

  /// F02/F03 label.
  ///
  /// In en, this message translates to:
  /// **'Correct answer:'**
  String get correctAnswerLabel;

  /// XP paid on the Correct sheet.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpGain(int xp);

  /// Feedback sheet button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// P07/P08 switch.
  ///
  /// In en, this message translates to:
  /// **'Show all Filipino'**
  String get showAllFilipino;

  /// P07 hint.
  ///
  /// In en, this message translates to:
  /// **'Read each line aloud, then tap it to check the Filipino.'**
  String get dialogueHint;

  /// P08 hint.
  ///
  /// In en, this message translates to:
  /// **'Read each sentence aloud, then tap it to check the Filipino.'**
  String get readingHint;

  /// P07 bubble hint, Filipino hidden.
  ///
  /// In en, this message translates to:
  /// **'Tap to see Filipino'**
  String get tapToSeeFilipino;

  /// P07 bubble hint, Filipino shown.
  ///
  /// In en, this message translates to:
  /// **'Tap to hide Filipino'**
  String get tapToHideFilipino;

  /// P09 second section title.
  ///
  /// In en, this message translates to:
  /// **'Common mistakes'**
  String get commonMistakes;

  /// P03 section title.
  ///
  /// In en, this message translates to:
  /// **'More examples'**
  String get moreExamples;

  /// P10 label above the text.
  ///
  /// In en, this message translates to:
  /// **'Culture note'**
  String get cultureNoteLabel;

  /// Temporary: shown after the last part until S03 exists.
  ///
  /// In en, this message translates to:
  /// **'Lesson finished! The Lesson complete screen comes in step 5.'**
  String get lessonFinishedNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil', 'hil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
    case 'hil':
      return AppLocalizationsHil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
