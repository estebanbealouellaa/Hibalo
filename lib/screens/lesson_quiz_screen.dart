import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart'; // purple, purple600, purple900, teal300, pink500
import 'library_screen.dart'; // Lesson, Gamify, LessonCompleteScreen
import 'filipiniana_cheer.dart'; // cheering character
import '../data/hiligaynon_quizzes.dart'; // generated quizzes, all levels

// ═════════════════════════════════════════════════════════════════════════════
// PALETTE
// ═════════════════════════════════════════════════════════════════════════════
const Color _bg = Color(0xFFF7F5FF);
const Color _ink = Color(0xFF1F1B2E);
const Color _muted = Color(0xFF6B6880);
const Color _amber = Color(0xFFFFB020);

Color _dark(Color c, [double amount = 0.14]) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Route<T> _slideRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 380),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, a, __, child) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(opacity: curved, child: child);
  },
);

// ═════════════════════════════════════════════════════════════════════════════
// AUDIO HOOK
// Set LessonAudio.speak once at app start to enable the listening questions,
// e.g. with the flutter_tts package:
//
//   final tts = FlutterTts()..setLanguage('fil-PH');
//   LessonAudio.speak = (text) => tts.speak(text);
//
// If it is left null, the play button reveals the word as text instead, so the
// quiz still works without any audio package.
// ═════════════════════════════════════════════════════════════════════════════
typedef SpeakFn = Future<void> Function(String text);

class LessonAudio {
  static SpeakFn? speak;
  static bool get isAvailable => speak != null;
}

// ═════════════════════════════════════════════════════════════════════════════
// QUESTION MODEL
// ═════════════════════════════════════════════════════════════════════════════
enum QType {
  mc,
  listen,
  fill,
  type,
  arrange,
  dialogue,
  match,
  dictation,
  speak,
  open,
}

class ExamQuestion {
  final String id;
  final QType type;

  /// Shown above the question, e.g. "Choose the Filipino meaning."
  final String instruction;

  /// The question itself. Supports **bold** and _italic_.
  final String prompt;

  /// Word or phrase played aloud (listen questions).
  final String audio;

  /// Choices for mc / listen / fill / dialogue.
  final List<String> options;
  final int answer;

  /// Accepted answers for type questions (first one is shown as the model
  /// answer). Comparison ignores case, accents and punctuation.
  final List<String> accepted;

  /// Word tiles for arrange questions, plus the sentence they build.
  final List<String> tiles;
  final String sentence;

  /// Pairs for match questions: [hiligaynon, filipino].
  final List<List<String>> pairs;

  /// Extra teaching note shown after answering.
  final String note;

  const ExamQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    this.instruction = '',
    this.audio = '',
    this.options = const [],
    this.answer = 0,
    this.accepted = const [],
    this.tiles = const [],
    this.sentence = '',
    this.pairs = const [],
    this.note = '',
  });

  String get label {
    switch (type) {
      case QType.mc:
        return 'Multiple choice';
      case QType.listen:
        return 'Listening';
      case QType.fill:
        return 'Fill in the blank';
      case QType.type:
        return 'Type the answer';
      case QType.arrange:
        return 'Build the sentence';
      case QType.dialogue:
        return 'Real situation';
      case QType.match:
        return 'Match the pairs';
      case QType.dictation:
        return 'Dictation';
      case QType.speak:
        return 'Speaking';
      case QType.open:
        return 'Open answer';
    }
  }

  IconData get icon {
    switch (type) {
      case QType.mc:
        return Icons.check_circle_outline_rounded;
      case QType.listen:
        return Icons.headphones_rounded;
      case QType.fill:
        return Icons.edit_note_rounded;
      case QType.type:
        return Icons.keyboard_rounded;
      case QType.arrange:
        return Icons.reorder_rounded;
      case QType.dialogue:
        return Icons.forum_rounded;
      case QType.match:
        return Icons.compare_arrows_rounded;
      case QType.dictation:
        return Icons.hearing_rounded;
      case QType.speak:
        return Icons.mic_rounded;
      case QType.open:
        return Icons.edit_rounded;
    }
  }

  /// Speaking and open answers cannot be machine-graded, so the learner
  /// compares with the model answer and rates themselves.
  bool get selfGraded => type == QType.speak || type == QType.open;
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAM: LESSON 1
// ═════════════════════════════════════════════════════════════════════════════
const List<ExamQuestion> lesson1Exam = [
  ExamQuestion(
    id: 'B1-1',
    type: QType.mc,
    instruction: 'Choose the Filipino meaning.',
    prompt: 'Which Filipino meaning matches _Maayong aga_?',
    options: [
      'Magandang umaga',
      'Pakiusap',
      'Walang anuman',
      'Maraming salamat',
    ],
    answer: 0,
    note: '_Maayong_ matches Filipino _magandang_, and _aga_ is morning.',
  ),
  ExamQuestion(
    id: 'B1-2',
    type: QType.listen,
    instruction: 'Listen, then choose the Filipino meaning.',
    prompt: 'What did you hear?',
    audio: 'Madamo nga salamat',
    options: [
      'Maraming salamat',
      'Pasensya na',
      'Ikaw naman?',
      'Magandang hapon',
    ],
    answer: 0,
    note: '_Madamo_ means "many," so _madamo nga salamat_ is "many thanks."',
  ),
  ExamQuestion(
    id: 'B1-3',
    type: QType.fill,
    instruction: 'Complete the sentence. It should mean "Pakihintay ako."',
    prompt: '＿＿＿, hulata ako.',
    options: ['Palihog', 'Pasayloa', 'Salamat', 'Indi'],
    answer: 0,
    note: '_Palihog_ opens a polite request and softens the command _hulata_.',
  ),
  ExamQuestion(
    id: 'B1-4',
    type: QType.mc,
    instruction: 'Choose the best answer.',
    prompt: 'In the spelling _gab-i_, the hyphen marks:',
    options: [
      'a plural ending',
      'a silent letter',
      'a glottal stop',
      'a capital letter',
    ],
    answer: 2,
    note: 'It is the small catch in the throat you hear in "uh-oh."',
  ),
  ExamQuestion(
    id: 'B1-5',
    type: QType.mc,
    instruction: 'Choose the best answer.',
    prompt: 'How many basic vowel sounds does native Hiligaynon have?',
    options: ['Five', 'Seven', 'Two', 'Three (a, i, u)'],
    answer: 3,
    note: 'The letters _e_ and _o_ appear mostly in loanwords.',
  ),
  ExamQuestion(
    id: 'B1-6',
    type: QType.type,
    instruction: 'Translate to Filipino.',
    prompt: 'Pasayloa ako, nalate ako.',
    accepted: [
      'Patawarin mo ako, nahuli ako.',
      'Patawarin mo ako nahuli ako',
      'Patawarin mo ako, na-late ako',
      'Patawarin mo ako, nalate ako',
      'Pasensya na, nahuli ako',
    ],
    note: '_Pasayloa ako_ is the Hiligaynon apology, "please forgive me."',
  ),
  ExamQuestion(
    id: 'B1-7',
    type: QType.arrange,
    instruction: 'Tap the words in order to build the sentence.',
    prompt: 'Greet someone in the morning and ask how they are.',
    tiles: ['Kamusta', 'Maayong', 'aga!', 'ka?'],
    sentence: 'Maayong aga! Kamusta ka?',
    note: 'Greeting first, then the question.',
  ),
  ExamQuestion(
    id: 'B1-8',
    type: QType.dialogue,
    instruction: 'Choose the best thing to say.',
    prompt: 'You greet an elderly woman at 4 p.m.',
    options: [
      'Maayong aga, ikaw.',
      'Hoy, kamusta?',
      'Salamat gid.',
      'Maayong hapon ho, Manang.',
    ],
    answer: 3,
    note:
        'Right time of day (_hapon_), the respect particle _ho_, and _Manang_ '
        'for an older woman.',
  ),
  ExamQuestion(
    id: 'B1-9',
    type: QType.match,
    instruction: 'Tap a Hiligaynon word, then its Filipino match.',
    prompt: 'Match Hiligaynon to Filipino.',
    pairs: [
      ['Kamusta ka?', 'Kumusta ka?'],
      ['Maayo man ako', 'Mabuti naman ako'],
      ['Madamo nga salamat', 'Maraming salamat'],
      ['Wala sing anuman', 'Walang anuman'],
    ],
    note: 'These four carry most everyday small talk.',
  ),
  ExamQuestion(
    id: 'B1-10',
    type: QType.type,
    instruction: 'Translate to Filipino.',
    prompt: 'Maayong hapon ho, Manang.',
    accepted: [
      'Magandang hapon po, Manang.',
      'Magandang hapon po Manang',
      'Magandang hapon po, Ate',
    ],
    note: 'Hiligaynon _ho_ becomes Filipino _po_.',
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
// EXAM: LESSON 2
// ═════════════════════════════════════════════════════════════════════════════
const List<ExamQuestion> lesson2Exam = [
  ExamQuestion(
    id: 'B2-1',
    type: QType.mc,
    instruction: 'Choose the Filipino meaning.',
    prompt: 'Which Filipino meaning matches _kita_?',
    options: [
      'tayo (kasama ang kausap)',
      'mga (pang-maramihan)',
      'tao',
      'amin',
    ],
    answer: 0,
    note: 'Careful, false friend: Filipino _kita_ can mean "I (to) you."',
  ),
  ExamQuestion(
    id: 'B2-2',
    type: QType.fill,
    instruction: 'Complete the sentence. It should mean "Aking libro ito."',
    prompt: '＿＿＿ nga libro ini.',
    options: ['Akon', 'Iya', 'Amon', 'Imo'],
    answer: 0,
    note: '_Akon_ is "my" in the long form that comes before the noun.',
  ),
  ExamQuestion(
    id: 'B2-3',
    type: QType.mc,
    instruction: 'Choose the correct phrase.',
    prompt: 'Which is correct for "my house"?',
    options: ['balay akon', 'akon nga balay', 'akon balay', 'balay nga akon'],
    answer: 1,
    note:
        'The long form comes before the noun with _nga_; the short form '
        '(_balay ko_) comes after.',
  ),
  ExamQuestion(
    id: 'B2-4',
    type: QType.arrange,
    instruction: 'Tap the words in order to build the sentence.',
    prompt: 'Say "You are the students."',
    tiles: ['Kamo', 'mga', 'ang', 'estudyante.'],
    sentence: 'Kamo ang mga estudyante.',
    note: '_Mga_ marks the plural and sits right before the noun.',
  ),
  ExamQuestion(
    id: 'B2-5',
    type: QType.type,
    instruction: 'Write it in Hiligaynon.',
    prompt: 'Say "I am a student."',
    accepted: ['Estudyante ako.', 'Estudyante ako'],
    note: 'Predicate first, and there is no word for "am."',
  ),
  ExamQuestion(
    id: 'B2-6',
    type: QType.type,
    instruction: 'Write it in Hiligaynon.',
    prompt: 'Say "I am Ana."',
    accepted: ['Ako si Ana.', 'Ako si Ana'],
    note: 'Names take _si_. _Si Ana ako_ is not natural.',
  ),
  ExamQuestion(
    id: 'B2-7',
    type: QType.listen,
    instruction: 'Listen, then choose the Filipino meaning.',
    prompt: 'What did you hear?',
    audio: 'aton',
    options: ['kayo', 'tao', 'babae', 'atin'],
    answer: 3,
    note: '_Aton_ is the inclusive "our," matching Filipino _atin_.',
  ),
  ExamQuestion(
    id: 'B2-8',
    type: QType.mc,
    instruction: 'Choose the best answer.',
    prompt: 'The Hiligaynon pronoun _siya_ means:',
    options: ['he or she', 'only she', 'only he', 'they'],
    answer: 0,
    note: 'Hiligaynon pronouns do not mark gender.',
  ),
  ExamQuestion(
    id: 'B2-9',
    type: QType.match,
    instruction: 'Tap a Hiligaynon word, then its Filipino match.',
    prompt: 'Match Hiligaynon to Filipino.',
    pairs: [
      ['imo', 'iyong'],
      ['iya', 'kaniya'],
      ['amon', 'amin'],
      ['aton', 'atin'],
    ],
    note: 'This is the _akon/imo_ set: the possessor before the noun.',
  ),
  ExamQuestion(
    id: 'B2-10',
    type: QType.type,
    instruction: 'Translate to Filipino.',
    prompt: 'Si Jose ang akon utod.',
    accepted: [
      'Si Jose ang kapatid ko.',
      'Si Jose ang kapatid ko',
      'Si Jose ay kapatid ko',
      'Kapatid ko si Jose',
    ],
    note: '_Utod_ is a brother or sister; Filipino uses _kapatid_.',
  ),
];

/// Returns the exam for a lesson id, or an empty list if it has none.
/// Beginner 1 and 2 are hand-written above; every other lesson comes from
/// the generated question bank in lib/data/hiligaynon_quizzes.dart.
List<ExamQuestion> examFor(String lessonId) {
  switch (lessonId) {
    case 'beginner_1':
      return lesson1Exam;
    case 'beginner_2':
      return lesson2Exam;
    default:
      return generatedExams[lessonId] ?? const [];
  }
}

/// Pass marks from the question bank: 80% Beginner and Intermediate,
/// 85% Advanced.
double passMarkFor(String lessonId) =>
    lessonId.startsWith('advanced') ? 0.85 : 0.80;

// ═════════════════════════════════════════════════════════════════════════════
// ANSWER CHECKING
// ═════════════════════════════════════════════════════════════════════════════
String _normalize(String s) {
  var t = s.toLowerCase().trim();
  const from = 'áàâäéèêëíìîïóòôöúùûüñç';
  const to = 'aaaaeeeeiiiioooouuuunc';
  final b = StringBuffer();
  for (final ch in t.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  t = b.toString();
  t = t.replaceAll(RegExp(r'[.,!?;:"\u2018\u2019\u201C\u201D]'), '');
  t = t.replaceAll('-', ' ');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t;
}

bool _matchesAccepted(String input, List<String> accepted) {
  final n = _normalize(input);
  if (n.isEmpty) return false;
  return accepted.any((a) => _normalize(a) == n);
}

// ═════════════════════════════════════════════════════════════════════════════
// QUIZ SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class LessonQuizScreen extends StatefulWidget {
  final Lesson lesson;
  final List<ExamQuestion> questions;

  /// XP already earned while reading the lesson, carried to the result screen.
  final int sessionXp;

  /// Hook to your flashcard / practice flow.
  final VoidCallback? onPractice;

  /// When true, finishing returns to the previous screen instead of showing
  /// the celebration screen. Used when the learner retakes the quiz.
  final bool isRetake;

  const LessonQuizScreen({
    super.key,
    required this.lesson,
    required this.questions,
    this.sessionXp = 0,
    this.onPractice,
    this.isRetake = false,
  });

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  int _index = 0;
  int _score = 0;
  int _xp = 0;
  bool _checked = false;
  bool _correct = false;
  bool _busy = false;

  /// For speaking / open questions: has the learner rated their answer yet?
  bool _rated = false;

  // per-question answer state
  int? _selected;
  final TextEditingController _typeCtrl = TextEditingController();
  List<int> _arranged = [];
  List<int> _rightOrder = []; // shuffled right column for match questions
  final Map<int, int> _matched = {}; // left index -> right index
  int? _matchLeft;

  ExamQuestion get _q => widget.questions[_index];
  int get _total => widget.questions.length;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  void _prepare() {
    _selected = null;
    _typeCtrl.clear();
    _arranged = [];
    _matched.clear();
    _matchLeft = null;
    _checked = false;
    _correct = false;
    _rated = false;
    if (_q.type == QType.match) {
      _rightOrder = List.generate(_q.pairs.length, (i) => i)
        ..shuffle(math.Random(_q.id.hashCode));
    }
  }

  bool get _canCheck {
    switch (_q.type) {
      case QType.mc:
      case QType.listen:
      case QType.fill:
      case QType.dialogue:
        return _selected != null;
      case QType.type:
      case QType.dictation:
        return _typeCtrl.text.trim().isNotEmpty;
      case QType.arrange:
        return _arranged.length == _q.tiles.length;
      case QType.match:
        return _matched.length == _q.pairs.length;
      case QType.speak:
      case QType.open:
        return true; // revealing the model answer is always allowed
    }
  }

  bool _grade() {
    switch (_q.type) {
      case QType.mc:
      case QType.listen:
      case QType.fill:
      case QType.dialogue:
        return _selected == _q.answer;
      case QType.type:
      case QType.dictation:
        return _matchesAccepted(_typeCtrl.text, _q.accepted);
      case QType.arrange:
        final built = _arranged.map((i) => _q.tiles[i]).join(' ');
        return _normalize(built) == _normalize(_q.sentence);
      case QType.match:
        return _matched.entries.every((e) => e.key == e.value);
      case QType.speak:
      case QType.open:
        return false; // graded by the learner in _rate()
    }
  }

  /// Self-assessment for speaking and open questions.
  Future<void> _rate(bool gotIt) async {
    if (_rated) return;
    setState(() {
      _rated = true;
      _correct = gotIt;
      if (gotIt) _score++;
    });
    if (gotIt) {
      HapticFeedback.mediumImpact();
      if (await Gamify.claim('exam:${widget.lesson.id}:${_q.id}')) {
        await Gamify.addXp(10);
        if (mounted) setState(() => _xp += 10);
      }
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _check() async {
    if (!_canCheck || _checked) return;
    FocusScope.of(context).unfocus();
    if (_q.selfGraded) {
      // Reveal the model answer; the learner rates themselves next.
      HapticFeedback.lightImpact();
      setState(() => _checked = true);
      return;
    }
    final ok = _grade();
    setState(() {
      _checked = true;
      _correct = ok;
      if (ok) _score++;
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      if (await Gamify.claim('exam:${widget.lesson.id}:${_q.id}')) {
        await Gamify.addXp(10);
        if (mounted) setState(() => _xp += 10);
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _next() async {
    if (_busy) return;
    if (_index + 1 < _total) {
      setState(() {
        _index++;
        _prepare();
      });
      return;
    }

    // Finished.
    _busy = true;
    await Gamify.touch();
    if (_score == _total &&
        await Gamify.claim('exam_perfect:${widget.lesson.id}')) {
      await Gamify.addXp(25);
      if (mounted) setState(() => _xp += 25);
    }
    final streak = await Gamify.streak();
    if (!mounted) return;

    if (widget.isRetake) {
      Navigator.pushReplacement(
        context,
        _slideRoute(
          _QuizResultScreen(
            lesson: widget.lesson,
            score: _score,
            total: _total,
            xp: _xp,
            questions: widget.questions,
            onPractice: widget.onPractice,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        _slideRoute(
          LessonCompleteScreen(
            lesson: widget.lesson,
            xpEarned: widget.sessionXp + _xp,
            streak: streak,
            onPractice: widget.onPractice,
            quizScore: _score,
            quizTotal: _total,
          ),
        ),
      );
    }
  }

  Future<void> _quitPrompt() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Leave the quiz?'),
        content: const Text(
          'Your score for this attempt will not be saved. XP you already '
          'earned stays with you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quitPrompt();
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(a),
                      child: child,
                    ),
                  ),
                  child: ListView(
                    key: ValueKey(_index),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      _header(),
                      const SizedBox(height: 18),
                      _body(),
                      if (_checked) ...[
                        const SizedBox(height: 18),
                        _feedback(),
                      ],
                    ],
                  ),
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _quitPrompt,
            icon: const Icon(Icons.close_rounded, color: _muted),
          ),
          Expanded(
            child: Row(
              children: List.generate(_total, (i) {
                final done = i < _index || (i == _index && _checked);
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: i == _index ? 8 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: done
                          ? (i == _index && !_correct ? pink500 : teal300)
                          : i == _index
                          ? purple
                          : purple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: teal300.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_score/$_total',
              style: TextStyle(
                color: _dark(teal300, 0.18),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_q.icon, size: 14, color: purple),
                  const SizedBox(width: 6),
                  Text(
                    _q.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: purple,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'Question ${_index + 1} of $_total',
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (_q.instruction.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _q.instruction,
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
        ],
        const SizedBox(height: 6),
        _Markup(
          _q.prompt,
          const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _ink,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _body() {
    switch (_q.type) {
      case QType.mc:
      case QType.fill:
      case QType.dialogue:
        return _choices();
      case QType.listen:
        return Column(
          children: [
            _AudioButton(text: _q.audio),
            const SizedBox(height: 16),
            _choices(),
          ],
        );
      case QType.type:
        return _typeField();
      case QType.dictation:
        return Column(
          children: [
            _AudioButton(text: _q.audio, revealable: false),
            const SizedBox(height: 18),
            _typeField(hint: 'Type what you hear'),
          ],
        );
      case QType.arrange:
        return _arrangeBoard();
      case QType.match:
        return _matchBoard();
      case QType.speak:
        return _speakCard();
      case QType.open:
        return _typeField(
          hint: 'Write your answer (optional)',
          optional: true,
          lines: 4,
        );
    }
  }

  // ── Speaking prompt ───────────────────────────────────────────────────────
  Widget _speakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_rounded, color: purple, size: 34),
          ),
          const SizedBox(height: 12),
          const Text(
            'Say your answer out loud, or practice it with a partner. '
            'When you are ready, tap "Show the model answer" and rate '
            'yourself honestly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  // ── Multiple choice ───────────────────────────────────────────────────────
  Widget _choices() {
    return Column(
      children: [for (int i = 0; i < _q.options.length; i++) _choice(i)],
    );
  }

  Widget _choice(int i) {
    final isAnswer = i == _q.answer;
    final picked = _selected == i;

    Color border = picked ? purple : Colors.grey.withOpacity(0.22);
    Color fill = picked ? purple.withOpacity(0.06) : Colors.white;
    Color badge = purple;
    IconData? trailing;

    if (_checked) {
      if (isAnswer) {
        border = teal300;
        fill = teal300.withOpacity(0.12);
        badge = teal300;
        trailing = Icons.check_circle_rounded;
      } else if (picked) {
        border = pink500;
        fill = pink500.withOpacity(0.08);
        badge = pink500;
        trailing = Icons.cancel_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Press(
        onTap: _checked ? null : () => setState(() => _selected = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.8),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badge.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  String.fromCharCode(65 + i),
                  style: TextStyle(
                    color: badge,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Markup(
                  _q.options[i],
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                    height: 1.3,
                  ),
                ),
              ),
              if (trailing != null) Icon(trailing, color: border, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Typed answer ──────────────────────────────────────────────────────────
  Widget _typeField({
    String hint = 'Type your answer',
    bool optional = false,
    int lines = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _typeCtrl,
          enabled: !_checked,
          autocorrect: false,
          textCapitalization: TextCapitalization.sentences,
          maxLines: lines,
          minLines: 1,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _check(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: optional
                    ? purple.withOpacity(0.3)
                    : (_correct ? teal300 : pink500).withOpacity(0.6),
                width: 1.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: purple, width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          optional
              ? 'Writing it down helps, but you can also just say it.'
              : 'Capital letters, accents and punctuation are not graded.',
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    );
  }

  // ── Build the sentence ────────────────────────────────────────────────────
  Widget _arrangeBoard() {
    final used = _arranged.toSet();
    final built = _arranged.map((i) => _q.tiles[i]).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _checked
                  ? (_correct ? teal300 : pink500)
                  : purple.withOpacity(0.25),
              width: 1.8,
            ),
          ),
          child: _arranged.isEmpty
              ? const Text(
                  'Tap the words below to build your sentence.',
                  style: TextStyle(color: _muted, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int pos = 0; pos < _arranged.length; pos++)
                      _Press(
                        onTap: _checked
                            ? null
                            : () => setState(() => _arranged.removeAt(pos)),
                        child: _tile(_q.tiles[_arranged[pos]], filled: true),
                      ),
                  ],
                ),
        ),
        if (built.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            built,
            style: const TextStyle(
              color: _muted,
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < _q.tiles.length; i++)
              if (!used.contains(i))
                _Press(
                  onTap: _checked
                      ? null
                      : () => setState(() => _arranged.add(i)),
                  child: _tile(_q.tiles[i], filled: false),
                ),
          ],
        ),
      ],
    );
  }

  Widget _tile(String text, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: filled ? purple : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: filled
            ? null
            : Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
        boxShadow: filled
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.white : _ink,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }

  // ── Match the pairs ───────────────────────────────────────────────────────
  Widget _matchBoard() {
    final pairs = _q.pairs;

    Color leftColor(int i) {
      if (!_matched.containsKey(i)) {
        return _matchLeft == i ? purple : Colors.grey.withOpacity(0.25);
      }
      if (!_checked) return purple;
      return _matched[i] == i ? teal300 : pink500;
    }

    int? leftFor(int right) {
      for (final e in _matched.entries) {
        if (e.value == right) return e.key;
      }
      return null;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (int i = 0; i < pairs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Press(
                    onTap: _checked
                        ? null
                        : () => setState(() {
                            if (_matched.containsKey(i)) {
                              _matched.remove(i);
                              _matchLeft = null;
                            } else {
                              _matchLeft = _matchLeft == i ? null : i;
                            }
                          }),
                    child: _matchCell(
                      pairs[i][0],
                      color: leftColor(i),
                      filled: _matchLeft == i,
                      italic: true,
                      tag: _matched.containsKey(i)
                          ? '${_matched[i]! + 1}'
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              for (int pos = 0; pos < pairs.length; pos++)
                Builder(
                  builder: (_) {
                    final r = _rightOrder[pos];
                    final owner = leftFor(r);
                    final taken = owner != null;
                    Color c = Colors.grey.withOpacity(0.25);
                    if (taken) {
                      c = !_checked ? purple : (owner == r ? teal300 : pink500);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Press(
                        onTap: _checked
                            ? null
                            : () => setState(() {
                                if (taken) {
                                  _matched.remove(owner);
                                  return;
                                }
                                if (_matchLeft != null) {
                                  _matched[_matchLeft!] = r;
                                  _matchLeft = null;
                                  HapticFeedback.selectionClick();
                                }
                              }),
                        child: _matchCell(
                          pairs[r][1],
                          color: c,
                          filled: false,
                          italic: false,
                          tag: taken ? '${owner! + 1}' : null,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _matchCell(
    String text, {
    required Color color,
    required bool filled,
    required bool italic,
    String? tag,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: italic ? purple : _ink,
              ),
            ),
          ),
          if (tag != null)
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Feedback ──────────────────────────────────────────────────────────────
  Widget _feedback() {
    if (_q.selfGraded) return _selfFeedback();
    final color = _correct ? teal300 : pink500;
    final title = _correct ? 'Husto!' : 'Sayop.';

    String answerText = '';
    if (!_correct) {
      switch (_q.type) {
        case QType.mc:
        case QType.listen:
        case QType.fill:
        case QType.dialogue:
          answerText = _q.options[_q.answer];
          break;
        case QType.type:
        case QType.dictation:
          answerText = _q.accepted.isNotEmpty ? _q.accepted.first : '';
          break;
        case QType.speak:
        case QType.open:
          break;
        case QType.arrange:
          answerText = _q.sentence;
          break;
        case QType.match:
          answerText = _q.pairs.map((p) => '${p[0]} = ${p[1]}').join(' · ');
          break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _correct ? '🎉' : '💡',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: _dark(color, 0.12),
                ),
              ),
              const Spacer(),
              if (_correct)
                Text(
                  '+10 XP',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    color: _dark(color, 0.12),
                  ),
                ),
            ],
          ),
          if (answerText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Answer: $answerText',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ink,
                height: 1.4,
              ),
            ),
          ],
          if (_q.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            _Markup(
              _q.note,
              const TextStyle(fontSize: 13.5, height: 1.45, color: _ink),
            ),
          ],
        ],
      ),
    );
  }

  /// Model answer + rubric, then two buttons for self-assessment.
  Widget _selfFeedback() {
    final model = _q.accepted.isNotEmpty ? _q.accepted.first : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: purple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: purple.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🧭', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Compare with the model',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: purple,
                ),
              ),
            ],
          ),
          if (model.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              model,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: _ink,
                height: 1.45,
              ),
            ),
          ],
          if (_q.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Markup(
              _q.note,
              const TextStyle(fontSize: 13, height: 1.45, color: _muted),
            ),
          ],
          const SizedBox(height: 14),
          if (!_rated)
            Row(
              children: [
                Expanded(
                  child: _Push(
                    onTap: () => _rate(false),
                    color: Colors.white,
                    foreground: pink500,
                    child: const Text('Not yet'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Push(
                    onTap: () => _rate(true),
                    color: teal300,
                    child: const Text('I got it'),
                  ),
                ),
              ],
            )
          else
            Text(
              _correct
                  ? 'Husto! +10 XP. Keep saying it aloud to make it stick.'
                  : 'No problem. Say the model answer aloud three times, '
                        'then move on.',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _dark(_correct ? teal300 : pink500, 0.12),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final last = _index == _total - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: _Push(
          onTap: _checked
              ? ((_q.selfGraded && !_rated) ? null : _next)
              : (_canCheck ? _check : null),
          color: !_checked
              ? purple
              : (_q.selfGraded && !_rated)
              ? purple
              : (_correct ? teal300 : pink500),
          child: Text(
            !_checked
                ? (_q.selfGraded ? 'Show the model answer' : 'Check')
                : (_q.selfGraded && !_rated)
                ? 'Rate yourself above'
                : (last ? 'See my score' : 'Continue'),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RESULT SCREEN (used when the learner retakes the quiz)
// ═════════════════════════════════════════════════════════════════════════════
class _QuizResultScreen extends StatelessWidget {
  final Lesson lesson;
  final int score;
  final int total;
  final int xp;
  final List<ExamQuestion> questions;
  final VoidCallback? onPractice;

  const _QuizResultScreen({
    required this.lesson,
    required this.score,
    required this.total,
    required this.xp,
    required this.questions,
    this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (score / total * 100).round();
    final passed = pct >= (passMarkFor(lesson.id) * 100).round();
    // The gown gets brighter the better the learner did.
    final gown = pct == 100
        ? const Color(0xFFC01F6B)
        : passed
        ? const Color(0xFF9B1B5A)
        : const Color(0xFF6E2A6B);
    final headline = pct == 100
        ? 'Perpekto!'
        : passed
        ? 'Maayo gid!'
        : 'Keep practicing';
    final sub = pct == 100
        ? 'A perfect score on Lesson ${lesson.number}.'
        : passed
        ? 'You passed Lesson ${lesson.number}. Review the ones you missed and '
              'try again for a perfect score.'
        : 'Read Lesson ${lesson.number} once more, then take the quiz again. '
              'Repetition is how it sticks.';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                children: [
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: FilipinianaCheer(size: 190, gown: gown),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sub,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      _resultTile('✅', '$score/$total', 'Correct'),
                      const SizedBox(width: 10),
                      _resultTile('📊', '$pct%', 'Score'),
                      const SizedBox(width: 10),
                      _resultTile('⚡', '+$xp', 'XP earned'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _Push(
                      color: purple,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        _slideRoute(
                          LessonQuizScreen(
                            lesson: lesson,
                            questions: questions,
                            onPractice: onPractice,
                            isRetake: true,
                          ),
                        ),
                      ),
                      child: const Text('Try the quiz again'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to the lesson',
                      style: TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultTile(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: purple.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SMALL UI PIECES
// ═════════════════════════════════════════════════════════════════════════════

/// Play button for listening questions. Falls back to showing the text when
/// no speech engine is wired up through [LessonAudio.speak].
class _AudioButton extends StatefulWidget {
  final String text;

  /// False for dictation: without a speech engine the text is shown with a
  /// note, so the item still works as copy-typing practice.
  final bool revealable;
  const _AudioButton({required this.text, this.revealable = true});

  @override
  State<_AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<_AudioButton> {
  bool _revealed = false;

  Future<void> _play() async {
    HapticFeedback.lightImpact();
    final speak = LessonAudio.speak;
    if (speak != null) {
      await speak(widget.text);
    } else {
      setState(() => _revealed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Press(
          onTap: _play,
          child: Container(
            width: 110,
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [purple, purple600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: purple.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          LessonAudio.isAvailable
              ? 'Tap to listen again'
              : widget.revealable
              ? 'Tap to reveal'
              : 'Audio is not set up yet. Tap to see the sentence.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 12.5),
        ),
        if (_revealed) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: purple.withOpacity(0.3)),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: purple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Chunky 3D button that presses down.
class _Push extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color foreground;
  const _Push({
    required this.child,
    required this.onTap,
    this.color = purple,
    this.foreground = Colors.white,
  });

  @override
  State<_Push> createState() => _PushState();
}

class _PushState extends State<_Push> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final base = enabled ? widget.color : Colors.grey.shade300;
    const d = 5.0;

    return GestureDetector(
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled
          ? (_) {
              _set(false);
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: _down ? d : 0, bottom: _down ? 0 : d),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _dark(base, 0.14),
              offset: Offset(0, _down ? 0 : d),
            ),
          ],
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: enabled ? widget.foreground : Colors.grey.shade600,
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              letterSpacing: 0.3,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Shrinks slightly while pressed.
class _Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Press({required this.child, this.onTap});

  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled
          ? (_) {
              _set(false);
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Tiny inline markup: **bold** and _italic_.
class _Markup extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _Markup(this.text, this.style);

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    // Blanks written as ___ would be read as italics, so swap them for
    // full-width underscores first.
    final text = this.text.replaceAll('___', '\uFF3F\uFF3F\uFF3F');
    final re = RegExp(r'\*\*(.+?)\*\*|_(.+?)_');
    int last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: purple,
            ),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
