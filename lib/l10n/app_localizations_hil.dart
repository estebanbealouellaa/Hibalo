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
  String get qtChoose => 'Pilia';

  @override
  String get qtListening => 'Pamati';

  @override
  String get qtFillBlank => 'Pun-a ang blangko';

  @override
  String get qtTypeAnswer => 'I-type ang sabat';

  @override
  String get qtBuildSentence => 'Buhata ang hambal';

  @override
  String get qtRealSituation => 'Matuod nga sitwasyon';

  @override
  String get qtMatchPairs => 'Ipares';

  @override
  String get qtDictation => 'Diktasyon';

  @override
  String get qtSpeaking => 'Paghambal';

  @override
  String get qtOpenAnswer => 'Hilway nga sabat';

  @override
  String get checkButton => 'Tan-awa';

  @override
  String get submitButton => 'Ipasa';

  @override
  String get q01Hint => 'Pilia ang husto nga sabat.';

  @override
  String get q02Hint => 'Pamati, dayon pilia ang sabat.';

  @override
  String get q03Title => 'Kompletoha ang hambal:';

  @override
  String get q03Hint => 'Pilia ang nadula nga tinaga.';

  @override
  String get q04TitleToHil => 'I-type ini sa Hiligaynon';

  @override
  String get q04TitleToFil => 'I-type ini sa Filipino';

  @override
  String get q04HintToHil => 'Isulat ang tinaga ukon prase sa Hiligaynon.';

  @override
  String get q04HintToFil => 'Isulat ang tinaga ukon prase sa Filipino.';

  @override
  String get yourAnswer => 'Ang sabat mo';

  @override
  String get q05Title => 'Buhata ang hambal';

  @override
  String get q05Hint => 'I-tap ang mga tinaga sa husto nga han-ay.';

  @override
  String get q06Title => 'Ano ang hambalon mo?';

  @override
  String get q08Hint => 'Pamati, dayon i-type sa Hiligaynon.';

  @override
  String get wordBankLabel => 'Mga tinaga (opsyonal)';

  @override
  String get q09Hint => 'Ensayuha ang paghambal sang prase. Wala sang iskor.';

  @override
  String get nativeSpeaker => 'Lumad nga humalambal';

  @override
  String get youLabel => 'Ikaw';

  @override
  String get recordTooltip => 'I-record';

  @override
  String get stopRecordingTooltip => 'Untati ang pag-record';

  @override
  String get micUnavailable => 'Indi magamit ang mic. Puede mo ini laktawan.';

  @override
  String charCount(int count, int max) {
    return '$count / $max ka letra';
  }

  @override
  String get feedbackTimeUp => 'Ubos na ang oras!';

  @override
  String get sampleAnswerTitle => 'Halimbawa nga sabat:';

  @override
  String get correctPairsLabel => 'Husto nga pares:';

  @override
  String get leaveQuizTooltip => 'Bayai ang pagsulit';

  @override
  String get leaveQuizTitle => 'Bayaan ang pagsulit?';

  @override
  String get leaveQuizText => 'Indi ma-save ang imo mga sabat.';

  @override
  String timeLeft(int seconds) {
    return '$seconds ka segundo pa';
  }

  @override
  String get backToLessons => 'Balik sa mga leksyon';

  @override
  String get filipinoName => 'Filipino';

  @override
  String get lessonCompleteTitle => 'Natapos ang leksyon!';

  @override
  String lessonCompleteLine(int number, String title) {
    return 'Natapos mo ang Leksyon $number: $title.';
  }

  @override
  String statXpPlus(int xp) {
    return '+$xp';
  }

  @override
  String get statXpLabel => 'XP';

  @override
  String get xpAlreadyEarned => 'XP · Nakuha na';

  @override
  String get newWordsLabel => 'Bag-o nga tinaga';

  @override
  String get lettersLabel => 'Letra';

  @override
  String lessonUnlockedChip(int number) {
    return 'Bukas na ang Leksyon $number';
  }

  @override
  String levelCompleteChip(String level) {
    return 'Natapos ang $level!';
  }

  @override
  String passToUnlockChip(int number) {
    return 'Ipasa ang pagsulit para mabuksan ang Leksyon $number';
  }

  @override
  String passToFinishLevelChip(String level) {
    return 'Ipasa ang pagsulit para matapos ang $level';
  }

  @override
  String get takeLessonQuiz => 'Sabton ang pagsulit';

  @override
  String continueToLesson(int number) {
    return 'Padayon sa Leksyon $number';
  }

  @override
  String quizScoreLine(int correct, int total) {
    return 'Husto ang $correct sa $total.';
  }

  @override
  String quizScoreLinePassed(int correct, int total) {
    return 'Husto ang $correct sa $total!';
  }

  @override
  String get xpEarnedLabel => 'Nakuha nga XP';

  @override
  String get accuracyLabel => 'Kahustuhan';

  @override
  String accuracyValue(int percent) {
    return '$percent%';
  }

  @override
  String get reviewAnswers => 'Repasuha ang mga sabat';

  @override
  String reviewQuestion(int number, String text) {
    return '$number. $text';
  }

  @override
  String reviewTyped(String type, String text) {
    return '$type: $text';
  }

  @override
  String get rvListening => 'Pamati';

  @override
  String get rvFillBlank => 'Pun-a ang blangko';

  @override
  String get rvType => 'I-type';

  @override
  String get rvBuild => 'Buhata';

  @override
  String get rvRealSituation => 'Matuod nga sitwasyon';

  @override
  String get rvMatchPairs => 'Ipares ang mga pares';

  @override
  String get rvDictation => 'Diktasyon';

  @override
  String get rvSpeaking => 'Pagyambot';

  @override
  String get rvOpenAnswer => 'Bukas nga sabat';

  @override
  String yourAnswerIs(String answer) {
    return 'Sabat mo: $answer';
  }

  @override
  String correctAnswerIs(String answer) {
    return 'Husto nga sabat: $answer';
  }

  @override
  String get timeUpAnswer => '(ubos na ang oras)';

  @override
  String pairsScore(int right, int total) {
    return '$right sa $total pares';
  }

  @override
  String get practiceTag => 'Pagbansay';

  @override
  String get practiceNote => 'Para sa pagbansay lang. Wala sang puntos.';

  @override
  String get commonCancel => 'Kanselaha';

  @override
  String get commonOpenSettings => 'Buksi ang Settings';

  @override
  String get commonNotNow => 'Dayon na lang';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSomethingWrong => 'May sala nga natabo. Tilawi liwat.';

  @override
  String get commonLoading => 'Nagaload';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonEnterEmail => 'Isulod ang email';

  @override
  String get commonEnterYourEmail => 'Isulod ang imo email';

  @override
  String get commonEmailLooksWrong => 'Daw indi husto ang email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonAtLeast6 => 'Indi magnubo sa 6 ka letra';

  @override
  String get commonPasswordsDontMatch => 'Indi pareho ang mga password';

  @override
  String get commonShowPassword => 'Ipakita ang password';

  @override
  String get commonHidePassword => 'Taguon ang password';

  @override
  String get commonProfilePicture => 'Litrato sa profile';

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
  String get commonListen => 'Pamatii';

  @override
  String get commonStop => 'Untati';

  @override
  String get commonSave => 'I-save';

  @override
  String get commonSaved => 'Na-save';

  @override
  String get commonTakePhoto => 'Magkuha sang litrato';

  @override
  String get commonChooseFromGallery => 'Magpili sa gallery';

  @override
  String get commonTypeInstead => 'Mag-type na lang';

  @override
  String get commonStartTranslating => 'Umpisahan ang pag-translate';

  @override
  String get navHome => 'Balay';

  @override
  String get navTranslate => 'Translate';

  @override
  String get navLearn => 'Magtuon';

  @override
  String get navMe => 'Ako';

  @override
  String get splashTagline => 'Hiligaynon · Filipino';

  @override
  String get welcomeEyebrow => 'HILIGAYNON';

  @override
  String get welcomeTitle => 'Ang mga tinaga\nnagahiusa sa aton.';

  @override
  String get welcomeBody =>
      'Tun-i ang adlaw-adlaw nga Hiligaynon, isa ka malip-ot nga istoryahanay kada tion.';

  @override
  String get welcomeCardTitle => 'Mag-umpisa sa isa ka hello.';

  @override
  String get welcomeCardBody =>
      'Mag-translate, mamati kag magtuon sa imo kaugalingon nga dasig.';

  @override
  String get welcomeGetStarted => 'Mag-umpisa';

  @override
  String get welcomeHaveAccount => 'May account na ako';

  @override
  String get onboard1Title => 'Maayong pag-abot sa Hibalo';

  @override
  String get onboard1Body =>
      'Mag-translate sa Hiligaynon kag Filipino, kag tun-an ang lenguahe samtang ginagamit mo ini.';

  @override
  String get onboard2Title => 'I-type, hambala, ukon kuhai sang litrato';

  @override
  String get onboard2Body =>
      'Mag-translate paagi sa pag-type, paghambal, ukon pagkuha sang litrato sang karatula ukon sulat.';

  @override
  String get onboard3Title => 'Magtuon sing diutay kada adlaw';

  @override
  String get onboard3Body =>
      'Malip-ot nga leksyon kag dalagan nga quiz. Mag-angkon sang XP kag padayuna ang imo streak.';

  @override
  String get onboardSkip => 'Laktawan';

  @override
  String get onboardNext => 'Sunod';

  @override
  String onboardPageOf(Object current, Object count) {
    return 'Pahina $current sang $count';
  }

  @override
  String get authNoInternetSignIn =>
      'Wala sang internet. Mag-connect para mag-sign in.';

  @override
  String get authNoInternetSignUp =>
      'Wala sang internet. Mag-connect para mag-sign up.';

  @override
  String get authWrongCredentials => 'Sala ang email ukon password.';

  @override
  String get authEmailInUse => 'Gingamit na ini nga email.';

  @override
  String get authWelcomeBack => 'Maayong pagbalik.';

  @override
  String get authWelcomeBackSub => 'Padayuna kon diin ka nag-untat.';

  @override
  String get authJoin => 'Mag-entra sa Hibalo.';

  @override
  String get authJoinSub =>
      'Maghimo sang account para ma-save ang imo leksyon, XP kag streak.';

  @override
  String get authUsername => 'Username';

  @override
  String get authEnterUsername => 'Isulod ang username';

  @override
  String get authEnterAUsername => 'Magsulod sang username';

  @override
  String get authAtLeast2 => 'Indi magnubo sa 2 ka letra';

  @override
  String get authEnterPassword => 'Isulod ang imo password';

  @override
  String get authForgotPassword => 'Nalipatan ang password?';

  @override
  String get authConfirmPassword => 'Kumpirmaha ang password';

  @override
  String get authReenterPassword => 'Isulod liwat ang password';

  @override
  String get authSigningIn => 'Nagasign in…';

  @override
  String get authCreatingAccount => 'Ginahimo ang account…';

  @override
  String get authSignIn => 'Mag-sign in';

  @override
  String get authCreateAccount => 'Maghimo sang account';

  @override
  String get authNewToHibalo => 'Bag-o sa Hibalo?';

  @override
  String get authHaveAccount => 'May account ka na?';

  @override
  String get authCreateAnAccount => 'Maghimo sang account';

  @override
  String get authStrengthTooWeak => 'Kaluya gid';

  @override
  String get authStrengthFair => 'Pwede na';

  @override
  String get authStrengthGood => 'Maayo';

  @override
  String get authStrengthStrong => 'Mabaskog';

  @override
  String get forgotNoInternet =>
      'Wala sang internet. Mag-connect para mapadala ang link.';

  @override
  String get forgotLinkSentAgain => 'Napadala liwat ang reset link';

  @override
  String get forgotCheckEmail => 'Tan-awa ang imo email';

  @override
  String get forgotTitle => 'Nalipatan mo ang imo password?';

  @override
  String forgotSentTo(Object email) {
    return 'Nagpadala kami sang reset link sa $email. Buksi ini sa sini nga telepono para maghimo sang bag-o nga password.';
  }

  @override
  String get forgotBody =>
      'Isulod ang imo email kag magapadala kami sang link para maghimo sang bag-o.';

  @override
  String get forgotSending => 'Ginapadala…';

  @override
  String get forgotSendLink => 'Ipadala ang reset link';

  @override
  String get forgotBackToSignIn => 'Balik sa sign in';

  @override
  String get forgotDidntGetIt => 'Wala nakabaton?';

  @override
  String get forgotRemembered => 'Nadumdoman mo na?';

  @override
  String get forgotResend => 'Ipadala liwat ang link';

  @override
  String get homeDayStreak => 'ADLAW NGA STREAK';

  @override
  String get homeLesson => 'LEKSYON';

  @override
  String get homeLessons => 'LEKSYON';

  @override
  String get homeXp => 'XP';

  @override
  String homeLessonTitle(Object number, Object title) {
    return 'Leksyon $number: $title';
  }

  @override
  String homePartsDone(Object done, Object total) {
    return '$done sa $total ka bahin';
  }

  @override
  String homePartOf(Object part, Object total) {
    return 'Bahin $part sang $total';
  }

  @override
  String homeStartLesson(Object number) {
    return 'Umpisahan ang Leksyon $number';
  }

  @override
  String get homeTakeQuiz => 'Sabton ang quiz';

  @override
  String homeLevelComplete(Object level) {
    return 'Natapos ang $level!';
  }

  @override
  String get homeAllComplete => 'Natapos na tanan!';

  @override
  String get homeEveryLessonDone => 'Natapos na ang tanan nga leksyon';

  @override
  String get homeReviewLessons => 'Balikan ang mga leksyon';

  @override
  String homeLevelChip(Object level, Object number) {
    return '$level · Lebel $number';
  }

  @override
  String get homePhraseOfDay => 'Prase sang adlaw';

  @override
  String get langChooseTitle => 'Pilia ang imo lenguahe';

  @override
  String get langContinue => 'Padayon';

  @override
  String get langTitle => 'Lenguahe';

  @override
  String get langAppLanguage => 'Lenguahe sang app';

  @override
  String get langNote =>
      'Ilisan dayon ang mga menu kag button. Ang mga leksyon magapabilin sa Hiligaynon nga may kahulugan sa Filipino.';

  @override
  String langChangedTo(Object language) {
    return 'Gin-ilisan ang lenguahe sa $language';
  }

  @override
  String get trTitle => 'Translate';

  @override
  String get trHistory => 'Kasaysayan';

  @override
  String get trTypeHere => 'Mag-type ukon mag-paste sang teksto diri';

  @override
  String trFromTo(Object from, Object to) {
    return 'Halin $from pakadto $to';
  }

  @override
  String get trSwap => 'Ilisan ang lenguahe';

  @override
  String get trClearText => 'Panason ang teksto';

  @override
  String trCharacters(Object count) {
    return '$count ka letra';
  }

  @override
  String get trSpeak => 'Maghambal';

  @override
  String get trScanPhoto => 'I-scan ang teksto sa litrato';

  @override
  String get trTranslating => 'Gina-translate…';

  @override
  String get trTranslatingShort => 'Gina-translate';

  @override
  String get trTranslateButton => 'I-translate';

  @override
  String get trPreparingVoice => 'Ginahanda ang tingog';

  @override
  String get trCopy => 'Kopyaha';

  @override
  String get trCopied => 'Nakopya';

  @override
  String get trShare => 'I-share';

  @override
  String get trFromVoice => 'Halin sa imo tingog · tan-awa kon may sala';

  @override
  String get trSpeakAgain => 'Maghambal liwat';

  @override
  String get trFromPhoto => 'Halin sa imo litrato · tan-awa kon may sala';

  @override
  String get trScanAgain => 'I-scan liwat';

  @override
  String get camAccessOffTitle => 'Naka-off ang access sa camera';

  @override
  String get camAccessOffBody =>
      'Para magkuha sang litrato, tugoti ang camera sa settings sang imo telepono. Pwede ka man gihapon magpili sang litrato sa gallery.';

  @override
  String get camNoTextTitle => 'Wala sang teksto nga nakita';

  @override
  String get camNoTextBody =>
      'Tilawi ang mas malinaw nga litrato nga may maayo nga suga, kag dapat tadlong kag malapit ang mga tinaga.';

  @override
  String get camCouldntReadTitle => 'Indi mabasa ang litrato';

  @override
  String get camCouldntReadBody =>
      'May sala nga natabo. Tilawi liwat ukon magpili sang iban nga litrato.';

  @override
  String get camChooseAnother => 'Magpili sang iban';

  @override
  String get camSheetBody =>
      'Ginabasa sang Hibalo ang mga tinaga sa litrato kag gina-translate ini.';

  @override
  String get camUseCamera => 'Gamita ang imo camera';

  @override
  String get camPickExisting => 'Magpili sang litrato nga ara na sa imo';

  @override
  String get camReading => 'Ginabasa ang teksto…';

  @override
  String get camTakesSeconds =>
      'Pila lang ka segundo ini kag nagaandar bisan wala internet.';

  @override
  String get voiceListening => 'Nagapamati…';

  @override
  String get voiceHoldMic => 'Pinduta ang mic kag maghambal';

  @override
  String get voiceStopListening => 'Untati ang pagpamati';

  @override
  String get voiceStartListening => 'Umpisahan ang pagpamati';

  @override
  String get voiceTapToStop => 'I-tap liwat para mag-untat';

  @override
  String get voiceTapToStart => 'I-tap para mag-umpisa';

  @override
  String get voiceDidntCatch => 'Wala ko nabatian sing maayo';

  @override
  String get voiceDidntCatchBody =>
      'Maghambal sing mas mabaskog kag mas malapit sa telepono, dayon tilawi liwat.';

  @override
  String get voiceMicOffTitle => 'Naka-off ang access sa mikropono';

  @override
  String get voiceMicOffBody =>
      'Para mag-translate paagi sa tingog, tugoti ang mikropono sa settings sang imo telepono. Pwede ka man gihapon mag-type.';

  @override
  String get voiceFilipinoTitle => 'Filipino voice';

  @override
  String get voiceFilipinoInstall =>
      'Para mabatian ang Filipino, i-install ang Filipino voice sang imo telepono.';

  @override
  String get voiceInstall => 'I-install';

  @override
  String get voiceLater => 'Dayon na lang';

  @override
  String get voiceFilipinoMissing =>
      'Wala pa sang Filipino voice sa telepono. I-install sa Settings.';

  @override
  String get voiceFilipinoNotReady =>
      'Indi pa handa ang Filipino voice. Mag-connect sa internet kag tilawi liwat.';

  @override
  String get histTapToOpen => 'I-tap ang translation para buksan liwat.';

  @override
  String get histClearAll => 'Panason tanan';

  @override
  String get histEmptyTitle => 'Wala pa sang translation';

  @override
  String get histEmptyBody =>
      'Diri makita ang mga tinaga kag prase nga gin-translate mo, para mabuksan mo liwat.';

  @override
  String get savedEmptyTitle => 'Wala pa sang na-save nga tinaga';

  @override
  String get savedEmptyBody =>
      'I-tap ang bookmark sa translation para itago ini diri kag ensayuhan.';

  @override
  String get savedCountOne => '1 ka na-save nga tinaga ukon prase';

  @override
  String savedCountMany(Object count) {
    return '$count ka na-save nga tinaga kag prase';
  }

  @override
  String get histToday => 'Subong';

  @override
  String get histYesterday => 'Kahapon';

  @override
  String histFromTo(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get histRemoveSaved => 'Kuhaa sa na-save';

  @override
  String get histCleared => 'Napanas ang kasaysayan sang translation';

  @override
  String get clearHistoryAction => 'Panason ang kasaysayan';

  @override
  String get clearHistoryTitle => 'Panason ang kasaysayan sang translation?';

  @override
  String get clearHistoryBody =>
      'Mapanas ang tanan mo nga nauna nga translation sa sini nga telepono. Magapabilin ang imo na-save nga mga tinaga.';

  @override
  String get clearHistoryKeep => 'Bilin ang kasaysayan';

  @override
  String get clearSavedAction => 'Panason ang na-save nga tinaga';

  @override
  String get clearSavedTitle => 'Panason ang na-save nga tinaga?';

  @override
  String get clearSavedBody =>
      'Mapanas ang tanan nga tinaga nga gin-save mo. Magapabilin ang imo progreso sa leksyon.';

  @override
  String get clearSavedKeep => 'Bilin ang na-save';

  @override
  String get savedCleared => 'Napanas ang na-save nga tinaga';

  @override
  String get meTitle => 'Ako';

  @override
  String get meAccount => 'Account';

  @override
  String get meEditProfile => 'I-edit ang profile';

  @override
  String get meEditProfileSub => 'Ngalan kag avatar';

  @override
  String get meLanguageRow => 'Lenguahe';

  @override
  String get meSettings => 'Mga Setting';

  @override
  String get meSettingsSub => 'Data, privacy, credits';

  @override
  String get meHelp => 'Bulig kag Suporta';

  @override
  String get meHelpSub => 'FAQ, kontaka kami';

  @override
  String get meLogOut => 'Mag-log out';

  @override
  String get meLogOutTitle => 'Mag-log out?';

  @override
  String get meLogOutBody =>
      'Na-save ang imo progreso. Pwede ka mag-sign in liwat bisan san-o.';

  @override
  String get meStay => 'Pabilin';

  @override
  String get meProfileUpdated => 'Na-update ang profile';

  @override
  String get meUser => 'User';

  @override
  String get editTitle => 'I-edit ang profile';

  @override
  String get editChooseAvatar => 'Magpili sang avatar';

  @override
  String editAvatar(Object number) {
    return 'Avatar $number';
  }

  @override
  String get editUsernameEmpty => 'Indi pwede nga wala sulod ang username.';

  @override
  String get editUsernameShort =>
      'Dapat indi magnubo sa 3 ka letra ang username.';

  @override
  String get editNewPassword => 'Bag-o nga password';

  @override
  String get editConfirmNewPassword => 'Kumpirmaha ang bag-o nga password';

  @override
  String get editCurrentPassword =>
      'Karon nga password (para makumpirma nga ikaw ini)';

  @override
  String get editCurrentPasswordHint => 'Karon nga password';

  @override
  String get editOnlyNeeded =>
      'Kinahanglan lang kon ilisan ang email ukon password.';

  @override
  String get editForgotPassword => 'Nalipatan mo ang imo password?';

  @override
  String get editSaveChanges => 'I-save ang mga pagbag-o';

  @override
  String get editDeleteAccount => 'Panason ang account';

  @override
  String get editWrongPassword => 'Sala ina nga password. Tilawi liwat.';

  @override
  String get editNeedPassword =>
      'Isulod ang karon nga password para ilisan ang email ukon password.';

  @override
  String get editNeedPasswordDelete =>
      'Isulod ang karon nga password para mapanas ang account.';

  @override
  String get editEmailInUse => 'Gingamit na ini nga email.';

  @override
  String get editNoInternet =>
      'Wala sang internet. Mag-connect kag tilawi liwat.';

  @override
  String get editTooManyTries =>
      'Madamo na nga tilaw. Maghulat anay kag tilawi liwat.';

  @override
  String get editCouldntSave => 'Indi ma-save. Tilawi liwat.';

  @override
  String get editCheckEmailTitle => 'Tan-awa ang imo bag-o nga email';

  @override
  String editCheckEmailBody(Object email) {
    return 'Nagpadala kami sang link sa $email. Buksi ini para matapos ang pag-ilis sang email. Asta sina, mag-sign in gamit ang daan nga email.';
  }

  @override
  String get editResendLink => 'Ipadala liwat ang link';

  @override
  String get editLinkSent => 'Napadala liwat ang link';

  @override
  String get editDeleteTitle => 'Panason ang imo account?';

  @override
  String get editDeleteBody =>
      'Mapanas ang imo profile, progreso, na-save nga tinaga kag kasaysayan. Indi na ini mabalik.';

  @override
  String get editDeleteKeep => 'Bilin ang akon account';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'Parte sa app';

  @override
  String get settingsPrivacy => 'Polisiya sa privacy';

  @override
  String get settingsCredits => 'Credits kag lisensya';

  @override
  String get settingsCreditsSub => 'Tingog, data, icon kag font';

  @override
  String get settingsAppVersion => 'Bersyon sang app';

  @override
  String settingsVersionValue(Object version) {
    return 'Hibalo $version';
  }

  @override
  String get privacyIntro =>
      'Ginhimo ang Hibalo sang mga estudyante sang Polytechnic University of the Philippines para sa isa ka capstone study.';

  @override
  String get privacySaveLabel => 'Ano ang ginasave namon';

  @override
  String get privacySaveText =>
      'ang imo username, email address kag ginpili nga avatar; san-o ka nag-sign up kag katapusan nga nag-sign in; kag ang imo progreso sa pagtuon (mga natapos nga leksyon, iskor sa quiz, XP kag streak). Na-save ini sa Google Firebase para indi madula ang imo progreso.';

  @override
  String get privacyNotSaveLabel => 'Ano ang wala namon ginasave';

  @override
  String get privacyNotSaveText =>
      'ang teksto nga gina-translate mo, ang mga litrato nga gina-scan mo kag ang imo tingog. Ara lang sa imo telepono ang kasaysayan sang translation kag na-save nga tinaga; mapanas ini kon i-uninstall ang app ukon panason sa Settings. Sa imo telepono ginahimo ang pag-translate kag pagbasa sang litrato. Ang speech-to-text nagagamit sang kaugalingon nga speech service sang telepono, nga basi magsunod sa privacy terms sang Google. Ang ensayo sa paghambal sa mga leksyon ara lang sa imo telepono samtang ginagamit, dayon ginapanas.';

  @override
  String get privacyWhoLabel => 'Sin-o ang makakita sang imo data';

  @override
  String get privacyWhoText =>
      'ikaw lang kag ang research team (mga administrator sang app). Indi mo makita ang data sang iban nga user, kag indi man nila makita ang imo.';

  @override
  String get privacyUseLabel => 'Paano ginagamit ang imo data';

  @override
  String get privacyUseText =>
      'para lang sa sini nga pagtuon. Indi ini ginabaligya ukon ginapaambit.';

  @override
  String get privacyDeleteLabel => 'Pagpanas sang imo data';

  @override
  String get privacyDeleteText =>
      'pwede mo panason ang imo account kag progreso sa Ako › I-edit ang profile, ukon pangabayon ang research team nga himuon ini.';

  @override
  String get privacyQuestionsLabel => 'Mga pamangkot';

  @override
  String get privacyQuestionsText => 'kontaka ang Hibalo research team.';

  @override
  String get creditsIntro =>
      'Ginhimo sang Hibalo team, Polytechnic University of the Philippines.';

  @override
  String get creditsVoiceLabel => 'Tingog nga Hiligaynon';

  @override
  String get creditsVoiceText =>
      'isa ka fine-tuned nga bersyon sang MMS-TTS (VITS) model sang Meta, may lisensya nga CC BY-NC 4.0 (para lang sa indi komersyal nga gamit).';

  @override
  String get creditsDataLabel => 'Data sa pag-ensayo sang tingog';

  @override
  String get creditsDataText =>
      'Philippine Languages Database (PLD), University of the Philippines Diliman Digital Signal Processing Laboratory (UP-DSP).';

  @override
  String get creditsTranslationLabel => 'Pag-translate';

  @override
  String get creditsTranslationText =>
      'isa ka MarianMT model nga gin-ensayo sang Hibalo team, sa bulig sang MADLAD-400 model kag mga publiko nga teksto sa Hiligaynon kag Filipino.';

  @override
  String get creditsLessonsLabel => 'Sulod sang leksyon';

  @override
  String get creditsLessonsText =>
      'ginsulat sang Hibalo team kag gintsek gamit ang mga publiko nga reperensya, lakip ang Omniglot, Iloilo Directory, Wikipedia, ang ERIC Hiligaynon language packet (ED402758) kag pinoydictionary.com.';

  @override
  String get creditsReadingLabel => 'Pagbasa sang teksto';

  @override
  String get creditsReadingText =>
      'Google ML Kit. Font: Plus Jakarta Sans (SIL Open Font License). Mga icon: Material Symbols (Apache License 2.0).';

  @override
  String get creditsOpenSource => 'Open-source nga software';

  @override
  String get helpTitle => 'Bulig kag Suporta';

  @override
  String get helpFaqTitle => 'Mga pirme ginapamangkot';

  @override
  String get helpQ1 => 'Paano mag-translate sang litrato?';

  @override
  String get helpA1 =>
      'Sa Translate, i-tap ang camera, dayon magkuha sang litrato ukon magpili sa gallery. Tan-awa ang teksto nga nabasa sang Hibalo, dayon i-tap ang I-translate.';

  @override
  String get helpQ2 => 'Nagaandar bala ang Hibalo bisan wala internet?';

  @override
  String get helpA2 =>
      'Huo, pagkatapos mo mag-sign in sing isa ka beses. Nagaandar bisan wala internet ang pag-translate, pagbasa sang litrato, tingog nga Hiligaynon kag mga leksyon. Ma-save sa imo account ang progreso kon online ka na liwat. Ang pag-translate paagi sa tingog nagagamit sang speech service sang telepono, nga basi magkinahanglan sang internet.';

  @override
  String get helpQ3 => 'Paano kon daw sala ang translation?';

  @override
  String get helpA3 =>
      'Ginahimo sa imo telepono ang translation kag basi indi eksakto. Tilawi ang mas malip-ot nga hambal ukon tan-awa ang spelling. Para sa tingog kag litrato, ayuha ang teksto sa kahon, dayon i-tap ang I-translate.';

  @override
  String get helpQ4 => 'Paano mabuksan ang masunod nga leksyon?';

  @override
  String get helpA4 =>
      'Ipasa ang quiz sang leksyon nga indi magnubo sa 80%. Mabuksan ang Leksyon 2 kon matapos mo ang Leksyon 1.';

  @override
  String get helpQ5 => 'Paano mag-angkon sang XP?';

  @override
  String get helpA5 =>
      'Tapusa ang isa ka leksyon (20 XP), sabta sing husto ang dali nga pamangkot (5 XP) ukon ang pamangkot sa quiz (10 XP). Isa lang ka beses nagahatag sang XP ang kada isa.';

  @override
  String get helpQ6 => 'Paano ilisan ang akon avatar?';

  @override
  String get helpA6 =>
      'Kadto sa Ako, i-tap ang I-edit ang profile, magpili sang avatar, dayon i-tap ang I-save ang mga pagbag-o.';

  @override
  String get helpStillNeed => 'Kinahanglan pa sang bulig?';

  @override
  String helpEmailUs(Object email) {
    return 'Mag-email sa amon sa $email';
  }

  @override
  String get helpCantOpenEmail => 'Indi mabuksan ang email app.';

  @override
  String get adminGoodMorning => 'Maayong Aga';

  @override
  String get adminGoodAfternoon => 'Maayong Hapon';

  @override
  String get adminGoodEvening => 'Maayong Gab-i';

  @override
  String get adminTitle => 'Admin Dashboard';

  @override
  String get adminManagement => 'Pagdumala';

  @override
  String get adminManageUsers => 'Dumalaha ang mga User';

  @override
  String get adminManageUsersSub =>
      'Tan-awa, i-edit, i-promote ukon kuhaa ang mga user';

  @override
  String get adminUsage => 'Analytics sang paggamit';

  @override
  String get adminUsageSub => 'Aktibo nga user kada adlaw kag semana';

  @override
  String get adminRecentSignups => 'Mga bag-o nga nag-sign up';

  @override
  String get adminSwitchLight => 'Himuon nga Light';

  @override
  String get adminSwitchDark => 'Himuon nga Dark';

  @override
  String get adminRefresh => 'I-refresh';

  @override
  String get adminLogout => 'Mag-log out';

  @override
  String get adminTotalUsers => 'Kabilugan nga User';

  @override
  String get adminAdmins => 'Mga Admin';

  @override
  String get adminActiveToday => 'Aktibo Subong';

  @override
  String get adminActiveWeek => 'Aktibo / Semana';

  @override
  String get adminNoUsersYet => 'Wala pa sang user.';

  @override
  String get adminUnknown => 'Indi mahibaluan';

  @override
  String get adminBadge => 'ADMIN';

  @override
  String get adminNoEmail => 'Wala sang email';

  @override
  String get adminLoading => 'Ginaload ang dashboard...';

  @override
  String get adminSearch => 'Pangita paagi sa ngalan ukon email...';

  @override
  String get adminAll => 'Tanan';

  @override
  String get adminNoUsersFound => 'Wala sang user nga nakita.';

  @override
  String get adminNoName => 'Wala sang Ngalan';

  @override
  String get adminNoEmailCap => 'Wala sang Email';

  @override
  String get adminEdit => 'I-edit';

  @override
  String get adminRemoveAdmin => 'Kuhaa bilang Admin';

  @override
  String get adminMakeAdmin => 'Himuon nga Admin';

  @override
  String get adminDelete => 'Panason';

  @override
  String get adminPromoted => 'Ginhimo nga admin ang user';

  @override
  String get adminDemoted => 'Ginkuha ang admin role';

  @override
  String adminError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminEditUser => 'I-edit ang User';

  @override
  String get adminName => 'Ngalan';

  @override
  String get adminUserUpdated => 'Na-update ang user';

  @override
  String get adminDeleteUser => 'Panason ang User';

  @override
  String adminDeleteConfirm(Object name) {
    return 'Sigurado ka nga panason si \"$name\"?\nIndi na ini mabalik.';
  }

  @override
  String get adminUserDeleted => 'Napanas ang user';

  @override
  String get adminDailyActive =>
      'AKTIBO NGA USER KADA ADLAW — KATAPUSAN NGA 7 KA ADLAW';

  @override
  String get adminBreakdown => 'DETALYE';

  @override
  String adminActiveCount(Object count) {
    return '$count aktibo';
  }

  @override
  String get adminEntry => 'Admin';

  @override
  String get settingsClearHistory => 'Panason ang kasaysayan sang translation';
}
