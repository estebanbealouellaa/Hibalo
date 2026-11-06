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
  String get learnComingSoon => 'Malapit nang magkaroon ng mga aralin';

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
    return 'Sagutan ang pagsusulit para mabuksan ang Aralin $next';
  }

  @override
  String rowQuizPendingLast(String level) {
    return 'Sagutan ang pagsusulit para matapos ang $level';
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
  String get checkButton => 'I-check';

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
  String get wordBankLabel => 'Mga pagpipiliang salita (opsyonal)';

  @override
  String get q09Hint => 'Sanayin ang pagsabi ng parirala. Walang iskor.';

  @override
  String get nativeSpeaker => 'Tagapagsalita ng Hiligaynon';

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
    return '$count / $max na character';
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
  String get backToLessons => 'Bumalik sa mga aralin';

  @override
  String get filipinoName => 'Filipino';

  @override
  String get lessonCompleteTitle => 'Tapos ang aralin!';

  @override
  String lessonCompleteLine(int number, String title) {
    return 'Natapos mo ang Aralin $number: $title.';
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
  String get newWordsLabel => 'Bagong salita';

  @override
  String get lettersLabel => 'Titik';

  @override
  String lessonUnlockedChip(int number) {
    return 'Bukas na ang Aralin $number';
  }

  @override
  String levelCompleteChip(String level) {
    return 'Tapos ang $level!';
  }

  @override
  String passToUnlockChip(int number) {
    return 'Ipasa ang pagsusulit para mabuksan ang Aralin $number';
  }

  @override
  String passToFinishLevelChip(String level) {
    return 'Ipasa ang pagsusulit para matapos ang $level';
  }

  @override
  String get takeLessonQuiz => 'Sagutan ang pagsusulit';

  @override
  String continueToLesson(int number) {
    return 'Tumuloy sa Aralin $number';
  }

  @override
  String quizScoreLine(int correct, int total) {
    return 'Tama ang $correct sa $total.';
  }

  @override
  String quizScoreLinePassed(int correct, int total) {
    return 'Tama ang $correct sa $total!';
  }

  @override
  String get xpEarnedLabel => 'Nakuhang XP';

  @override
  String get accuracyLabel => 'Tamang sagot';

  @override
  String accuracyValue(int percent) {
    return '$percent%';
  }

  @override
  String get reviewAnswers => 'Balikan ang mga sagot';

  @override
  String reviewQuestion(int number, String text) {
    return '$number. $text';
  }

  @override
  String reviewTyped(String type, String text) {
    return '$type: $text';
  }

  @override
  String get rvListening => 'Pakikinig';

  @override
  String get rvFillBlank => 'Punan ang patlang';

  @override
  String get rvType => 'I-type';

  @override
  String get rvBuild => 'Buuin';

  @override
  String get rvRealSituation => 'Totoong sitwasyon';

  @override
  String get rvMatchPairs => 'Pagtapatin ang magkapares';

  @override
  String get rvDictation => 'Diktasyon';

  @override
  String get rvSpeaking => 'Pagsasalita';

  @override
  String get rvOpenAnswer => 'Malayang sagot';

  @override
  String yourAnswerIs(String answer) {
    return 'Sagot mo: $answer';
  }

  @override
  String correctAnswerIs(String answer) {
    return 'Tamang sagot: $answer';
  }

  @override
  String get timeUpAnswer => '(ubos na ang oras)';

  @override
  String pairsScore(int right, int total) {
    return '$right sa $total pares';
  }

  @override
  String get practiceTag => 'Pagsasanay';

  @override
  String get practiceNote => 'Para sa pagsasanay lang. Walang iskor.';

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get commonOpenSettings => 'Buksan ang Settings';

  @override
  String get commonNotNow => 'Mamaya na';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSomethingWrong => 'May nangyaring mali. Subukan ulit.';

  @override
  String get commonLoading => 'Naglo-load';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonEnterEmail => 'Ilagay ang email';

  @override
  String get commonEnterYourEmail => 'Ilagay ang iyong email';

  @override
  String get commonEmailLooksWrong => 'Mukhang mali ang email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonAtLeast6 => 'Hindi bababa sa 6 na character';

  @override
  String get commonPasswordsDontMatch => 'Hindi magkapareho ang mga password';

  @override
  String get commonShowPassword => 'Ipakita ang password';

  @override
  String get commonHidePassword => 'Itago ang password';

  @override
  String get commonProfilePicture => 'Larawan sa profile';

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
  String get commonListen => 'Pakinggan';

  @override
  String get commonStop => 'Itigil';

  @override
  String get commonSave => 'I-save';

  @override
  String get commonSaved => 'Naka-save';

  @override
  String get commonTakePhoto => 'Kumuha ng litrato';

  @override
  String get commonChooseFromGallery => 'Pumili sa gallery';

  @override
  String get commonTypeInstead => 'Mag-type na lang';

  @override
  String get commonStartTranslating => 'Magsimulang magsalin';

  @override
  String get navHome => 'Home';

  @override
  String get navTranslate => 'Isalin';

  @override
  String get navLearn => 'Matuto';

  @override
  String get navMe => 'Ako';

  @override
  String get splashTagline => 'Hiligaynon · Filipino';

  @override
  String get welcomeEyebrow => 'HILIGAYNON';

  @override
  String get welcomeTitle => 'Pinaglalapit tayo\nng mga salita.';

  @override
  String get welcomeBody =>
      'Matuto ng pang-araw-araw na Hiligaynon, isang maikling usapan sa bawat pagkakataon.';

  @override
  String get welcomeCardTitle => 'Magsimula sa isang hello.';

  @override
  String get welcomeCardBody =>
      'Magsalin, makinig at matuto sa sarili mong bilis.';

  @override
  String get welcomeGetStarted => 'Magsimula';

  @override
  String get welcomeHaveAccount => 'May account na ako';

  @override
  String get onboard1Title => 'Maligayang pagdating sa Hibalo';

  @override
  String get onboard1Body =>
      'Magsalin sa pagitan ng Hiligaynon at Filipino, at matuto ng wika habang ginagamit ito.';

  @override
  String get onboard2Title => 'I-type, sabihin, o kunan ng litrato';

  @override
  String get onboard2Body =>
      'Magsalin sa pag-type, pagsasalita, o pagkuha ng litrato ng karatula o sulat.';

  @override
  String get onboard3Title => 'Matuto nang kaunti araw-araw';

  @override
  String get onboard3Body =>
      'Maiikling aralin at mabilis na pagsusulit. Kumita ng XP at panatilihin ang iyong streak.';

  @override
  String get onboardSkip => 'Laktawan';

  @override
  String get onboardNext => 'Susunod';

  @override
  String onboardPageOf(Object current, Object count) {
    return 'Pahina $current ng $count';
  }

  @override
  String get authNoInternetSignIn =>
      'Walang internet. Kumonekta para mag-sign in.';

  @override
  String get authNoInternetSignUp =>
      'Walang internet. Kumonekta para mag-sign up.';

  @override
  String get authWrongCredentials => 'Mali ang email o password.';

  @override
  String get authEmailInUse => 'Ginagamit na ang email na ito.';

  @override
  String get authWelcomeBack => 'Maligayang pagbabalik.';

  @override
  String get authWelcomeBackSub => 'Ituloy kung saan ka huminto.';

  @override
  String get authJoin => 'Sumali sa Hibalo.';

  @override
  String get authJoinSub =>
      'Gumawa ng account para ma-save ang iyong aralin, XP at streak.';

  @override
  String get authUsername => 'Username';

  @override
  String get authEnterUsername => 'Ilagay ang username';

  @override
  String get authEnterAUsername => 'Maglagay ng username';

  @override
  String get authAtLeast2 => 'Hindi bababa sa 2 character';

  @override
  String get authEnterPassword => 'Ilagay ang iyong password';

  @override
  String get authForgotPassword => 'Nakalimutan ang password?';

  @override
  String get authConfirmPassword => 'Kumpirmahin ang password';

  @override
  String get authReenterPassword => 'Ilagay muli ang password';

  @override
  String get authSigningIn => 'Nagsa-sign in…';

  @override
  String get authCreatingAccount => 'Ginagawa ang account…';

  @override
  String get authSignIn => 'Mag-sign in';

  @override
  String get authCreateAccount => 'Gumawa ng account';

  @override
  String get authNewToHibalo => 'Bago sa Hibalo?';

  @override
  String get authHaveAccount => 'May account ka na?';

  @override
  String get authCreateAnAccount => 'Gumawa ng account';

  @override
  String get authStrengthTooWeak => 'Masyadong mahina';

  @override
  String get authStrengthFair => 'Puwede na';

  @override
  String get authStrengthGood => 'Maayos';

  @override
  String get authStrengthStrong => 'Matibay';

  @override
  String get forgotNoInternet =>
      'Walang internet. Kumonekta para maipadala ang link.';

  @override
  String get forgotLinkSentAgain => 'Naipadala ulit ang reset link';

  @override
  String get forgotCheckEmail => 'Tingnan ang iyong email';

  @override
  String get forgotTitle => 'Nakalimutan ang iyong password?';

  @override
  String forgotSentTo(Object email) {
    return 'Nagpadala kami ng reset link sa $email. Buksan ito sa teleponong ito para gumawa ng bagong password.';
  }

  @override
  String get forgotBody =>
      'Ilagay ang iyong email at magpapadala kami ng link para gumawa ng bago.';

  @override
  String get forgotSending => 'Ipinapadala…';

  @override
  String get forgotSendLink => 'Ipadala ang reset link';

  @override
  String get forgotBackToSignIn => 'Bumalik sa sign in';

  @override
  String get forgotDidntGetIt => 'Hindi natanggap?';

  @override
  String get forgotRemembered => 'Naalala mo na?';

  @override
  String get forgotResend => 'Ipadala ulit ang link';

  @override
  String get homeDayStreak => 'ARAW';

  @override
  String get homeLesson => 'ARALIN';

  @override
  String get homeLessons => 'ARALIN';

  @override
  String get homeXp => 'XP';

  @override
  String homeLessonTitle(Object number, Object title) {
    return 'Aralin $number: $title';
  }

  @override
  String homePartsDone(Object done, Object total) {
    return '$done sa $total bahagi';
  }

  @override
  String homePartOf(Object part, Object total) {
    return 'Bahagi $part ng $total';
  }

  @override
  String homeStartLesson(Object number) {
    return 'Simulan ang Aralin $number';
  }

  @override
  String get homeTakeQuiz => 'Sagutan ang pagsusulit';

  @override
  String homeLevelComplete(Object level) {
    return 'Tapos ang $level!';
  }

  @override
  String get homeAllComplete => 'Tapos na lahat!';

  @override
  String get homeEveryLessonDone => 'Tapos na ang lahat ng aralin';

  @override
  String get homeReviewLessons => 'Balikan ang mga aralin';

  @override
  String homeLevelChip(Object level, Object number) {
    return '$level · Antas $number';
  }

  @override
  String get homePhraseOfDay => 'Parirala ng araw';

  @override
  String get langChooseTitle => 'Piliin ang iyong wika';

  @override
  String get langContinue => 'Magpatuloy';

  @override
  String get langTitle => 'Wika';

  @override
  String get langAppLanguage => 'Wika ng app';

  @override
  String get langNote =>
      'Agad nitong papalitan ang mga menu at button. Mananatili sa Hiligaynon ang mga aralin, may kahulugan sa Filipino.';

  @override
  String langChangedTo(Object language) {
    return 'Pinalitan ang wika sa $language';
  }

  @override
  String get trTitle => 'Isalin';

  @override
  String get trHistory => 'History';

  @override
  String get trTypeHere => 'Mag-type o mag-paste ng teksto dito';

  @override
  String trFromTo(Object from, Object to) {
    return 'Mula $from papuntang $to';
  }

  @override
  String get trSwap => 'Pagpalitin ang wika';

  @override
  String get trClearText => 'Burahin ang teksto';

  @override
  String trCharacters(Object count) {
    return '$count na character';
  }

  @override
  String get trSpeak => 'Magsalita';

  @override
  String get trScanPhoto => 'I-scan ang teksto sa litrato';

  @override
  String get trTranslating => 'Isinasalin…';

  @override
  String get trTranslatingShort => 'Isinasalin';

  @override
  String get trTranslateButton => 'Isalin';

  @override
  String get trPreparingVoice => 'Inihahanda ang boses';

  @override
  String get trCopy => 'Kopyahin';

  @override
  String get trCopied => 'Nakopya';

  @override
  String get trShare => 'Ibahagi';

  @override
  String get trFromVoice => 'Mula sa iyong boses · tingnan kung may mali';

  @override
  String get trSpeakAgain => 'Magsalita ulit';

  @override
  String get trFromPhoto => 'Mula sa iyong litrato · tingnan kung may mali';

  @override
  String get trScanAgain => 'I-scan ulit';

  @override
  String get camAccessOffTitle => 'Naka-off ang access sa camera';

  @override
  String get camAccessOffBody =>
      'Para kumuha ng litrato, payagan ang camera sa settings ng iyong telepono. Puwede ka pa ring pumili ng litrato sa gallery.';

  @override
  String get camNoTextTitle => 'Walang nakitang teksto';

  @override
  String get camNoTextBody =>
      'Subukan ang mas malinaw na litrato na may maayos na ilaw, at panatilihing tuwid at malapit ang mga salita.';

  @override
  String get camCouldntReadTitle => 'Hindi mabasa ang litrato';

  @override
  String get camCouldntReadBody =>
      'May nangyaring mali. Subukan ulit o pumili ng ibang litrato.';

  @override
  String get camChooseAnother => 'Pumili ng iba';

  @override
  String get camSheetBody =>
      'Binabasa ng Hibalo ang mga salita sa litrato at isinasalin ito.';

  @override
  String get camUseCamera => 'Gamitin ang iyong camera';

  @override
  String get camPickExisting => 'Pumili ng litratong mayroon ka na';

  @override
  String get camReading => 'Binabasa ang teksto…';

  @override
  String get camTakesSeconds =>
      'Ilang segundo lang ito at gumagana kahit walang internet.';

  @override
  String get voiceListening => 'Nakikinig…';

  @override
  String get voiceHoldMic => 'I-tap ang mic at magsalita';

  @override
  String get voiceStopListening => 'Itigil ang pakikinig';

  @override
  String get voiceStartListening => 'Simulan ang pakikinig';

  @override
  String get voiceTapToStop => 'I-tap ulit para huminto';

  @override
  String get voiceTapToStart => 'I-tap para magsimula';

  @override
  String get voiceDidntCatch => 'Hindi ko narinig nang maayos';

  @override
  String get voiceDidntCatchBody =>
      'Magsalita nang mas malakas at mas malapit sa telepono, saka subukan ulit.';

  @override
  String get voiceMicOffTitle => 'Naka-off ang access sa mikropono';

  @override
  String get voiceMicOffBody =>
      'Para magsalin gamit ang boses, payagan ang mikropono sa settings ng iyong telepono. Puwede ka pa ring mag-type.';

  @override
  String get voiceFilipinoTitle => 'Filipino voice';

  @override
  String get voiceFilipinoInstall =>
      'Para marinig ang Filipino, i-install ang Filipino voice ng iyong telepono.';

  @override
  String get voiceInstall => 'I-install';

  @override
  String get voiceLater => 'Mamaya na';

  @override
  String get voiceFilipinoMissing =>
      'Wala pang Filipino voice sa telepono. I-install sa Settings.';

  @override
  String get voiceFilipinoNotReady =>
      'Hindi pa handa ang Filipino voice. Kumonekta sa internet at subukan ulit.';

  @override
  String get histTapToOpen => 'I-tap ang salin para buksan ulit.';

  @override
  String get histClearAll => 'Burahin lahat';

  @override
  String get histEmptyTitle => 'Wala pang salin';

  @override
  String get histEmptyBody =>
      'Lalabas dito ang mga salita at pariralang isinalin mo, para mabuksan mo ulit.';

  @override
  String get savedEmptyTitle => 'Wala pang naka-save na salita';

  @override
  String get savedEmptyBody =>
      'I-tap ang bookmark sa salin para itago ito dito at pagsanayan.';

  @override
  String get savedCountOne => '1 naka-save na salita o parirala';

  @override
  String savedCountMany(Object count) {
    return '$count naka-save na salita at parirala';
  }

  @override
  String get histToday => 'Ngayon';

  @override
  String get histYesterday => 'Kahapon';

  @override
  String histFromTo(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get histRemoveSaved => 'Alisin sa naka-save';

  @override
  String get histCleared => 'Nabura ang history ng salin';

  @override
  String get clearHistoryAction => 'Burahin ang history';

  @override
  String get clearHistoryTitle => 'Burahin ang history ng salin?';

  @override
  String get clearHistoryBody =>
      'Mabubura ang lahat ng dati mong salin sa teleponong ito. Mananatili ang mga naka-save mong salita.';

  @override
  String get clearHistoryKeep => 'Huwag burahin';

  @override
  String get clearSavedAction => 'Burahin ang naka-save na salita';

  @override
  String get clearSavedTitle => 'Burahin ang naka-save na salita?';

  @override
  String get clearSavedBody =>
      'Mabubura ang lahat ng salitang na-save mo. Mananatili ang progreso mo sa aralin.';

  @override
  String get clearSavedKeep => 'Huwag burahin';

  @override
  String get savedCleared => 'Nabura ang naka-save na salita';

  @override
  String get meTitle => 'Ako';

  @override
  String get meAccount => 'Account';

  @override
  String get meEditProfile => 'I-edit ang profile';

  @override
  String get meEditProfileSub => 'Pangalan at avatar';

  @override
  String get meLanguageRow => 'Wika';

  @override
  String get meSettings => 'Settings';

  @override
  String get meSettingsSub => 'Data, privacy, credits';

  @override
  String get meHelp => 'Tulong at Suporta';

  @override
  String get meHelpSub => 'FAQ, makipag-ugnayan';

  @override
  String get meLogOut => 'Mag-log out';

  @override
  String get meLogOutTitle => 'Mag-log out?';

  @override
  String get meLogOutBody =>
      'Naka-save ang iyong progreso. Puwede kang mag-sign in ulit anumang oras.';

  @override
  String get meStay => 'Manatili';

  @override
  String get meProfileUpdated => 'Na-update ang profile';

  @override
  String get meUser => 'User';

  @override
  String get editTitle => 'I-edit ang profile';

  @override
  String get editChooseAvatar => 'Pumili ng avatar';

  @override
  String editAvatar(Object number) {
    return 'Avatar $number';
  }

  @override
  String get editUsernameEmpty => 'Hindi puwedeng walang laman ang username.';

  @override
  String get editUsernameShort =>
      'Dapat hindi bababa sa 3 character ang username.';

  @override
  String get editNewPassword => 'Bagong password';

  @override
  String get editConfirmNewPassword => 'Kumpirmahin ang bagong password';

  @override
  String get editCurrentPassword =>
      'Kasalukuyang password (para makumpirmang ikaw ito)';

  @override
  String get editCurrentPasswordHint => 'Kasalukuyang password';

  @override
  String get editOnlyNeeded =>
      'Kailangan lang kung papalitan ang email o password.';

  @override
  String get editForgotPassword => 'Nakalimutan ang iyong password?';

  @override
  String get editSaveChanges => 'I-save ang mga pagbabago';

  @override
  String get editDeleteAccount => 'Burahin ang account';

  @override
  String get editWrongPassword => 'Mali ang password na iyan. Subukan ulit.';

  @override
  String get editNeedPassword =>
      'Ilagay ang kasalukuyang password para mapalitan ang email o password.';

  @override
  String get editNeedPasswordDelete =>
      'Ilagay ang kasalukuyang password para mabura ang account.';

  @override
  String get editEmailInUse => 'Ginagamit na ang email na ito.';

  @override
  String get editNoInternet => 'Walang internet. Kumonekta at subukan ulit.';

  @override
  String get editTooManyTries =>
      'Masyadong maraming subok. Maghintay sandali at subukan ulit.';

  @override
  String get editCouldntSave => 'Hindi ma-save. Subukan ulit.';

  @override
  String get editCheckEmailTitle => 'Tingnan ang iyong bagong email';

  @override
  String editCheckEmailBody(Object email) {
    return 'Nagpadala kami ng link sa $email. Buksan ito para matapos ang pagpapalit ng email. Hangga\'t hindi pa tapos, mag-sign in gamit ang lumang email.';
  }

  @override
  String get editResendLink => 'Ipadala ulit ang link';

  @override
  String get editLinkSent => 'Naipadala ulit ang link';

  @override
  String get editDeleteTitle => 'Burahin ang iyong account?';

  @override
  String get editDeleteBody =>
      'Mabubura ang iyong profile, progreso, naka-save na salita at history. Hindi na ito maibabalik.';

  @override
  String get editDeleteKeep => 'Huwag burahin ang account ko';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'Tungkol sa app';

  @override
  String get settingsPrivacy => 'Patakaran sa privacy';

  @override
  String get settingsCredits => 'Credits at lisensya';

  @override
  String get settingsCreditsSub => 'Boses, data, icon at font';

  @override
  String get settingsAppVersion => 'Bersyon ng app';

  @override
  String settingsVersionValue(Object version) {
    return 'Hibalo $version';
  }

  @override
  String get privacyIntro =>
      'Ginawa ang Hibalo ng mga estudyante ng Polytechnic University of the Philippines para sa isang capstone study.';

  @override
  String get privacySaveLabel => 'Ano ang sine-save namin';

  @override
  String get privacySaveText =>
      'ang iyong username, email address at napiling avatar; kung kailan ka nag-sign up at huling nag-sign in; at ang iyong progreso sa pag-aaral (mga natapos na aralin, iskor sa pagsusulit, XP at streak). Naka-save ang mga ito sa Google Firebase para hindi mawala ang iyong progreso.';

  @override
  String get privacyNotSaveLabel => 'Ano ang hindi namin sine-save';

  @override
  String get privacyNotSaveText =>
      'ang tekstong isinasalin mo, ang mga litratong ini-scan mo at ang iyong boses. Nasa telepono mo lang ang history ng salin at mga naka-save na salita; mabubura ang mga ito kapag in-uninstall ang app o binura sa Settings. Sa telepono mo ginagawa ang pagsasalin at pagbasa ng litrato. Ang speech-to-text ay gumagamit ng sariling speech service ng telepono, na maaaring sumunod sa privacy terms ng Google. Ang pagsasanay sa pagsasalita sa mga aralin ay nasa telepono mo lang habang ginagamit, saka binubura.';

  @override
  String get privacyWhoLabel => 'Sino ang makakakita ng iyong data';

  @override
  String get privacyWhoText =>
      'ikaw lang at ang research team (mga administrator ng app). Hindi mo makikita ang data ng ibang user, at hindi rin nila makikita ang sa iyo.';

  @override
  String get privacyUseLabel => 'Paano ginagamit ang iyong data';

  @override
  String get privacyUseText =>
      'para lang sa pag-aaral na ito. Hindi ito ibinebenta o ibinabahagi.';

  @override
  String get privacyDeleteLabel => 'Pagbura ng iyong data';

  @override
  String get privacyDeleteText =>
      'puwede mong burahin ang iyong account at progreso sa Ako › I-edit ang profile, o hilingin sa research team na gawin ito.';

  @override
  String get privacyQuestionsLabel => 'Mga tanong';

  @override
  String get privacyQuestionsText => 'makipag-ugnayan sa Hibalo research team.';

  @override
  String get creditsIntro =>
      'Ginawa ng Hibalo team, Polytechnic University of the Philippines.';

  @override
  String get creditsVoiceLabel => 'Boses na Hiligaynon';

  @override
  String get creditsVoiceText =>
      'isang fine-tuned na bersyon ng MMS-TTS (VITS) model ng Meta, may lisensyang CC BY-NC 4.0 (para lamang sa hindi pangkomersyal na paggamit).';

  @override
  String get creditsDataLabel => 'Data para sa pag-train ng voice model';

  @override
  String get creditsDataText =>
      'Philippine Languages Database (PLD), University of the Philippines Diliman Digital Signal Processing Laboratory (UP-DSP).';

  @override
  String get creditsTranslationLabel => 'Pagsasalin';

  @override
  String get creditsTranslationText =>
      'isang MarianMT model na sinanay ng Hibalo team, sa tulong ng MADLAD-400 model at mga pampublikong teksto sa Hiligaynon at Filipino.';

  @override
  String get creditsLessonsLabel => 'Nilalaman ng aralin';

  @override
  String get creditsLessonsText =>
      'isinulat ng Hibalo team at sinuri gamit ang mga pampublikong sanggunian, kabilang ang Omniglot, Iloilo Directory, Wikipedia, ang ERIC Hiligaynon language packet (ED402758) at pinoydictionary.com.';

  @override
  String get creditsReadingLabel => 'Pagbasa ng teksto';

  @override
  String get creditsReadingText =>
      'Google ML Kit. Font: Plus Jakarta Sans (SIL Open Font License). Mga icon: Material Symbols (Apache License 2.0).';

  @override
  String get creditsOpenSource => 'Open-source na software';

  @override
  String get helpTitle => 'Tulong at Suporta';

  @override
  String get helpFaqTitle => 'Mga madalas itanong';

  @override
  String get helpQ1 => 'Paano magsalin ng litrato?';

  @override
  String get helpA1 =>
      'Sa Isalin, i-tap ang camera, saka kumuha ng litrato o pumili sa gallery. Tingnan ang tekstong nabasa ng Hibalo at ayusin ang mali; lalabas sa ibaba ang salin.';

  @override
  String get helpQ2 => 'Gumagana ba ang Hibalo kahit walang internet?';

  @override
  String get helpA2 =>
      'Oo, pagkatapos mong mag-sign in nang isang beses. Gumagana kahit walang internet ang pagsasalin, pagbasa ng litrato, boses na Hiligaynon at mga aralin. Mase-save sa account mo ang progreso kapag online ka na ulit. Ang pagsasalin gamit ang boses ay gumagamit ng speech service ng telepono, na maaaring mangailangan ng internet.';

  @override
  String get helpQ3 => 'Paano kung mukhang mali ang salin?';

  @override
  String get helpA3 =>
      'Ginagawa sa telepono mo ang salin at maaaring hindi eksakto. Subukan ang mas maikling pangungusap o tingnan ang baybay. Para sa boses at litrato, ayusin ang teksto sa kahon, saka i-tap ang Isalin.';

  @override
  String get helpQ4 => 'Paano mabubuksan ang susunod na aralin?';

  @override
  String get helpA4 =>
      'Ipasa ang pagsusulit ng aralin nang hindi bababa sa 80%. Mabubuksan ang Aralin 2 kapag natapos mo ang Aralin 1.';

  @override
  String get helpQ5 => 'Paano kumita ng XP?';

  @override
  String get helpA5 =>
      'Tapusin ang isang aralin (20 XP), sagutin nang tama ang mabilis na tanong (5 XP) o ang tanong sa pagsusulit (10 XP). Isang beses lang nagbibigay ng XP ang bawat isa.';

  @override
  String get helpQ6 => 'Paano palitan ang aking avatar?';

  @override
  String get helpA6 =>
      'Pumunta sa Ako, i-tap ang I-edit ang profile, pumili ng avatar, saka i-tap ang I-save ang mga pagbabago.';

  @override
  String get helpStillNeed => 'Kailangan pa ng tulong?';

  @override
  String helpEmailUs(Object email) {
    return 'Mag-email sa amin sa $email';
  }

  @override
  String get helpCantOpenEmail => 'Hindi mabuksan ang email app.';

  @override
  String get adminGoodMorning => 'Magandang Umaga';

  @override
  String get adminGoodAfternoon => 'Magandang Hapon';

  @override
  String get adminGoodEvening => 'Magandang Gabi';

  @override
  String get adminTitle => 'Admin Dashboard';

  @override
  String get adminManagement => 'Pag-manage';

  @override
  String get adminManageUsers => 'I-manage ang mga user';

  @override
  String get adminManageUsersSub =>
      'Tingnan, i-edit, i-promote o alisin ang mga user';

  @override
  String get adminUsage => 'Analytics ng paggamit';

  @override
  String get adminUsageSub => 'Aktibong user kada araw at linggo';

  @override
  String get adminRecentSignups => 'Mga bagong nag-sign up';

  @override
  String get adminSwitchLight => 'Gawing Light';

  @override
  String get adminSwitchDark => 'Gawing Dark';

  @override
  String get adminRefresh => 'I-refresh';

  @override
  String get adminLogout => 'Mag-log out';

  @override
  String get adminTotalUsers => 'Lahat ng user';

  @override
  String get adminAdmins => 'Mga Admin';

  @override
  String get adminActiveToday => 'Aktibo Ngayon';

  @override
  String get adminActiveWeek => 'Aktibo / Linggo';

  @override
  String get adminNoUsersYet => 'Wala pang user.';

  @override
  String get adminUnknown => 'Hindi alam';

  @override
  String get adminBadge => 'ADMIN';

  @override
  String get adminNoEmail => 'Walang email';

  @override
  String get adminLoading => 'Nilo-load ang dashboard...';

  @override
  String get adminSearch => 'Maghanap ayon sa pangalan o email...';

  @override
  String get adminAll => 'Lahat';

  @override
  String get adminNoUsersFound => 'Walang nakitang user.';

  @override
  String get adminNoName => 'Walang Pangalan';

  @override
  String get adminNoEmailCap => 'Walang Email';

  @override
  String get adminEdit => 'I-edit';

  @override
  String get adminRemoveAdmin => 'Alisin bilang Admin';

  @override
  String get adminMakeAdmin => 'Gawing Admin';

  @override
  String get adminDelete => 'Burahin';

  @override
  String get adminPromoted => 'Ginawang admin ang user';

  @override
  String get adminDemoted => 'Inalis ang admin role';

  @override
  String adminError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminEditUser => 'I-edit ang User';

  @override
  String get adminName => 'Pangalan';

  @override
  String get adminUserUpdated => 'Na-update ang user';

  @override
  String get adminDeleteUser => 'Burahin ang User';

  @override
  String adminDeleteConfirm(Object name) {
    return 'Sigurado ka bang buburahin si \"$name\"?\nHindi na ito maibabalik.';
  }

  @override
  String get adminUserDeleted => 'Nabura ang user';

  @override
  String get adminDailyActive => 'AKTIBONG USER KADA ARAW — HULING 7 ARAW';

  @override
  String get adminBreakdown => 'DETALYE';

  @override
  String adminActiveCount(Object count) {
    return '$count aktibo';
  }

  @override
  String get adminEntry => 'Admin';

  @override
  String get settingsClearHistory => 'Burahin ang history ng salin';
}
