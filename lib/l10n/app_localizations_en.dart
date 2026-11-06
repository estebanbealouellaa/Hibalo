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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSomethingWrong => 'Something went wrong. Try again.';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonEnterEmail => 'Enter email';

  @override
  String get commonEnterYourEmail => 'Enter your email';

  @override
  String get commonEmailLooksWrong => 'That email doesn\'t look right';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonAtLeast6 => 'At least 6 characters';

  @override
  String get commonPasswordsDontMatch => 'Passwords do not match';

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String get commonProfilePicture => 'Profile picture';

  @override
  String commonCharCounter(Object count, Object max) {
    return '$count/$max';
  }

  @override
  String get commonHiligaynon => 'Hiligaynon';

  @override
  String get commonFilipino => 'Filipino';

  @override
  String get commonEnglish => 'English';

  @override
  String get commonListen => 'Listen';

  @override
  String get commonStop => 'Stop';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaved => 'Saved';

  @override
  String get commonTakePhoto => 'Take a photo';

  @override
  String get commonChooseFromGallery => 'Choose from gallery';

  @override
  String get commonTypeInstead => 'Type instead';

  @override
  String get commonStartTranslating => 'Start translating';

  @override
  String get navHome => 'Home';

  @override
  String get navTranslate => 'Translate';

  @override
  String get navLearn => 'Learn';

  @override
  String get navMe => 'Me';

  @override
  String get splashTagline => 'Hiligaynon · Filipino';

  @override
  String get welcomeEyebrow => 'HILIGAYNON';

  @override
  String get welcomeTitle => 'Words make\nroom for us.';

  @override
  String get welcomeBody =>
      'Learn everyday Hiligaynon, one small conversation at a time.';

  @override
  String get welcomeCardTitle => 'Start with a hello.';

  @override
  String get welcomeCardBody => 'Translate, listen and learn at your pace.';

  @override
  String get welcomeGetStarted => 'Get started';

  @override
  String get welcomeHaveAccount => 'I already have an account';

  @override
  String get onboard1Title => 'Welcome to Hibalo';

  @override
  String get onboard1Body =>
      'Translate between Hiligaynon and Filipino, and learn the language as you go.';

  @override
  String get onboard2Title => 'Type it, say it, or snap it';

  @override
  String get onboard2Body =>
      'Translate by typing, by speaking, or by taking a photo of a sign or a note.';

  @override
  String get onboard3Title => 'Learn a little every day';

  @override
  String get onboard3Body =>
      'Short lessons and quick quizzes. Earn XP and keep your daily streak going.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardNext => 'Next';

  @override
  String onboardPageOf(Object current, Object count) {
    return 'Page $current of $count';
  }

  @override
  String get authNoInternetSignIn => 'No internet. Connect to sign in.';

  @override
  String get authNoInternetSignUp => 'No internet. Connect to sign up.';

  @override
  String get authWrongCredentials => 'Wrong email or password.';

  @override
  String get authEmailInUse => 'This email is already in use.';

  @override
  String get authWelcomeBack => 'Welcome back.';

  @override
  String get authWelcomeBackSub => 'Pick up where your words left off.';

  @override
  String get authJoin => 'Join Hibalo.';

  @override
  String get authJoinSub =>
      'Make an account to save your lessons, XP and streak.';

  @override
  String get authUsername => 'Username';

  @override
  String get authEnterUsername => 'Enter username';

  @override
  String get authEnterAUsername => 'Enter a username';

  @override
  String get authAtLeast2 => 'At least 2 characters';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authReenterPassword => 'Re-enter password';

  @override
  String get authSigningIn => 'Signing in…';

  @override
  String get authCreatingAccount => 'Creating account…';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authNewToHibalo => 'New to Hibalo?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authCreateAnAccount => 'Create an account';

  @override
  String get authStrengthTooWeak => 'Too weak';

  @override
  String get authStrengthFair => 'Fair';

  @override
  String get authStrengthGood => 'Good';

  @override
  String get authStrengthStrong => 'Strong';

  @override
  String get forgotNoInternet => 'No internet. Connect to send the link.';

  @override
  String get forgotLinkSentAgain => 'Reset link sent again';

  @override
  String get forgotCheckEmail => 'Check your email';

  @override
  String get forgotCheckSpam => 'Don\'t see it? Check your Spam folder.';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String forgotSentTo(Object email) {
    return 'We sent a reset link to $email. Open it on this phone to make a new password.';
  }

  @override
  String get forgotBody =>
      'Enter your email and we\'ll send you a link to make a new one.';

  @override
  String get forgotSending => 'Sending…';

  @override
  String get forgotSendLink => 'Send reset link';

  @override
  String get forgotBackToSignIn => 'Back to sign in';

  @override
  String get forgotDidntGetIt => 'Didn\'t get it?';

  @override
  String get forgotRemembered => 'Remembered it?';

  @override
  String get forgotResend => 'Resend link';

  @override
  String get homeDayStreak => 'DAY STREAK';

  @override
  String get homeLesson => 'LESSON';

  @override
  String get homeLessons => 'LESSONS';

  @override
  String get homeXp => 'XP';

  @override
  String homeLessonTitle(Object number, Object title) {
    return 'Lesson $number: $title';
  }

  @override
  String homePartsDone(Object done, Object total) {
    return '$done of $total parts';
  }

  @override
  String homePartOf(Object part, Object total) {
    return 'Part $part of $total';
  }

  @override
  String homeStartLesson(Object number) {
    return 'Start Lesson $number';
  }

  @override
  String get homeTakeQuiz => 'Take the quiz';

  @override
  String homeLevelComplete(Object level) {
    return '$level complete!';
  }

  @override
  String get homeAllComplete => 'All complete!';

  @override
  String get homeEveryLessonDone => 'Every lesson done';

  @override
  String get homeReviewLessons => 'Review lessons';

  @override
  String homeLevelChip(Object level, Object number) {
    return '$level · Level $number';
  }

  @override
  String get homePhraseOfDay => 'Phrase of the day';

  @override
  String get langChooseTitle => 'Choose your language';

  @override
  String get langContinue => 'Continue';

  @override
  String get langTitle => 'Language';

  @override
  String get langAppLanguage => 'App language';

  @override
  String get langNote =>
      'Changes the menus and buttons right away. Lessons stay in Hiligaynon with Filipino meanings.';

  @override
  String langChangedTo(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get trTitle => 'Translate';

  @override
  String get trHistory => 'History';

  @override
  String get trTypeHere => 'Type or paste text here';

  @override
  String trFromTo(Object from, Object to) {
    return 'From $from to $to';
  }

  @override
  String get trSwap => 'Swap languages';

  @override
  String get trClearText => 'Clear text';

  @override
  String trCharacters(Object count) {
    return '$count characters';
  }

  @override
  String get trSpeak => 'Speak';

  @override
  String get trScanPhoto => 'Scan text from a photo';

  @override
  String get trTranslating => 'Translating…';

  @override
  String get trTranslatingShort => 'Translating';

  @override
  String get trTranslateButton => 'Translate';

  @override
  String get trPreparingVoice => 'Preparing the voice';

  @override
  String get trCopy => 'Copy';

  @override
  String get trCopied => 'Copied';

  @override
  String get trShare => 'Share';

  @override
  String get trFromVoice => 'From your voice · check for mistakes';

  @override
  String get trSpeakAgain => 'Speak again';

  @override
  String get trFromPhoto => 'From your photo · check for mistakes';

  @override
  String get trScanAgain => 'Scan again';

  @override
  String get camAccessOffTitle => 'Camera access is off';

  @override
  String get camAccessOffBody =>
      'To take a photo, allow camera access in your phone settings. You can still choose a photo from your gallery.';

  @override
  String get camNoTextTitle => 'No text found';

  @override
  String get camNoTextBody =>
      'Try a clearer photo with good light, and keep the words straight and close.';

  @override
  String get camCouldntReadTitle => 'Couldn\'t read the photo';

  @override
  String get camCouldntReadBody =>
      'Something went wrong. Please try again or choose another photo.';

  @override
  String get camChooseAnother => 'Choose another';

  @override
  String get camSheetBody =>
      'Hibalo reads the words in the photo and translates them.';

  @override
  String get camUseCamera => 'Use your camera';

  @override
  String get camPickExisting => 'Pick a photo you already have';

  @override
  String get camReading => 'Reading the text…';

  @override
  String get camTakesSeconds => 'This takes a few seconds and works offline.';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceHoldMic => 'Tap the mic and speak';

  @override
  String get voiceStopListening => 'Stop listening';

  @override
  String get voiceStartListening => 'Start listening';

  @override
  String get voiceTapToStop => 'Tap again to stop';

  @override
  String get voiceTapToStart => 'Tap to start';

  @override
  String get voiceDidntCatch => 'Didn\'t catch that';

  @override
  String get voiceDidntCatchBody =>
      'Speak a little louder and closer to the phone, then try again.';

  @override
  String get voiceMicOffTitle => 'Microphone access is off';

  @override
  String get voiceMicOffBody =>
      'To translate by voice, allow microphone access in your phone settings. You can still type instead.';

  @override
  String get voiceFilipinoTitle => 'Filipino voice';

  @override
  String get voiceFilipinoInstall =>
      'To hear Filipino, install your phone\'s Filipino voice.';

  @override
  String get voiceInstall => 'Install';

  @override
  String get voiceLater => 'Later';

  @override
  String get voiceFilipinoMissing =>
      'Your phone has no Filipino voice yet. Install it in Settings.';

  @override
  String get voiceFilipinoNotReady =>
      'The Filipino voice isn\'t ready yet. Connect to the internet and try again.';

  @override
  String get histTapToOpen => 'Tap a translation to open it again.';

  @override
  String get histClearAll => 'Clear all';

  @override
  String get histEmptyTitle => 'No translations yet';

  @override
  String get histEmptyBody =>
      'Words and phrases you translate will show up here, so you can open them again.';

  @override
  String get savedEmptyTitle => 'No saved words yet';

  @override
  String get savedEmptyBody =>
      'Tap the bookmark on a translation to keep it here for practice.';

  @override
  String get savedCountOne => '1 saved word or phrase';

  @override
  String savedCountMany(Object count) {
    return '$count saved words and phrases';
  }

  @override
  String get histToday => 'Today';

  @override
  String get histYesterday => 'Yesterday';

  @override
  String histFromTo(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get histRemoveSaved => 'Remove from saved';

  @override
  String get histCleared => 'Translation history cleared';

  @override
  String get clearHistoryAction => 'Clear history';

  @override
  String get clearHistoryTitle => 'Clear translation history?';

  @override
  String get clearHistoryBody =>
      'This removes all your past translations from this phone. Your saved words stay.';

  @override
  String get clearHistoryKeep => 'Keep history';

  @override
  String get clearSavedAction => 'Clear saved words';

  @override
  String get clearSavedTitle => 'Clear saved words?';

  @override
  String get clearSavedBody =>
      'This removes every word you saved. Your lesson progress stays.';

  @override
  String get clearSavedKeep => 'Keep saved words';

  @override
  String get savedCleared => 'Saved words cleared';

  @override
  String get meTitle => 'Me';

  @override
  String get meAccount => 'Account';

  @override
  String get meEditProfile => 'Edit profile';

  @override
  String get meEditProfileSub => 'Name and avatar';

  @override
  String get meLanguageRow => 'Language';

  @override
  String get meSettings => 'Settings';

  @override
  String get meSettingsSub => 'Data, privacy, credits';

  @override
  String get meHelp => 'Help & Support';

  @override
  String get meHelpSub => 'FAQ, contact us';

  @override
  String get meLogOut => 'Log out';

  @override
  String get meLogOutTitle => 'Log out?';

  @override
  String get meLogOutBody =>
      'Your progress is saved. You can sign back in any time.';

  @override
  String get meStay => 'Stay';

  @override
  String get meProfileUpdated => 'Profile updated';

  @override
  String get meUser => 'User';

  @override
  String get editTitle => 'Edit profile';

  @override
  String get editChooseAvatar => 'Choose an avatar';

  @override
  String editAvatar(Object number) {
    return 'Avatar $number';
  }

  @override
  String get editUsernameEmpty => 'Username cannot be empty.';

  @override
  String get editUsernameShort => 'Username must be at least 3 characters.';

  @override
  String get editNewPassword => 'New password';

  @override
  String get editConfirmNewPassword => 'Confirm new password';

  @override
  String get editCurrentPassword => 'Current password (to confirm it\'s you)';

  @override
  String get editCurrentPasswordHint => 'Current password';

  @override
  String get editOnlyNeeded => 'Only needed to change your email or password.';

  @override
  String get editForgotPassword => 'Forgot your password?';

  @override
  String get editSaveChanges => 'Save changes';

  @override
  String get editDeleteAccount => 'Delete account';

  @override
  String get editWrongPassword => 'That password isn\'t right. Try again.';

  @override
  String get editNeedPassword =>
      'Enter your current password to change your email or password.';

  @override
  String get editNeedPasswordDelete =>
      'Enter your current password to delete your account.';

  @override
  String get editEmailInUse => 'This email is already in use.';

  @override
  String get editNoInternet => 'No internet. Connect and try again.';

  @override
  String get editTooManyTries => 'Too many tries. Wait a moment and try again.';

  @override
  String get editCouldntSave => 'Couldn\'t save. Please try again.';

  @override
  String get editCheckEmailTitle => 'Check your new email';

  @override
  String editCheckEmailBody(Object email) {
    return 'We sent a link to $email. Open it to finish changing your email. Until then, sign in with your old email.';
  }

  @override
  String get editResendLink => 'Resend link';

  @override
  String get editLinkSent => 'Link sent again';

  @override
  String get editDeleteTitle => 'Delete your account?';

  @override
  String get editDeleteBody =>
      'This removes your profile, progress, saved words and history. This can\'t be undone.';

  @override
  String get editDeleteKeep => 'Keep my account';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsCredits => 'Credits & licences';

  @override
  String get settingsCreditsSub => 'Voice, data, icons and fonts';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String settingsVersionValue(Object version) {
    return 'Hibalo $version';
  }

  @override
  String get privacyIntro =>
      'Hibalo was made by students of the Polytechnic University of the Philippines for a capstone study.';

  @override
  String get privacySaveLabel => 'What we save';

  @override
  String get privacySaveText =>
      'your username, email address and chosen avatar; when you signed up and last signed in; and your learning progress (lessons finished, quiz scores, XP and streak). These are saved in Google Firebase so your progress isn\'t lost.';

  @override
  String get privacyNotSaveLabel => 'What we don\'t save';

  @override
  String get privacyNotSaveText =>
      'the text you translate, the pictures you scan and your voice. Your translation history and saved words are kept only on your phone; uninstalling the app or clearing them in Settings deletes them. Translation and picture reading happen on your phone. Speech-to-text uses your phone\'s own speech service, which may follow Google\'s privacy terms. Speaking practice in lessons is kept on your phone only while you use it, then deleted.';

  @override
  String get privacyWhoLabel => 'Who can see your data';

  @override
  String get privacyWhoText =>
      'only you and the research team (app administrators). You can\'t see other users\' data, and they can\'t see yours.';

  @override
  String get privacyUseLabel => 'How your data is used';

  @override
  String get privacyUseText => 'only for this study. It is not sold or shared.';

  @override
  String get privacyDeleteLabel => 'Deleting your data';

  @override
  String get privacyDeleteText =>
      'you can delete your account and progress in Me › Edit profile, or ask the research team to do it.';

  @override
  String get privacyQuestionsLabel => 'Questions';

  @override
  String get privacyQuestionsText => 'contact the Hibalo research team.';

  @override
  String get creditsIntro =>
      'Made by the Hibalo team, Polytechnic University of the Philippines.';

  @override
  String get creditsVoiceLabel => 'Hiligaynon voice';

  @override
  String get creditsVoiceText =>
      'a fine-tuned version of Meta\'s MMS-TTS (VITS) model, licensed CC BY-NC 4.0 (non-commercial use only).';

  @override
  String get creditsDataLabel => 'Voice training data';

  @override
  String get creditsDataText =>
      'Philippine Languages Database (PLD), University of the Philippines Diliman Digital Signal Processing Laboratory (UP-DSP).';

  @override
  String get creditsTranslationLabel => 'Translation';

  @override
  String get creditsTranslationText =>
      'a MarianMT model trained by the Hibalo team, with help from the MADLAD-400 model and public Hiligaynon and Filipino texts.';

  @override
  String get creditsLessonsLabel => 'Lesson content';

  @override
  String get creditsLessonsText =>
      'written by the Hibalo team and checked against public references, including Omniglot, Iloilo Directory, Wikipedia, the ERIC Hiligaynon language packet (ED402758) and pinoydictionary.com.';

  @override
  String get creditsReadingLabel => 'Text reading';

  @override
  String get creditsReadingText =>
      'Google ML Kit. Font: Plus Jakarta Sans (SIL Open Font License). Icons: Material Symbols (Apache License 2.0).';

  @override
  String get creditsOpenSource => 'Open-source software';

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpFaqTitle => 'Frequently asked questions';

  @override
  String get helpQ1 => 'How do I translate a photo?';

  @override
  String get helpA1 =>
      'On Translate, tap the camera button, then take a photo or choose one from your gallery. Check the text Hibalo reads and fix any mistakes; the translation appears below.';

  @override
  String get helpQ2 => 'Does Hibalo work without internet?';

  @override
  String get helpA2 =>
      'Yes, after you sign in once. Translating, reading photos, the Hiligaynon voice and the lessons work offline. Your progress is saved to your account when you are back online. Speaking to translate uses your phone\'s speech service, which may need internet.';

  @override
  String get helpQ3 => 'What if a translation looks wrong?';

  @override
  String get helpA3 =>
      'Translations are made on your phone and may not be exact. Try a shorter sentence or check the spelling. For voice and photos, fix the text in the box, then tap Translate.';

  @override
  String get helpQ4 => 'How do I unlock the next lesson?';

  @override
  String get helpA4 =>
      'Pass the lesson\'s quiz with at least 80%. Lesson 2 unlocks when you finish Lesson 1.';

  @override
  String get helpQ5 => 'How do I earn XP?';

  @override
  String get helpA5 =>
      'Finish a lesson (20 XP), answer a quick check right (5 XP) or answer a quiz question right (10 XP). Each one gives XP only the first time.';

  @override
  String get helpQ6 => 'How do I change my avatar?';

  @override
  String get helpA6 =>
      'Go to Me, tap Edit profile, choose an avatar, then tap Save changes.';

  @override
  String get helpStillNeed => 'Still need help?';

  @override
  String helpEmailUs(Object email) {
    return 'Email us at $email';
  }

  @override
  String get helpCantOpenEmail => 'Couldn\'t open the email app.';

  @override
  String get adminGoodMorning => 'Good Morning';

  @override
  String get adminGoodAfternoon => 'Good Afternoon';

  @override
  String get adminGoodEvening => 'Good Evening';

  @override
  String get adminTitle => 'Admin Dashboard';

  @override
  String get adminManagement => 'Management';

  @override
  String get adminManageUsers => 'Manage Users';

  @override
  String get adminManageUsersSub => 'View, edit, promote or remove users';

  @override
  String get adminUsage => 'Usage Analytics';

  @override
  String get adminUsageSub => 'Daily & weekly active user breakdown';

  @override
  String get adminRecentSignups => 'Recent Signups';

  @override
  String get adminSwitchLight => 'Switch to Light';

  @override
  String get adminSwitchDark => 'Switch to Dark';

  @override
  String get adminRefresh => 'Refresh';

  @override
  String get adminLogout => 'Logout';

  @override
  String get adminTotalUsers => 'Total Users';

  @override
  String get adminAdmins => 'Admins';

  @override
  String get adminActiveToday => 'Active Today';

  @override
  String get adminActiveWeek => 'Active / Week';

  @override
  String get adminNoUsersYet => 'No users yet.';

  @override
  String get adminUnknown => 'Unknown';

  @override
  String get adminBadge => 'ADMIN';

  @override
  String get adminNoEmail => 'No email';

  @override
  String get adminLoading => 'Loading dashboard...';

  @override
  String get adminSearch => 'Search by name or email...';

  @override
  String get adminAll => 'All';

  @override
  String get adminNoUsersFound => 'No users found.';

  @override
  String get adminNoName => 'No Name';

  @override
  String get adminNoEmailCap => 'No Email';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminRemoveAdmin => 'Remove Admin';

  @override
  String get adminMakeAdmin => 'Make Admin';

  @override
  String get adminDelete => 'Delete';

  @override
  String get adminPromoted => 'User promoted to admin';

  @override
  String get adminDemoted => 'Admin role removed';

  @override
  String adminError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminEditUser => 'Edit User';

  @override
  String get adminName => 'Name';

  @override
  String get adminUserUpdated => 'User updated';

  @override
  String get adminDeleteUser => 'Delete User';

  @override
  String adminDeleteConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?\nThis cannot be undone.';
  }

  @override
  String get adminUserDeleted => 'User deleted';

  @override
  String get adminDailyActive => 'DAILY ACTIVE USERS — LAST 7 DAYS';

  @override
  String get adminBreakdown => 'BREAKDOWN';

  @override
  String adminActiveCount(Object count) {
    return '$count active';
  }

  @override
  String get adminEntry => 'Admin';

  @override
  String get settingsClearHistory => 'Clear translation history';
}
