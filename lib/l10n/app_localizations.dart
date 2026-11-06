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

  /// Question type chip: Q01 Multiple choice.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get qtChoose;

  /// Question type chip: Q02.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get qtListening;

  /// Question type chip: Q03.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get qtFillBlank;

  /// Question type chip: Q04.
  ///
  /// In en, this message translates to:
  /// **'Type the answer'**
  String get qtTypeAnswer;

  /// Question type chip: Q05.
  ///
  /// In en, this message translates to:
  /// **'Build the sentence'**
  String get qtBuildSentence;

  /// Question type chip: Q06.
  ///
  /// In en, this message translates to:
  /// **'Real situation'**
  String get qtRealSituation;

  /// Question type chip: Q07.
  ///
  /// In en, this message translates to:
  /// **'Match pairs'**
  String get qtMatchPairs;

  /// Question type chip: Q08.
  ///
  /// In en, this message translates to:
  /// **'Dictation'**
  String get qtDictation;

  /// Question type chip: Q09.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get qtSpeaking;

  /// Question type chip: Q10.
  ///
  /// In en, this message translates to:
  /// **'Open answer'**
  String get qtOpenAnswer;

  /// Quiz primary button before an answer is checked.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkButton;

  /// Q10 primary button.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Q01 line under the question.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct answer.'**
  String get q01Hint;

  /// Q02 line under the question.
  ///
  /// In en, this message translates to:
  /// **'Listen, then choose the answer.'**
  String get q02Hint;

  /// Q03 title.
  ///
  /// In en, this message translates to:
  /// **'Complete the sentence:'**
  String get q03Title;

  /// Q03 line under the title.
  ///
  /// In en, this message translates to:
  /// **'Choose the missing word.'**
  String get q03Hint;

  /// Q04 title when the text is Filipino.
  ///
  /// In en, this message translates to:
  /// **'Type this in Hiligaynon'**
  String get q04TitleToHil;

  /// Q04 title when the text is Hiligaynon.
  ///
  /// In en, this message translates to:
  /// **'Type this in Filipino'**
  String get q04TitleToFil;

  /// Q04 line under the title (Filipino to Hiligaynon).
  ///
  /// In en, this message translates to:
  /// **'Write the Hiligaynon word or phrase.'**
  String get q04HintToHil;

  /// Q04 line under the title (Hiligaynon to Filipino).
  ///
  /// In en, this message translates to:
  /// **'Write the Filipino word or phrase.'**
  String get q04HintToFil;

  /// Label above the Q04/Q08 text field.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// Q05 title.
  ///
  /// In en, this message translates to:
  /// **'Build the sentence'**
  String get q05Title;

  /// Q05 line under the title.
  ///
  /// In en, this message translates to:
  /// **'Tap the words in the right order.'**
  String get q05Hint;

  /// Q06 title.
  ///
  /// In en, this message translates to:
  /// **'What would you say?'**
  String get q06Title;

  /// Q08 line under the question.
  ///
  /// In en, this message translates to:
  /// **'Listen, then type it in Hiligaynon.'**
  String get q08Hint;

  /// Q08 label above the word chips.
  ///
  /// In en, this message translates to:
  /// **'Word bank (optional)'**
  String get wordBankLabel;

  /// Q09 line under the question.
  ///
  /// In en, this message translates to:
  /// **'Practice saying the phrase. There is no score.'**
  String get q09Hint;

  /// Q09 button that plays the recording.
  ///
  /// In en, this message translates to:
  /// **'Native speaker'**
  String get nativeSpeaker;

  /// Q09 button that plays the learner's recording.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// Q09 mic button (screen readers).
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordTooltip;

  /// Q09 stop button (screen readers).
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecordingTooltip;

  /// Q09 when the mic is refused or missing.
  ///
  /// In en, this message translates to:
  /// **'Mic not available. You can skip this one.'**
  String get micUnavailable;

  /// Q10 counter under the field.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} characters'**
  String charCount(int count, int max);

  /// F03 title.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get feedbackTimeUp;

  /// F04 title.
  ///
  /// In en, this message translates to:
  /// **'Sample answer:'**
  String get sampleAnswerTitle;

  /// F02/F03 label for Q07 (match pairs).
  ///
  /// In en, this message translates to:
  /// **'Correct pairs:'**
  String get correctPairsLabel;

  /// Quiz X button (screen readers).
  ///
  /// In en, this message translates to:
  /// **'Leave the quiz'**
  String get leaveQuizTooltip;

  /// S06 title, quiz version.
  ///
  /// In en, this message translates to:
  /// **'Leave the quiz?'**
  String get leaveQuizTitle;

  /// S06 text, quiz version.
  ///
  /// In en, this message translates to:
  /// **'Your answers won\'t be saved.'**
  String get leaveQuizText;

  /// Timer chip (screen readers).
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds left'**
  String timeLeft(int seconds);

  /// Button back to S01.
  ///
  /// In en, this message translates to:
  /// **'Back to lessons'**
  String get backToLessons;

  /// Label on the quiz prompt card (Q04, Q05) when the text is Filipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get filipinoName;

  /// S03 title.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete!'**
  String get lessonCompleteTitle;

  /// S03 line under the title.
  ///
  /// In en, this message translates to:
  /// **'You finished Lesson {number}: {title}.'**
  String lessonCompleteLine(int number, String title);

  /// S03 XP tile value.
  ///
  /// In en, this message translates to:
  /// **'+{xp}'**
  String statXpPlus(int xp);

  /// S03 XP tile label.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get statXpLabel;

  /// S03 XP tile label when the lesson XP was paid before.
  ///
  /// In en, this message translates to:
  /// **'XP · Already earned'**
  String get xpAlreadyEarned;

  /// S03 tile label.
  ///
  /// In en, this message translates to:
  /// **'New words'**
  String get newWordsLabel;

  /// S03 Letters tile label.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get lettersLabel;

  /// S03 Letters / S04 passed chip.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number} unlocked'**
  String lessonUnlockedChip(int number);

  /// S04 chip after the last quiz of a level: "Beginner complete!".
  ///
  /// In en, this message translates to:
  /// **'{level} complete!'**
  String levelCompleteChip(String level);

  /// S04 failed chip.
  ///
  /// In en, this message translates to:
  /// **'Pass this quiz to unlock Lesson {number}'**
  String passToUnlockChip(int number);

  /// S04 failed chip on the last lesson of a level.
  ///
  /// In en, this message translates to:
  /// **'Pass this quiz to complete {level}'**
  String passToFinishLevelChip(String level);

  /// S03 primary button.
  ///
  /// In en, this message translates to:
  /// **'Take the lesson quiz'**
  String get takeLessonQuiz;

  /// S03 Letters primary button.
  ///
  /// In en, this message translates to:
  /// **'Continue to Lesson {number}'**
  String continueToLesson(int number);

  /// S04 (not passed) and S05 line.
  ///
  /// In en, this message translates to:
  /// **'You got {correct} out of {total} correct.'**
  String quizScoreLine(int correct, int total);

  /// S04 line when passed.
  ///
  /// In en, this message translates to:
  /// **'You got {correct} out of {total} correct!'**
  String quizScoreLinePassed(int correct, int total);

  /// S04 tile label.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get xpEarnedLabel;

  /// S04 tile label.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyLabel;

  /// S04 accuracy tile value.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String accuracyValue(int percent);

  /// S04 text button and S05 title.
  ///
  /// In en, this message translates to:
  /// **'Review answers'**
  String get reviewAnswers;

  /// S05 row title.
  ///
  /// In en, this message translates to:
  /// **'{number}. {text}'**
  String reviewQuestion(int number, String text);

  /// S05 row title after the number, e.g. "Listening: What does…".
  ///
  /// In en, this message translates to:
  /// **'{type}: {text}'**
  String reviewTyped(String type, String text);

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get rvListening;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get rvFillBlank;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get rvType;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get rvBuild;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Real situation'**
  String get rvRealSituation;

  /// S05 row title for Q07.
  ///
  /// In en, this message translates to:
  /// **'Match the pairs'**
  String get rvMatchPairs;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Dictation'**
  String get rvDictation;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get rvSpeaking;

  /// S05 type label.
  ///
  /// In en, this message translates to:
  /// **'Open answer'**
  String get rvOpenAnswer;

  /// S05 row.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String yourAnswerIs(String answer);

  /// S05 wrong row.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswerIs(String answer);

  /// S05: the answer of a timed-out question.
  ///
  /// In en, this message translates to:
  /// **'(time\'s up)'**
  String get timeUpAnswer;

  /// S05 Q07 answer.
  ///
  /// In en, this message translates to:
  /// **'{right} of {total} pairs'**
  String pairsScore(int right, int total);

  /// S05 practice tag.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTag;

  /// S05 practice row.
  ///
  /// In en, this message translates to:
  /// **'Saved for practice only. No score.'**
  String get practiceNote;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get commonOpenSettings;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get commonSomethingWrong;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get commonEnterEmail;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get commonEnterYourEmail;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'That email doesn\'t look right'**
  String get commonEmailLooksWrong;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get commonAtLeast6;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get commonPasswordsDontMatch;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get commonProfilePicture;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String commonCharCounter(Object count, Object max);

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Hiligaynon'**
  String get commonHiligaynon;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get commonFilipino;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get commonEnglish;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get commonListen;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get commonStop;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get commonSaved;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get commonTakePhoto;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get commonChooseFromGallery;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Type instead'**
  String get commonTypeInstead;

  /// Common.
  ///
  /// In en, this message translates to:
  /// **'Start translating'**
  String get commonStartTranslating;

  /// Bottom bar.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom bar.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get navTranslate;

  /// Bottom bar.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// Bottom bar.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Hiligaynon · Filipino'**
  String get splashTagline;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'HILIGAYNON'**
  String get welcomeEyebrow;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Words make\nroom for us.'**
  String get welcomeTitle;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Learn everyday Hiligaynon, one small conversation at a time.'**
  String get welcomeBody;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Start with a hello.'**
  String get welcomeCardTitle;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Translate, listen and learn at your pace.'**
  String get welcomeCardBody;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeGetStarted;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get welcomeHaveAccount;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hibalo'**
  String get onboard1Title;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Translate between Hiligaynon and Filipino, and learn the language as you go.'**
  String get onboard1Body;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Type it, say it, or snap it'**
  String get onboard2Title;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Translate by typing, by speaking, or by taking a photo of a sign or a note.'**
  String get onboard2Body;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Learn a little every day'**
  String get onboard3Title;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Short lessons and quick quizzes. Earn XP and keep your daily streak going.'**
  String get onboard3Body;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardNext;

  /// Splash / Welcome / Onboarding.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {count}'**
  String onboardPageOf(Object current, Object count);

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'No internet. Connect to sign in.'**
  String get authNoInternetSignIn;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'No internet. Connect to sign up.'**
  String get authNoInternetSignUp;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get authWrongCredentials;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get authEmailInUse;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get authWelcomeBack;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Pick up where your words left off.'**
  String get authWelcomeBackSub;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Join Hibalo.'**
  String get authJoin;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Make an account to save your lessons, XP and streak.'**
  String get authJoinSub;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get authEnterUsername;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get authEnterAUsername;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'At least 2 characters'**
  String get authAtLeast2;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authEnterPassword;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get authReenterPassword;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authSigningIn;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get authCreatingAccount;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'New to Hibalo?'**
  String get authNewToHibalo;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAnAccount;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Too weak'**
  String get authStrengthTooWeak;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authStrengthFair;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get authStrengthGood;

  /// Sign in / Sign up.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authStrengthStrong;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'No internet. Connect to send the link.'**
  String get forgotNoInternet;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent again'**
  String get forgotLinkSentAgain;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotCheckEmail;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotTitle;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'We sent a reset link to {email}. Open it on this phone to make a new password.'**
  String forgotSentTo(Object email);

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to make a new one.'**
  String get forgotBody;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get forgotSending;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotSendLink;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get forgotBackToSignIn;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get forgotDidntGetIt;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get forgotRemembered;

  /// Forgot password.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get forgotResend;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'DAY STREAK'**
  String get homeDayStreak;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'LESSON'**
  String get homeLesson;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'LESSONS'**
  String get homeLessons;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get homeXp;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}: {title}'**
  String homeLessonTitle(Object number, Object title);

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} parts'**
  String homePartsDone(Object done, Object total);

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Part {part} of {total}'**
  String homePartOf(Object part, Object total);

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson {number}'**
  String homeStartLesson(Object number);

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz'**
  String get homeTakeQuiz;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'{level} complete!'**
  String homeLevelComplete(Object level);

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'All complete!'**
  String get homeAllComplete;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Every lesson done'**
  String get homeEveryLessonDone;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Review lessons'**
  String get homeReviewLessons;

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'{level} · Level {number}'**
  String homeLevelChip(Object level, Object number);

  /// Home.
  ///
  /// In en, this message translates to:
  /// **'Phrase of the day'**
  String get homePhraseOfDay;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get langChooseTitle;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get langContinue;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langTitle;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get langAppLanguage;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Changes the menus and buttons right away. Lessons stay in Hiligaynon with Filipino meanings.'**
  String get langNote;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String langChangedTo(Object language);

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get trTitle;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get trHistory;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Type or paste text here'**
  String get trTypeHere;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'From {from} to {to}'**
  String trFromTo(Object from, Object to);

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Swap languages'**
  String get trSwap;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get trClearText;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String trCharacters(Object count);

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get trSpeak;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Scan text from a photo'**
  String get trScanPhoto;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Translating…'**
  String get trTranslating;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Translating'**
  String get trTranslatingShort;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get trTranslateButton;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Preparing the voice'**
  String get trPreparingVoice;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get trCopy;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get trCopied;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get trShare;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'From your voice · check for mistakes'**
  String get trFromVoice;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Speak again'**
  String get trSpeakAgain;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'From your photo · check for mistakes'**
  String get trFromPhoto;

  /// Translate.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get trScanAgain;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get camAccessOffTitle;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'To take a photo, allow camera access in your phone settings. You can still choose a photo from your gallery.'**
  String get camAccessOffBody;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'No text found'**
  String get camNoTextTitle;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Try a clearer photo with good light, and keep the words straight and close.'**
  String get camNoTextBody;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the photo'**
  String get camCouldntReadTitle;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again or choose another photo.'**
  String get camCouldntReadBody;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get camChooseAnother;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Hibalo reads the words in the photo and translates them.'**
  String get camSheetBody;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Use your camera'**
  String get camUseCamera;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo you already have'**
  String get camPickExisting;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'Reading the text…'**
  String get camReading;

  /// Camera.
  ///
  /// In en, this message translates to:
  /// **'This takes a few seconds and works offline.'**
  String get camTakesSeconds;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Hold the mic and speak'**
  String get voiceHoldMic;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get voiceStopListening;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get voiceStartListening;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Tap again to stop'**
  String get voiceTapToStop;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get voiceTapToStart;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t catch that'**
  String get voiceDidntCatch;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Speak a little louder and closer to the phone, then try again.'**
  String get voiceDidntCatchBody;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off'**
  String get voiceMicOffTitle;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'To translate by voice, allow microphone access in your phone settings. You can still type instead.'**
  String get voiceMicOffBody;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Filipino voice'**
  String get voiceFilipinoTitle;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'To hear Filipino, install your phone\'s Filipino voice.'**
  String get voiceFilipinoInstall;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get voiceInstall;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get voiceLater;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'Your phone has no Filipino voice yet. Install it in Settings.'**
  String get voiceFilipinoMissing;

  /// Voice.
  ///
  /// In en, this message translates to:
  /// **'The Filipino voice isn\'t ready yet. Connect to the internet and try again.'**
  String get voiceFilipinoNotReady;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Tap a translation to open it again.'**
  String get histTapToOpen;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get histClearAll;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'No translations yet'**
  String get histEmptyTitle;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Words and phrases you translate will show up here, so you can open them again.'**
  String get histEmptyBody;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'No saved words yet'**
  String get savedEmptyTitle;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on a translation to keep it here for practice.'**
  String get savedEmptyBody;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'1 saved word or phrase'**
  String get savedCountOne;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'{count} saved words and phrases'**
  String savedCountMany(Object count);

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get histToday;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get histYesterday;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String histFromTo(Object from, Object to);

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get histRemoveSaved;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Translation history cleared'**
  String get histCleared;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistoryAction;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Clear translation history?'**
  String get clearHistoryTitle;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'This removes all your past translations from this phone. Your saved words stay.'**
  String get clearHistoryBody;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Keep history'**
  String get clearHistoryKeep;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Clear saved words'**
  String get clearSavedAction;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Clear saved words?'**
  String get clearSavedTitle;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'This removes every word you saved. Your lesson progress stays.'**
  String get clearSavedBody;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Keep saved words'**
  String get clearSavedKeep;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Saved words cleared'**
  String get savedCleared;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get meAccount;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get meEditProfile;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Name and avatar'**
  String get meEditProfileSub;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get meLanguageRow;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettings;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Data, privacy, credits'**
  String get meSettingsSub;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get meHelp;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'FAQ, contact us'**
  String get meHelpSub;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get meLogOut;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get meLogOutTitle;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved. You can sign back in any time.'**
  String get meLogOutBody;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get meStay;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get meProfileUpdated;

  /// Me.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get meUser;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editTitle;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Choose an avatar'**
  String get editChooseAvatar;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Avatar {number}'**
  String editAvatar(Object number);

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty.'**
  String get editUsernameEmpty;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters.'**
  String get editUsernameShort;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get editNewPassword;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get editConfirmNewPassword;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Current password (to confirm it\'s you)'**
  String get editCurrentPassword;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get editCurrentPasswordHint;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Only needed to change your email or password.'**
  String get editOnlyNeeded;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get editForgotPassword;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editSaveChanges;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get editDeleteAccount;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'That password isn\'t right. Try again.'**
  String get editWrongPassword;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to change your email or password.'**
  String get editNeedPassword;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to delete your account.'**
  String get editNeedPasswordDelete;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get editEmailInUse;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'No internet. Connect and try again.'**
  String get editNoInternet;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a moment and try again.'**
  String get editTooManyTries;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get editCouldntSave;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Check your new email'**
  String get editCheckEmailTitle;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {email}. Open it to finish changing your email. Until then, sign in with your old email.'**
  String editCheckEmailBody(Object email);

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get editResendLink;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Link sent again'**
  String get editLinkSent;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get editDeleteTitle;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'This removes your profile, progress, saved words and history. This can\'t be undone.'**
  String get editDeleteBody;

  /// Edit profile.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get editDeleteKeep;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Credits & licences'**
  String get settingsCredits;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Voice, data, icons and fonts'**
  String get settingsCreditsSub;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Hibalo {version}'**
  String settingsVersionValue(Object version);

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Hibalo was made by students of the Polytechnic University of the Philippines for a capstone study.'**
  String get privacyIntro;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'What we save'**
  String get privacySaveLabel;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'your username, email address and chosen avatar; when you signed up and last signed in; and your learning progress (lessons finished, quiz scores, XP and streak). These are saved in Google Firebase so your progress isn\'t lost.'**
  String get privacySaveText;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'What we don\'t save'**
  String get privacyNotSaveLabel;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'the text you translate, the pictures you scan and your voice. Your translation history and saved words are kept only on your phone; uninstalling the app or clearing them in Settings deletes them. Translation and picture reading happen on your phone. Speech-to-text uses your phone\'s own speech service, which may follow Google\'s privacy terms. Speaking practice in lessons is kept on your phone only while you use it, then deleted.'**
  String get privacyNotSaveText;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Who can see your data'**
  String get privacyWhoLabel;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'only you and the research team (app administrators). You can\'t see other users\' data, and they can\'t see yours.'**
  String get privacyWhoText;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'How your data is used'**
  String get privacyUseLabel;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'only for this study. It is not sold or shared.'**
  String get privacyUseText;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyDeleteLabel;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'you can delete your account and progress in Me › Edit profile, or ask the research team to do it.'**
  String get privacyDeleteText;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get privacyQuestionsLabel;

  /// Privacy policy.
  ///
  /// In en, this message translates to:
  /// **'contact the Hibalo research team.'**
  String get privacyQuestionsText;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Made by the Hibalo team, Polytechnic University of the Philippines.'**
  String get creditsIntro;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Hiligaynon voice'**
  String get creditsVoiceLabel;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'a fine-tuned version of Meta\'s MMS-TTS (VITS) model, licensed CC BY-NC 4.0 (non-commercial use only).'**
  String get creditsVoiceText;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Voice training data'**
  String get creditsDataLabel;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Philippine Languages Database (PLD), University of the Philippines Diliman Digital Signal Processing Laboratory (UP-DSP).'**
  String get creditsDataText;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get creditsTranslationLabel;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'a MarianMT model trained by the Hibalo team, with help from the MADLAD-400 model and public Hiligaynon and Filipino texts.'**
  String get creditsTranslationText;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Lesson content'**
  String get creditsLessonsLabel;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'written by the Hibalo team and checked against public references, including Omniglot, Iloilo Directory, Wikipedia, the ERIC Hiligaynon language packet (ED402758) and pinoydictionary.com.'**
  String get creditsLessonsText;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Text reading'**
  String get creditsReadingLabel;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Google ML Kit. Font: Plus Jakarta Sans (SIL Open Font License). Icons: Material Symbols (Apache License 2.0).'**
  String get creditsReadingText;

  /// Credits.
  ///
  /// In en, this message translates to:
  /// **'Open-source software'**
  String get creditsOpenSource;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqTitle;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'How do I translate a photo?'**
  String get helpQ1;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'On Translate, tap the camera button, then take a photo or choose one from your gallery. Check the text Hibalo reads, then tap Translate.'**
  String get helpA1;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Does Hibalo work without internet?'**
  String get helpQ2;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Yes, after you sign in once. Translating, reading photos, the Hiligaynon voice and the lessons work offline. Your progress is saved to your account when you are back online. Speaking to translate uses your phone\'s speech service, which may need internet.'**
  String get helpA2;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'What if a translation looks wrong?'**
  String get helpQ3;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Translations are made on your phone and may not be exact. Try a shorter sentence or check the spelling. For voice and photos, fix the text in the box, then tap Translate.'**
  String get helpA3;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'How do I unlock the next lesson?'**
  String get helpQ4;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Pass the lesson\'s quiz with at least 80%. Lesson 2 unlocks when you finish Lesson 1.'**
  String get helpA4;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'How do I earn XP?'**
  String get helpQ5;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Finish a lesson (20 XP), answer a quick check right (5 XP) or answer a quiz question right (10 XP). Each one gives XP only the first time.'**
  String get helpA5;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'How do I change my avatar?'**
  String get helpQ6;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Go to Me, tap Edit profile, choose an avatar, then tap Save changes.'**
  String get helpA6;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get helpStillNeed;

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Email us at {email}'**
  String helpEmailUs(Object email);

  /// Help.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the email app.'**
  String get helpCantOpenEmail;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get adminGoodMorning;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get adminGoodAfternoon;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get adminGoodEvening;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminTitle;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get adminManagement;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get adminManageUsers;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'View, edit, promote or remove users'**
  String get adminManageUsersSub;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get adminUsage;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Daily & weekly active user breakdown'**
  String get adminUsageSub;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Recent Signups'**
  String get adminRecentSignups;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Switch to Light'**
  String get adminSwitchLight;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Switch to Dark'**
  String get adminSwitchDark;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminRefresh;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get adminLogout;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminTotalUsers;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminAdmins;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Active Today'**
  String get adminActiveToday;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Active / Week'**
  String get adminActiveWeek;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'No users yet.'**
  String get adminNoUsersYet;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminUnknown;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get adminBadge;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get adminNoEmail;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard...'**
  String get adminLoading;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get adminSearch;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminAll;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get adminNoUsersFound;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get adminNoName;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get adminNoEmailCap;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminEdit;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get adminRemoveAdmin;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get adminMakeAdmin;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDelete;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'User promoted to admin'**
  String get adminPromoted;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Admin role removed'**
  String get adminDemoted;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String adminError(Object error);

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get adminEditUser;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminName;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get adminUserUpdated;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get adminDeleteUser;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?\nThis cannot be undone.'**
  String adminDeleteConfirm(Object name);

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get adminUserDeleted;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'DAILY ACTIVE USERS — LAST 7 DAYS'**
  String get adminDailyActive;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'BREAKDOWN'**
  String get adminBreakdown;

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String adminActiveCount(Object count);

  /// Admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminEntry;

  /// History / Saved.
  ///
  /// In en, this message translates to:
  /// **'Clear translation history'**
  String get settingsClearHistory;
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
