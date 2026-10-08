import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart'; // purple, purple600, purple900, teal300, pink500
import 'lesson_quiz_screen.dart'; // end-of-lesson quiz
import 'filipiniana_cheer.dart'; // vector lesson art + cheering character
import '../data/hiligaynon_lessons.dart'; // generated lessons, all levels

// ═════════════════════════════════════════════════════════════════════════════
// PALETTE (local helpers, built on your existing app_colors)
// ═════════════════════════════════════════════════════════════════════════════
const Color _bg = Color(0xFFF7F5FF);
const Color _ink = Color(0xFF1F1B2E);
const Color _muted = Color(0xFF6B6880);
const Color _amber = Color(0xFFFFB020);

Color _darken(Color c, [double amount = 0.14]) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Route<T> _route<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, a, __, child) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

// ═════════════════════════════════════════════════════════════════════════════
// CONTENT MODEL
// ═════════════════════════════════════════════════════════════════════════════
abstract class Block {
  const Block();
}

class SubheadingBlock extends Block {
  final String text;
  const SubheadingBlock(this.text);
}

/// Supports **bold** and _italic_ inline markup.
class ParagraphBlock extends Block {
  final String text;
  const ParagraphBlock(this.text);
}

class BulletsBlock extends Block {
  final List<String> items;
  const BulletsBlock(this.items);
}

class TableBlock extends Block {
  final List<String> headers;
  final List<List<String>> rows;
  final int italicColumn; // column rendered in accent + italic (Hiligaynon)
  const TableBlock({
    required this.headers,
    required this.rows,
    this.italicColumn = 0,
  });
}

class CalloutBlock extends Block {
  final String title;
  final String text;
  final String emoji;
  final Color color;
  const CalloutBlock({
    required this.title,
    required this.text,
    this.emoji = '💡',
    this.color = teal300,
  });
}

class DialogueLine {
  final String speaker;
  final String hiligaynon;
  final String english;
  const DialogueLine(this.speaker, this.hiligaynon, this.english);
}

class DialogueBlock extends Block {
  final List<DialogueLine> lines;
  const DialogueBlock(this.lines);
}

/// Multiple-choice quick check. Awards XP the first time it is solved
/// on the first try. [id] must be unique and stable across app versions.
class QuizBlock extends Block {
  final String id;
  final String question;
  final List<String> options;
  final int answer;
  final String explain;
  const QuizBlock({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explain,
  });
}

class Flashcard {
  final String front;
  final String back;
  const Flashcard(this.front, this.back);
}

/// One row of an alphabet or sound chart.
class LetterEntry {
  final String letter;
  final String name;
  final String sound;
  final String example;
  final String meaning;
  const LetterEntry({
    required this.letter,
    required this.name,
    required this.sound,
    required this.example,
    required this.meaning,
  });
}

/// A swipeable deck of letter cards. Built for phones in portrait: one big
/// card at a time instead of a five-column table that runs off the screen.
class LetterCardsBlock extends Block {
  final String title;
  final List<LetterEntry> letters;
  const LetterCardsBlock(this.letters, {this.title = 'The alphabet'});
}

/// Grid of tap-to-flip word cards.
class FlashcardsBlock extends Block {
  final String title;
  final List<Flashcard> cards;
  const FlashcardsBlock(this.cards, {this.title = 'Flip the cards'});
}

class LessonSection {
  final String title;
  final IconData icon;
  final int minutes;
  final List<Block> blocks;
  const LessonSection({
    required this.title,
    required this.icon,
    required this.minutes,
    required this.blocks,
  });

  bool get hasQuiz => blocks.any((b) => b is QuizBlock);
}

class Lesson {
  final String id;
  final int number;
  final String title;
  final String subtitle;
  final String emoji;
  final String level;
  final List<String> objectives;
  final List<LessonSection> sections;
  const Lesson({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.level,
    required this.objectives,
    required this.sections,
  });

  int get minutes => sections.fold(0, (s, e) => s + e.minutes);
  int get quizCount =>
      sections.fold(0, (s, e) => s + e.blocks.whereType<QuizBlock>().length);
}

// ═════════════════════════════════════════════════════════════════════════════
// LESSON LIST
// Add new lessons here, in order. Each lesson unlocks when the one before it
// is finished. Set [kLockLessons] to false while testing to open everything.
// ═════════════════════════════════════════════════════════════════════════════
const bool kLockLessons = true;
// Lessons 1 and 2 are hand-written below; the rest come from the curriculum
// document via lib/data/hiligaynon_lessons.dart.
const List<Lesson> beginnerLessons = [
  lesson1,
  lesson2,
  ...generatedBeginnerLessons,
];
const List<Lesson> intermediateLessons = generatedIntermediateLessons;
const List<Lesson> advancedLessons = generatedAdvancedLessons;

/// The level a lesson belongs to.
LearningLevel? levelOf(Lesson lesson) {
  for (final lv in learningLevels) {
    if (lv.lessons.any((l) => l.id == lesson.id)) return lv;
  }
  return null;
}

// ═════════════════════════════════════════════════════════════════════════════
// LEVELS
// Three rungs of the ladder. A level opens only when every lesson in the level
// before it is finished, so the learner always has one clear next step.
// ═════════════════════════════════════════════════════════════════════════════
class LearningLevel {
  final String id;
  final int step; // 1, 2, 3
  final String name;
  final String hiligaynonName;
  final String tagline;

  /// Three short promises of what the learner will be able to do.
  final List<String> skills;

  final List<Lesson> lessons;
  final List<Color> colors;

  /// Which motif LessonArt draws on this level's banner.
  final int artMotif;

  const LearningLevel({
    required this.id,
    required this.step,
    required this.name,
    required this.hiligaynonName,
    required this.tagline,
    required this.skills,
    required this.lessons,
    required this.colors,
    required this.artMotif,
  });

  int get totalSections => lessons.fold(0, (s, l) => s + l.sections.length);
  int get minutes => lessons.fold(0, (s, l) => s + l.minutes);
  int get quizCount => lessons.length;
}

const List<LearningLevel> learningLevels = [
  LearningLevel(
    id: 'beginner',
    step: 1,
    name: 'Beginner',
    hiligaynonName: 'Para sa nagasugod',
    tagline:
        'Sounds, greetings, numbers, time, family, food and first verbs. '
        'By the end you can hold a short, slow conversation.',
    skills: [
      'Pronounce words, greet anyone and introduce yourself',
      'Count, tell time, and talk about family, places and food',
      'Use basic verbs, ask questions and shop or ask directions',
    ],
    lessons: beginnerLessons,
    colors: [purple, pink500],
    artMotif: 1,
  ),
  LearningLevel(
    id: 'intermediate',
    step: 2,
    name: 'Intermediate',
    hiligaynonName: 'Para sa may nahibal-an',
    tagline:
        'From phrases to real sentences: talk about feelings, health, work '
        'and travel, and tell what happened, is happening and will happen.',
    skills: [
      'Narrate past, present and future with the right aspect',
      'Sound natural with particles and linkers like man, gid and nga',
      'Describe, compare, give opinions, read, listen and translate',
    ],
    lessons: intermediateLessons,
    colors: [purple600, teal300],
    artMotif: 2,
  ),
  LearningLevel(
    id: 'advanced',
    step: 3,
    name: 'Advanced',
    hiligaynonName: 'Para sa hanas',
    tagline:
        'Speak like a local: master the focus system, idioms and register, '
        'and follow fast, natural speech from Iloilo to Negros.',
    skills: [
      'Use the focus (voice) system and recognize regional variation',
      'Use idioms and switch between formal and informal register',
      'Tell longer stories, argue a point and translate with nuance',
    ],
    lessons: advancedLessons,
    colors: [pink500, _amber],
    artMotif: 3,
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
// LESSON 1 — BEGINNER
// ═════════════════════════════════════════════════════════════════════════════
const Lesson lesson1 = Lesson(
  id: 'beginner_1',
  number: 1,
  title: 'Sounds, Alphabet, Greetings & Courtesy',
  subtitle: 'Read, pronounce and greet in Hiligaynon',
  emoji: '👋',
  level: 'Beginner',
  objectives: [
    'Recognize the letters and sounds used in written Hiligaynon.',
    'Pronounce the special features: ng, the glottal stop, and stress.',
    'Greet people at different times of day and respond politely.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Hiligaynon uses the same letters as Filipino and is fairly phonetic, '
          'but a few sounds differ (**ng**, the **glottal stop**, **stress**). '
          'Greetings come first because they open every conversation and are '
          'an expected sign of good manners.',
        ),
        CalloutBlock(
          title: 'How this lesson works',
          emoji: '🎮',
          color: pink500,
          text:
              'Flip word cards, tap chat bubbles to reveal translations, and '
              'answer quick checks to earn XP. Come back each day to keep '
              'your streak going.',
        ),
        QuizBlock(
          id: 'l1_q_intro',
          question:
              'Which of these will you learn to pronounce in this lesson?',
          options: [
            'The glottal stop',
            'Rising and falling tones',
            'Silent letters',
          ],
          answer: 0,
          explain:
              'Hiligaynon has no tones like Chinese, but the **glottal stop**, '
              '**ng** and **stress** all matter.',
        ),
      ],
    ),
    LessonSection(
      title: 'The Alphabet',
      icon: Icons.abc_rounded,
      minutes: 3,
      blocks: [
        ParagraphBlock(
          'Modern Hiligaynon is written with the Latin alphabet. The '
          'traditional native alphabet (the _Abakada_-type inventory) uses '
          'these letters:',
        ),
        LetterCardsBlock([
          LetterEntry(
            letter: 'Aa',
            name: 'a',
            sound: 'like a in "father"',
            example: 'aga',
            meaning: 'morning',
          ),
          LetterEntry(
            letter: 'Bb',
            name: 'ba',
            sound: 'like English b',
            example: 'balay',
            meaning: 'house',
          ),
          LetterEntry(
            letter: 'Dd',
            name: 'da',
            sound: 'like English d',
            example: 'duha',
            meaning: 'two',
          ),
          LetterEntry(
            letter: 'Gg',
            name: 'ga',
            sound: 'like g in "go"',
            example: 'gab-i',
            meaning: 'night',
          ),
          LetterEntry(
            letter: 'Hh',
            name: 'ha',
            sound: 'like h in "hat"',
            example: 'hapon',
            meaning: 'afternoon',
          ),
          LetterEntry(
            letter: 'Ii',
            name: 'i',
            sound: 'like ee in "see" (short)',
            example: 'isa',
            meaning: 'one',
          ),
          LetterEntry(
            letter: 'Kk',
            name: 'ka',
            sound: 'like k in "sky", no puff of air',
            example: 'kaon',
            meaning: 'eat',
          ),
          LetterEntry(
            letter: 'Ll',
            name: 'la',
            sound: 'like English l',
            example: 'lamesa',
            meaning: 'table',
          ),
          LetterEntry(
            letter: 'Mm',
            name: 'ma',
            sound: 'like English m',
            example: 'matahom',
            meaning: 'beautiful',
          ),
          LetterEntry(
            letter: 'Nn',
            name: 'na',
            sound: 'like English n',
            example: 'napulo',
            meaning: 'ten',
          ),
          LetterEntry(
            letter: 'NG ng',
            name: 'nga',
            sound: 'like ng in "sing"',
            example: 'ngalan',
            meaning: 'name',
          ),
          LetterEntry(
            letter: 'Oo',
            name: 'o',
            sound: 'between o in "go" and u in "put"',
            example: 'anom',
            meaning: 'six',
          ),
          LetterEntry(
            letter: 'Pp',
            name: 'pa',
            sound: 'like p in "spin", no puff of air',
            example: 'palihog',
            meaning: 'please',
          ),
          LetterEntry(
            letter: 'Rr',
            name: 'ra',
            sound: 'a quick tap of the tongue, like Spanish r',
            example: 'rason',
            meaning: 'reason',
          ),
          LetterEntry(
            letter: 'Ss',
            name: 'sa',
            sound: 'like English s',
            example: 'salamat',
            meaning: 'thank you',
          ),
          LetterEntry(
            letter: 'Tt',
            name: 'ta',
            sound: 'like t in "star", no puff of air',
            example: 'tubig',
            meaning: 'water',
          ),
          LetterEntry(
            letter: 'Uu',
            name: 'u',
            sound: 'like oo in "moon" (short)',
            example: 'tuig',
            meaning: 'year',
          ),
          LetterEntry(
            letter: 'Ww',
            name: 'wa',
            sound: 'like English w',
            example: 'walo',
            meaning: 'eight',
          ),
          LetterEntry(
            letter: 'Yy',
            name: 'ya',
            sound: 'like English y',
            example: 'yuhum',
            meaning: 'smile',
          ),
        ], title: 'Letters & sounds'),
        ParagraphBlock(
          'The full Filipino alphabet of **28 letters** is also used, mainly '
          'for Spanish and English loanwords and for names: _Enero_ (January), '
          '_Pebrero_ (February), _Niño_, _Jose_, _Cebu_. The letters '
          '_e, f, j, c, ñ, q, v, x_ and _z_ appear mostly in loanwords.',
        ),
        FlashcardsBlock([
          Flashcard('balay', 'house'),
          Flashcard('tubig', 'water'),
          Flashcard('ngalan', 'name'),
          Flashcard('yuhum', 'smile'),
          Flashcard('matahom', 'beautiful'),
          Flashcard('tuig', 'year'),
        ], title: 'Warm-up words'),
        QuizBlock(
          id: 'l1_q_alphabet',
          question: 'What does _tubig_ mean?',
          options: ['House', 'Water', 'Year', 'Smile'],
          answer: 1,
          explain:
              '_Tubig_ is water. The t has no puff of air, like the t in "star".',
        ),
      ],
    ),
    LessonSection(
      title: 'Vowels & the letters "ng"',
      icon: Icons.record_voice_over_rounded,
      minutes: 2,
      blocks: [
        SubheadingBlock('Vowels'),
        ParagraphBlock(
          'Linguists describe **three basic vowel sounds** in native '
          'Hiligaynon: /a/, /i/, and /u/. The letters _e_ and _o_ appear '
          'mostly in Spanish loanwords (_Enero, doktor, kwarto_) and in '
          'spellings that show a variant of _i_ or _u_. This is why the '
          'letter _o_ in words like _anom_ (six) is pronounced somewhere '
          'between _o_ and _u_. Keep vowels **short and clear**, without '
          'gliding them the way English speakers do.',
        ),
        SubheadingBlock('The letters ng'),
        ParagraphBlock(
          'Spanish and English speakers may think _ng_ is only found at the '
          'end of words (like "sing"). In Hiligaynon, and in Filipino, '
          '_ng_ is **one single consonant** that can also appear at the '
          'beginning of a word: _ngalan_ (name), _ngaa_ (why), _nga_ '
          '(linker). Practice saying "sing-a" and then remove the "si": '
          'you get "nga".',
        ),
        QuizBlock(
          id: 'l1_q_vowels',
          question:
              'How many **basic vowel sounds** does native Hiligaynon have?',
          options: ['Three', 'Five', 'Seven'],
          answer: 0,
          explain:
              '/a/, /i/ and /u/. The letters _e_ and _o_ mostly show up in '
              'loanwords or as variants.',
        ),
      ],
    ),
    LessonSection(
      title: 'Glottal Stop & Stress',
      icon: Icons.graphic_eq_rounded,
      minutes: 2,
      blocks: [
        SubheadingBlock('The glottal stop'),
        ParagraphBlock(
          'The glottal stop is a tiny catch in the throat, the same sound '
          'you hear in the middle of "uh-oh." It is common at the end of '
          'words that end in a vowel and inside some words. It matters '
          'because it can change meaning and rhythm. In many teaching '
          'spellings, a hyphen marks the glottal stop between a consonant '
          'and a vowel:',
        ),
        BulletsBlock([
          '_gab-i_ (night), pronounced gab-ee with a slight catch after the b.',
          '_kan-on_ (cooked rice), with a catch between n and o.',
          '_sin-o_ (who) and _san-o_ (when).',
        ]),
        ParagraphBlock(
          'If you already speak Filipino, you know the idea: in Filipino, '
          '_buhay_ can be stressed BU-hay (life) or bu-HAY (alive), and '
          'speakers also end many vowel-ending words with a light glottal '
          'catch. Hiligaynon uses similar tools.',
        ),
        SubheadingBlock('Stress'),
        ParagraphBlock(
          'Hiligaynon words have a stressed syllable, and stress placement '
          'can change meaning or make speech sound foreign. Do not guess: '
          '**learn each new word by listening to it**, then say it in a '
          'full phrase. For example, say _ba-LAY_ (house), and _Maayong aga_ '
          'in one flowing phrase, not as separate blocks.',
        ),
        QuizBlock(
          id: 'l1_q_glottal',
          question:
              'Which spelling shows the glottal stop in the word for "night"?',
          options: ['gabi', 'gab-i', 'gabbi'],
          answer: 1,
          explain:
              'The hyphen in _gab-i_ marks the catch in the throat. Without '
              'it, _gabi_ is the Filipino word for taro root!',
        ),
      ],
    ),
    LessonSection(
      title: 'Greetings by Time of Day',
      icon: Icons.wb_sunny_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock(
          'Hiligaynon greetings use _maayong_ ("good") plus the time of day:',
        ),
        TableBlock(
          headers: ['Time', 'Hiligaynon', 'Filipino'],
          italicColumn: 1,
          rows: [
            ['morning', 'Maayong aga', 'Magandang umaga'],
            ['midday / noon', 'Maayong udto', 'Magandang tanghali'],
            ['afternoon', 'Maayong hapon', 'Magandang hapon'],
            ['evening / night', 'Maayong gab-i', 'Magandang gabi'],
          ],
        ),
        CalloutBlock(
          title: 'Remember',
          emoji: '🕐',
          text:
              'Udto covers the late-morning-to-early-afternoon period '
              'around lunchtime. Hapon starts after lunch until sunset. '
              'Gab-i covers evening and night.',
        ),
        FlashcardsBlock([
          Flashcard('Maayong aga', 'Good morning'),
          Flashcard('Maayong udto', 'Good noon'),
          Flashcard('Maayong hapon', 'Good afternoon'),
          Flashcard('Maayong gab-i', 'Good evening'),
        ], title: 'Greeting cards'),
        QuizBlock(
          id: 'l1_q_greetings',
          question: 'It\'s 8:00 PM and you meet a friend. What do you say?',
          options: [
            'Maayong aga',
            'Maayong udto',
            'Maayong hapon',
            'Maayong gab-i',
          ],
          answer: 3,
          explain: '_Gab-i_ covers both evening and night.',
        ),
      ],
    ),
    LessonSection(
      title: 'How Are You?',
      icon: Icons.chat_bubble_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Kamusta ka?_ ("How are you?") comes from Spanish _¿cómo está?_, '
          'just like Filipino _kumusta_. Typical answers:',
        ),
        BulletsBlock([
          '_Maayo man ako._ (I\'m fine.)',
          '_Maayo man, salamat. Ikaw man?_ (Fine, thanks. And you?)',
          '_Okay lang._ (Just okay.)',
        ]),
        ParagraphBlock(
          '_Ikaw man?_ (literally "you also?") is the standard, friendly way '
          'to say "And you?" and shows the particle _man_ at work, which you '
          'will study in detail at the Intermediate level.',
        ),
        QuizBlock(
          id: 'l1_q_howareyou',
          question:
              'A friend asks _Kamusta ka?_ Which reply answers and asks back?',
          options: [
            'Maayo man, salamat. Ikaw man?',
            'Wala sing anuman.',
            'Pasayloa ako.',
          ],
          answer: 0,
          explain: '_Ikaw man?_ is the friendly way to say "And you?"',
        ),
      ],
    ),
    LessonSection(
      title: 'Courtesy Words',
      icon: Icons.favorite_rounded,
      minutes: 2,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English', 'Use'],
          italicColumn: 0,
          rows: [
            ['Salamat', 'Salamat', 'Thank you', 'Everyday thanks'],
            [
              'Madamo nga salamat',
              'Maraming salamat',
              'Thank you very much',
              'Stronger thanks',
            ],
            [
              'Wala sing anuman',
              'Walang anuman',
              "You're welcome",
              'Reply to thanks (also written Wala sing ano man)',
            ],
            ['Palihog', 'Pakiusap / Pakisuyo', 'Please', 'Softens a request'],
            [
              'Pasayloa ako',
              'Patawarin mo ako',
              'Please forgive me',
              'Apology',
            ],
            [
              'Pasensya',
              'Pasensya',
              'Sorry / excuse me',
              'Light apology (shared with Filipino)',
            ],
            ['Oo / Indi', 'Oo / Hindi', 'Yes / No', 'Basic replies'],
            [
              'Oo ho / Indi ho',
              'Opo / Hindi po',
              "Yes, sir/ma'am / No, sir/ma'am",
              'Respectful replies',
            ],
          ],
        ),
        CalloutBlock(
          title: 'Respect particles',
          emoji: '🙏',
          color: purple,
          text:
              'Ho and po are respect particles. They are added after oo or '
              'indi, and after other words when speaking to elders or people '
              'you respect: Maayong aga ho, Nanay.',
        ),
        FlashcardsBlock([
          Flashcard('Salamat', 'Thank you'),
          Flashcard('Palihog', 'Please'),
          Flashcard('Wala sing anuman', "You're welcome"),
          Flashcard('Pasayloa ako', 'Please forgive me'),
        ], title: 'Polite words'),
        QuizBlock(
          id: 'l1_q_courtesy',
          question: 'Someone tells you _Salamat!_ What is the best reply?',
          options: ['Palihog', 'Wala sing anuman', 'Indi ho'],
          answer: 1,
          explain: '_Wala sing anuman_ means "You\'re welcome."',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 2,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Maayong aga! Kamusta ka?',
              'Magandang umaga! Kumusta ka?',
              'Good morning! How are you?',
            ],
            [
              'Maayo man ako, salamat. Ikaw man?',
              'Mabuti naman ako, salamat. Ikaw naman?',
              "I'm fine, thanks. And you?",
            ],
            ['Salamat gid.', 'Salamat talaga.', 'Thank you very much.'],
            ['Wala sing anuman.', 'Walang anuman.', "You're welcome."],
            ['Oo ho, Nanay.', 'Opo, Nanay.', 'Yes, Mother.'],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Maayong aga_ is a complete greeting; reply by '
          'repeating it. _Man_ softens _Maayo man ako_, and _gid_ means '
          '"really" in _Salamat gid_. _Palihog_ opens a polite request and '
          'softens the command _hulata_ ("wait"). _Oo ho_ is what a child '
          'says to a parent or a student to a teacher.',
        ),
        SubheadingBlock('Greeting an older neighbor'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Maayong hapon ho, Manang.',
            'Good afternoon, ma\'am (older sister).',
          ),
          DialogueLine(
            'Neighbor',
            'Maayong hapon man. Kamusta ka?',
            'Good afternoon. How are you?',
          ),
          DialogueLine(
            'You',
            'Maayo man ho, salamat. Kamusta kamo?',
            'Fine, thank you. How are you?',
          ),
          DialogueLine('Neighbor', 'Maayo man kami.', "We're fine."),
        ]),
        CalloutBlock(
          title: 'Did you know?',
          text:
              'Manang (older sister) and Manong (older brother) are used '
              'across the Visayas to address an older woman or man politely, '
              'even a stranger. Using them is one of the quickest ways to '
              'sound respectful in Hiligaynon-speaking communities.',
        ),
        QuizBlock(
          id: 'l1_q_dialogue',
          question:
              'You meet an older woman in the afternoon. Which greeting is '
              'most respectful?',
          options: [
            'Maayong hapon, ikaw.',
            'Maayong hapon ho, Manang.',
            'Maayong aga ho, Manang.',
          ],
          answer: 1,
          explain:
              'Right time of day (_hapon_), the respect particle _ho_, and '
              '_Manang_ for an older woman.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        BulletsBlock([
          'The alphabets are shared, so reading is easy; pronounce carefully and learn stress from audio.',
          '_Maayong_ corresponds to Filipino _magandang_. Hiligaynon uses _maayo_ ("good") where Filipino uses _maganda_ ("beautiful, nice") or _mabuti_. Hiligaynon uses _matahom_ for "beautiful."',
          'Filipino _po/opo_ corresponds to Hiligaynon _ho/po_. Do not drop the respect particle with elders.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Saying _Magandang aga_ or _Maayong umaga_, a mix of Filipino and Hiligaynon. Use **Maayong aga**.',
          'Ignoring the glottal stop, so _gab-i_ becomes _gabi_ (which in Filipino also means "taro root").',
          'Forgetting _ho_ with elders.',
        ]),
        QuizBlock(
          id: 'l1_q_bridge',
          question: 'Which greeting is correct Hiligaynon?',
          options: ['Magandang aga', 'Maayong umaga', 'Maayong aga'],
          answer: 2,
          explain:
              'The other two mix Filipino and Hiligaynon. **Maayong aga** is '
              'the real thing.',
        ),
      ],
    ),
  ],
);

// ═════════════════════════════════════════════════════════════════════════════
// LESSON 2 — BEGINNER
// ═════════════════════════════════════════════════════════════════════════════
const Lesson lesson2 = Lesson(
  id: 'beginner_2',
  number: 2,
  title: 'Pronouns & Identity Sentences',
  subtitle: 'Say who you are and talk about others',
  emoji: '🙋',
  level: 'Beginner',
  objectives: [
    'Use personal pronouns for one person, several people, and "we" '
        '(inclusive and exclusive).',
    'Understand that Hiligaynon pronouns change form by grammatical role.',
    'Build simple identity sentences.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Pronouns are the words you will use most. Hiligaynon pronouns show '
          'whether _"we"_ includes the listener and change form by role in '
          'the sentence, so learn the chart early.',
        ),
        QuizBlock(
          id: 'l2_q_intro',
          question: 'Hiligaynon pronouns change form depending on...',
          options: [
            'The speaker\'s age',
            'Their role in the sentence',
            'The time of day',
          ],
          answer: 1,
          explain:
              'The same person can be _ako_, _ko_ or _akon_ depending on '
              'their **role** in the sentence. You\'ll see all three soon.',
        ),
      ],
    ),
    LessonSection(
      title: 'The Basic (ang) Pronouns',
      icon: Icons.people_alt_rounded,
      minutes: 3,
      blocks: [
        ParagraphBlock(
          'These are the forms used as the **subject or topic** of the '
          'sentence:',
        ),
        TableBlock(
          headers: ['Person', 'Hiligaynon', 'Filipino', 'English'],
          italicColumn: 1,
          rows: [
            ['1st singular', 'ako', 'ako', 'I'],
            ['2nd singular', 'ikaw / ka', 'ikaw / ka', 'you'],
            ['3rd singular', 'siya', 'siya', 'he / she'],
            [
              '1st plural (exclusive)',
              'kami',
              'kami',
              'we (not including you)',
            ],
            ['1st plural (inclusive)', 'kita', 'tayo', 'we (including you)'],
            ['2nd plural', 'kamo', 'kayo', 'you (plural, or polite singular)'],
            ['3rd plural', 'sila', 'sila', 'they'],
          ],
        ),
        BulletsBlock([
          '_Ikaw_ is used when a pronoun starts the sentence or stands alone: '
              '_Ikaw ang manunudlo._ (You are the teacher.)',
          '_Ka_ is the short form used after another word, usually a verb or '
              'adjective: _Kamusta ka?_ _Matahom ka._',
          '_Siya_ means "he" **and** "she." Hiligaynon does not mark gender '
              'in pronouns, so context tells you who is meant.',
        ]),
        FlashcardsBlock([
          Flashcard('ako', 'I'),
          Flashcard('ikaw / ka', 'you'),
          Flashcard('siya', 'he / she'),
          Flashcard('kami', 'we (not you)'),
          Flashcard('kita', 'we (incl. you)'),
          Flashcard('kamo', 'you all / polite you'),
          Flashcard('sila', 'they'),
        ], title: 'Pronoun cards'),
        QuizBlock(
          id: 'l2_q_siya',
          question: 'Who can _siya_ refer to?',
          options: ['Only a man', 'Only a woman', 'A man or a woman'],
          answer: 2,
          explain:
              '_Siya_ covers both "he" and "she." Context tells you which.',
        ),
      ],
    ),
    LessonSection(
      title: 'Inclusive vs. Exclusive "We"',
      icon: Icons.group_add_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock(
          'Hiligaynon (like Filipino) has **two words for "we."**',
        ),
        BulletsBlock([
          '**Kita** includes the person you are speaking to: _Kadto kita sa '
              'merkado._ ("Let\'s go to the market," you and I.)',
          '**Kami** excludes the person you are speaking to: _Kadto kami sa '
              'merkado._ ("We, but not you, are going to the market.")',
        ]),
        CalloutBlock(
          title: 'Don\'t skip this',
          emoji: '⚠️',
          color: pink500,
          text:
              'If you say kami when you mean to invite someone, you sound as '
              'if you are excluding them.',
        ),
        QuizBlock(
          id: 'l2_q_kita',
          question:
              'You want to invite your friend to come with you to the '
              'market. What do you say?',
          options: ['Kadto kami sa merkado.', 'Kadto kita sa merkado.'],
          answer: 1,
          explain:
              '_Kita_ includes your friend. _Kami_ would mean you\'re going '
              '**without** them.',
        ),
      ],
    ),
    LessonSection(
      title: 'The Three Pronoun Sets',
      icon: Icons.view_column_rounded,
      minutes: 3,
      blocks: [
        ParagraphBlock(
          'Hiligaynon pronouns change depending on their role. The three '
          'main sets:',
        ),
        TableBlock(
          headers: [
            'Meaning',
            'Ang set (subject/topic)',
            'Ko/Mo set (actor, possessor after noun)',
            'Akon/Imo set (possessor before noun; "to/for" me, you)',
          ],
          italicColumn: 1,
          rows: [
            ['I / me / my', 'ako', 'ko', 'akon'],
            ['you (sing.)', 'ikaw / ka', 'mo', 'imo'],
            ['he / she', 'siya', 'niya', 'iya'],
            ['we (excl.)', 'kami', 'namon', 'amon'],
            ['we (incl.)', 'kita', 'naton', 'aton'],
            ['you (pl.)', 'kamo', 'ninyo', 'inyo'],
            ['they', 'sila', 'nila', 'ila'],
          ],
        ),
        SubheadingBlock('Examples'),
        BulletsBlock([
          '_Ang balay ko_ (my house). The short form follows the noun.',
          '_Akon nga balay_ (my house). The long form comes before the noun '
              'and takes the linker _nga_.',
          '_Sa akon ang libro._ (The book is mine / belongs to me.)',
        ]),
        FlashcardsBlock([
          Flashcard('balay ko', 'my house'),
          Flashcard('akon nga balay', 'my house'),
          Flashcard('libro mo', 'your book'),
          Flashcard('iya nga balay', 'his / her house'),
        ], title: 'Say "my" two ways'),
        QuizBlock(
          id: 'l2_q_akon',
          question: 'Which phrase correctly says "my house"?',
          options: ['Balay akon', 'Akon nga balay', 'Ko balay'],
          answer: 1,
          explain:
              'The long form _akon_ goes **before** the noun with _nga_. '
              'The short form _ko_ goes **after** it: _balay ko_.',
        ),
      ],
    ),
    LessonSection(
      title: 'Names: si, ni & kay',
      icon: Icons.badge_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock('People\'s names use special markers:'),
        BulletsBlock([
          '**si** before a name when the person is the subject: _Si Maria ang '
              'manunudlo._ (Maria is the teacher.)',
          '**ni** for "of/by" a person: _Ang balay ni Maria_ (Maria\'s house).',
          '**kay** for "to/for/at" a person: _Ginhatag ko kay Maria._ '
              '(I gave it to Maria.)',
        ]),
        FlashcardsBlock([
          Flashcard('si Maria', 'Maria (subject)'),
          Flashcard('ni Maria', 'of / by Maria'),
          Flashcard('kay Maria', 'to / for Maria'),
        ], title: 'Name markers'),
        QuizBlock(
          id: 'l2_q_ni',
          question:
              'Fill the blank for "Maria\'s house": _Ang balay_ ( ? ) _Maria_',
          options: ['si', 'ni', 'kay'],
          answer: 1,
          explain: '_Ni_ means "of" a person: _ang balay ni Maria_.',
        ),
      ],
    ),
    LessonSection(
      title: 'Identity Sentences',
      icon: Icons.record_voice_over_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock(
          'To say "I am a student," Hiligaynon usually puts the description '
          '**first** and the pronoun **after**:',
        ),
        BulletsBlock([
          '_Estudyante ako._ (I am a student.)',
          '_Manunudlo siya._ (She/he is a teacher.)',
          '_Taga-Iloilo kami._ (We are from Iloilo.)',
        ]),
        CalloutBlock(
          title: 'No "am / is / are"',
          emoji: '✂️',
          color: purple,
          text:
              'There is no word for "am/is/are." When the subject is a name, '
              'use si: Ako si Maria. (I am Maria.)',
        ),
        BulletsBlock([
          '_Ako si Maria._ (I am Maria.)',
          '_Si Jose ang akon nga utod._ (Jose is my brother/sibling.)',
        ]),
        QuizBlock(
          id: 'l2_q_identity',
          question: 'What is the natural way to say "I am a student"?',
          options: ['Ako estudyante.', 'Estudyante ako.', 'Ako si estudyante.'],
          answer: 1,
          explain:
              'Description first, pronoun second: _Estudyante ako._ Use _si_ '
              'only before names.',
        ),
      ],
    ),
    LessonSection(
      title: 'Vocabulary',
      icon: Icons.translate_rounded,
      minutes: 2,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['ako', 'ako', 'I'],
            ['ikaw / ka', 'ikaw / ka', 'you'],
            ['siya', 'siya', 'he / she'],
            ['kami', 'kami', 'we (excl.)'],
            ['kita', 'tayo', 'we (incl.)'],
            ['kamo', 'kayo', 'you (plural / polite)'],
            ['sila', 'sila', 'they'],
            ['bata', 'bata', 'child'],
            ['tawo', 'tao', 'person'],
            ['lalaki', 'lalaki', 'man / male'],
            ['babayi', 'babae', 'woman / female'],
            ['estudyante', 'estudyante', 'student'],
            ['manunudlo', 'guro', 'teacher'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('bata', 'child'),
          Flashcard('tawo', 'person'),
          Flashcard('lalaki', 'man / male'),
          Flashcard('babayi', 'woman / female'),
          Flashcard('estudyante', 'student'),
          Flashcard('manunudlo', 'teacher'),
        ], title: 'People words'),
        QuizBlock(
          id: 'l2_q_babayi',
          question: 'What does _babayi_ mean?',
          options: ['Child', 'Man', 'Woman', 'Person'],
          answer: 2,
          explain: '_Babayi_ is woman or female. Compare Filipino _babae_.',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 3,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['Estudyante ako.', 'Estudyante ako.', 'I am a student.'],
            ['Manunudlo siya.', 'Guro siya.', 'She/he is a teacher.'],
            ['Ako si Ana.', 'Ako si Ana.', 'I am Ana.'],
            [
              'Kita ang magkadto sa merkado.',
              'Tayo ang pupunta sa palengke.',
              'We (you and I) are the ones going to the market.',
            ],
            ['Ang libro ko.', 'Ang libro ko.', 'My book.'],
            ['Akon nga libro ini.', 'Aking libro ito.', 'This is my book.'],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Rows 1 to 3 show the predicate-first pattern: '
          'identity first, pronoun second. _Si_ introduces a name '
          '(_Ako si Ana_), and _mga_ comes before the noun, as in Filipino. '
          '_Ang libro ko_ and _Akon nga libro ini_ both mean "my book," but '
          'short _ko_ follows the noun while long _akon_ comes before it and '
          'needs _nga_.',
        ),
        SubheadingBlock('Meeting a classmate'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Maayong aga! Ako si Ana.',
            'Good morning! I am Ana.',
          ),
          DialogueLine(
            'Jose',
            'Maayong aga man. Ako si Jose. Estudyante ka?',
            'Good morning. I am Jose. Are you a student?',
          ),
          DialogueLine(
            'You',
            'Oo, estudyante ako. Taga-Iloilo ako. Ikaw man?',
            'Yes, I\'m a student. I\'m from Iloilo. And you?',
          ),
          DialogueLine(
            'Jose',
            'Taga-Bacolod ako. Kadto kita sa klase!',
            'I\'m from Bacolod. Let\'s go to class!',
          ),
        ]),
        CalloutBlock(
          title: 'Did you know?',
          text:
              'Hiligaynon uses kamo (plural "you") to address a single '
              'respected person, such as a grandparent, teacher, or older '
              'stranger. This is similar to Filipino kayo and to French vous.',
        ),
        QuizBlock(
          id: 'l2_q_dialogue',
          question:
              'Jose says _Kadto kita sa klase!_ Is Ana invited to go with him?',
          options: [
            'Yes, kita includes her',
            'No, kita leaves her out',
            'It doesn\'t say',
          ],
          answer: 0,
          explain:
              '_Kita_ is the inclusive "we," so Jose is inviting Ana along.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        BulletsBlock([
          '**False friend:** Filipino _kita_ can mean "I (to) you" '
              '(_mahal kita_). Hiligaynon _kita_ means **inclusive "we"**.',
          'Filipino _tayo_ = Hiligaynon _kita_. Filipino _kayo_ = Hiligaynon '
              '_kamo_.',
          'Filipino _ang/ng_ have three Hiligaynon counterparts in the '
              'pronoun chart; learn the chart as three columns.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _kami_ when inviting someone.',
          'Placing _akon_ after the noun without _nga_ (_balay akon_ is '
              'wrong); say _akon nga balay_ or _balay ko_.',
          'Starting a sentence with short _ka_. At the start, use _ikaw_.',
        ]),
        QuizBlock(
          id: 'l2_q_bridge',
          question: 'In Hiligaynon, what does _kita_ mean?',
          options: ['I (to) you', 'We, including you', 'They'],
          answer: 1,
          explain:
              'Careful, false friend! Hiligaynon _kita_ is the inclusive '
              '"we," like Filipino _tayo_.',
        ),
      ],
    ),
  ],
);

// ═════════════════════════════════════════════════════════════════════════════
// PROGRESS (sections finished per lesson)
// ═════════════════════════════════════════════════════════════════════════════
class LessonProgress {
  static String _key(String id) => 'lesson_sections_done_$id';

  static Future<int> load(String id) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_key(id)) ?? 0;
  }

  /// Returns true if this moved progress forward.
  static Future<bool> save(String id, int done) async {
    final p = await SharedPreferences.getInstance();
    final prev = p.getInt(_key(id)) ?? 0;
    if (done > prev) {
      await p.setInt(_key(id), done);
      return true;
    }
    return false;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GAMIFICATION (XP, daily streak, one-time rewards)
// ═════════════════════════════════════════════════════════════════════════════
class Gamify {
  static const _xpKey = 'hili_xp';
  static const _streakKey = 'hili_streak';
  static const _lastDayKey = 'hili_last_day';
  static const _claimedKey = 'hili_claimed';

  static String _day(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static Future<int> xp() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_xpKey) ?? 0;
  }

  static Future<int> addXp(int n) async {
    final p = await SharedPreferences.getInstance();
    final v = (p.getInt(_xpKey) ?? 0) + n;
    await p.setInt(_xpKey, v);
    return v;
  }

  /// One-time reward guard. Returns true only the first time [id] is claimed.
  static Future<bool> claim(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_claimedKey) ?? <String>[];
    if (list.contains(id)) return false;
    list.add(id);
    await p.setStringList(_claimedKey, list);
    return true;
  }

  /// Current streak (0 if the learner missed a day).
  static Future<int> streak() async {
    final p = await SharedPreferences.getInstance();
    final last = p.getString(_lastDayKey);
    final s = p.getInt(_streakKey) ?? 0;
    final now = DateTime.now();
    if (last == _day(now) ||
        last == _day(now.subtract(const Duration(days: 1)))) {
      return s;
    }
    return 0;
  }

  /// Marks today as active and returns the updated streak.
  static Future<int> touch() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = _day(now);
    final yesterday = _day(now.subtract(const Duration(days: 1)));
    final last = p.getString(_lastDayKey);
    final s = p.getInt(_streakKey) ?? 0;
    if (last == today) return math.max(s, 1);
    final next = last == yesterday ? s + 1 : 1;
    await p.setInt(_streakKey, next);
    await p.setString(_lastDayKey, today);
    return next;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1) MODULE SCREEN — greeting, streak/XP, word of the day, lesson cards
// ═════════════════════════════════════════════════════════════════════════════
class LibraryScreen extends StatefulWidget {
  /// Called after the learner finishes a lesson and taps "Start practice".
  /// Hook this to your existing flashcard / quiz flow.
  final VoidCallback? onStartPractice;
  const LibraryScreen({super.key, this.onStartPractice});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final Map<String, int> _done = {};
  int _xp = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final d = <String, int>{};
    for (final level in learningLevels) {
      for (final l in level.lessons) {
        d[l.id] = await LessonProgress.load(l.id);
      }
    }
    final x = await Gamify.xp();
    final s = await Gamify.streak();
    if (mounted) {
      setState(() {
        _done
          ..clear()
          ..addAll(d);
        _xp = x;
        _streak = s;
      });
    }
  }

  int _doneFor(Lesson l) => (_done[l.id] ?? 0).clamp(0, l.sections.length);

  int _sectionsDone(LearningLevel lv) =>
      lv.lessons.fold(0, (s, l) => s + _doneFor(l));

  bool _levelFinished(LearningLevel lv) =>
      lv.lessons.isNotEmpty && _sectionsDone(lv) >= lv.totalSections;

  /// A level opens once every lesson in the level before it is finished.
  bool _levelUnlocked(int i) =>
      !kLockLessons || i == 0 || _levelFinished(learningLevels[i - 1]);

  Future<void> _openLevel(LearningLevel lv) async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      _route(
        LevelLessonsScreen(level: lv, onStartPractice: widget.onStartPractice),
      ),
    );
    _refresh();
  }

  /// Greets the learner in Hiligaynon for the current time of day.
  List<String> _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return ['Maayong aga!', 'Good morning'];
    if (h < 14) return ['Maayong udto!', 'Good noon'];
    if (h < 18) return ['Maayong hapon!', 'Good afternoon'];
    return ['Maayong gab-i!', 'Good evening'];
  }

  @override
  Widget build(BuildContext context) {
    final greet = _greeting();

    // Progress across every lesson in every level.
    final totalSections = learningLevels.fold<int>(
      0,
      (s, lv) => s + lv.totalSections,
    );
    final doneSections = learningLevels.fold<int>(
      0,
      (s, lv) => s + _sectionsDone(lv),
    );
    final progress = totalSections == 0
        ? 0.0
        : (doneSections / totalSections).clamp(0.0, 1.0);

    // The level the learner should be working on right now.
    LearningLevel? current;
    for (int i = 0; i < learningLevels.length; i++) {
      final lv = learningLevels[i];
      if (_levelUnlocked(i) && lv.lessons.isNotEmpty && !_levelFinished(lv)) {
        current = lv;
        break;
      }
    }

    String progressText;
    if (current == null) {
      progressText = 'Every lesson is done. Husto gid!';
    } else {
      Lesson? lesson;
      for (final l in current.lessons) {
        if (_doneFor(l) < l.sections.length) {
          lesson = l;
          break;
        }
      }
      progressText = lesson == null
          ? '${current.name} is ready for you.'
          : '${current.name} · Lesson ${lesson.number}: '
                '${_doneFor(lesson)} of ${lesson.sections.length} parts done.';
    }

    return Scaffold(
      backgroundColor: _bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 12,
                20,
                64,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [purple900, purple600],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -70,
                    top: -40,
                    child: _Blob(size: 190, color: pink500.withOpacity(0.22)),
                  ),
                  Positioned(
                    left: -60,
                    bottom: -110,
                    child: _Blob(size: 160, color: teal300.withOpacity(0.16)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.maybePop(context),
                          ),
                          const Spacer(),
                          _GlassChip(
                            emoji: '🔥',
                            label: '$_streak',
                            tooltip: 'Day streak',
                          ),
                          const SizedBox(width: 8),
                          _GlassChip(
                            emoji: '⚡',
                            label: '$_xp XP',
                            tooltip: 'Total XP',
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        greet[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        '${greet[1]} — that\'s your first Hiligaynon of the day.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Learn\nHiligaynon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Progress card ──
                  _SoftCard(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: v,
                                    strokeWidth: 7,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor: purple.withOpacity(0.12),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          purple,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${(v * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: _ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                progressText,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _WordOfDayCard(),
                  const SizedBox(height: 26),
                  const Text(
                    'Choose your level',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Start at the beginning. Each level opens when you finish '
                    'the one before it.',
                    style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < learningLevels.length; i++) ...[
                    if (_levelUnlocked(i))
                      _LevelCard(
                        level: learningLevels[i],
                        sectionsDone: _sectionsDone(learningLevels[i]),
                        isCurrent: identical(learningLevels[i], current),
                        onTap: learningLevels[i].lessons.isEmpty
                            ? null
                            : () => _openLevel(learningLevels[i]),
                      )
                    else
                      _LockedLevelCard(
                        level: learningLevels[i],
                        previousLevel: learningLevels[i - 1],
                      ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LEVEL CARDS
// ═════════════════════════════════════════════════════════════════════════════
class _LevelCard extends StatelessWidget {
  final LearningLevel level;
  final int sectionsDone;
  final bool isCurrent;

  /// Null when the level has no lessons written yet.
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.sectionsDone,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final empty = level.lessons.isEmpty;
    final total = level.totalSections;
    final progress = total == 0 ? 0.0 : (sectionsDone / total).clamp(0.0, 1.0);
    final finished = !empty && progress >= 1;
    final started = sectionsDone > 0;
    final accent = finished ? teal300 : level.colors.first;

    return _Bouncy(
      onTap: onTap,
      scale: 0.985,
      child: _SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level badge with its own artwork.
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: level.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        LessonArt(lessonNumber: level.artMotif),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                for (int i = 1; i <= 3; i++)
                                  Container(
                                    width: i <= level.step ? 7 : 5,
                                    height: i <= level.step ? 7 : 5,
                                    margin: const EdgeInsets.only(right: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                        i <= level.step ? 0.95 : 0.45,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (finished)
                          Container(
                            color: Colors.black.withOpacity(0.2),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LEVEL ${level.step}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: accent,
                            ),
                          ),
                          if (isCurrent && !finished) ...[
                            const SizedBox(width: 6),
                            _Pulse(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  started ? 'NOW' : 'START HERE',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _muted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (!empty)
                        Text(
                          '${level.lessons.length} lessons  ·  '
                          '${level.minutes} min  ·  '
                          '${level.quizCount} quizzes',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (empty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Text('🚧', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Unlocked! Lessons are being written.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _darken(_amber, 0.25),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => LinearProgressIndicator(
                              value: v,
                              minHeight: 7,
                              backgroundColor: accent.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$sectionsDone of $total parts done',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _PushButton(
                    onTap: onTap,
                    color: accent,
                    depth: 4,
                    radius: 13,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          finished
                              ? 'Review'
                              : started
                              ? 'Continue'
                              : 'Start',
                          style: const TextStyle(fontSize: 13.5),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          finished
                              ? Icons.replay_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A level the learner has not reached yet. It still shows what is inside,
/// so there is something to look forward to.
class _LockedLevelCard extends StatelessWidget {
  final LearningLevel level;
  final LearningLevel previousLevel;
  const _LockedLevelCard({required this.level, required this.previousLevel});

  @override
  Widget build(BuildContext context) {
    return _Bouncy(
      onTap: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Finish ${previousLevel.name} to open ${level.name}.',
              ),
            ),
          );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greyed banner.
            SizedBox(
              height: 92,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: LessonArt(
                      lessonNumber: level.artMotif,
                      opacity: 0.6,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 14,
                    child: _LevelDots(step: level.step, dim: true),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 14,
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          level.name,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.tagline,
                    style: TextStyle(
                      color: _ink.withOpacity(0.6),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: purple.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded, size: 18, color: purple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Finish ${previousLevel.name} to unlock this.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: purple,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
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
}

/// Three dots showing which rung of the ladder a level sits on.
class _LevelDots extends StatelessWidget {
  final int step; // 1, 2 or 3
  final bool dim;
  const _LevelDots({required this.step, this.dim = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(dim ? 0.2 : 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 1; i <= 3; i++) ...[
            Container(
              width: i <= step ? 8 : 6,
              height: i <= step ? 8 : 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(i <= step ? 0.95 : 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ],
          const SizedBox(width: 6),
          Text(
            'Level $step',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LEVEL LESSON LIST — the lessons inside one level
// ═════════════════════════════════════════════════════════════════════════════
class LevelLessonsScreen extends StatefulWidget {
  final LearningLevel level;
  final VoidCallback? onStartPractice;
  const LevelLessonsScreen({
    super.key,
    required this.level,
    this.onStartPractice,
  });

  @override
  State<LevelLessonsScreen> createState() => _LevelLessonsScreenState();
}

class _LevelLessonsScreenState extends State<LevelLessonsScreen> {
  final Map<String, int> _done = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final d = <String, int>{};
    for (final l in widget.level.lessons) {
      d[l.id] = await LessonProgress.load(l.id);
    }
    if (mounted) {
      setState(() {
        _done
          ..clear()
          ..addAll(d);
      });
    }
  }

  int _doneFor(Lesson l) => (_done[l.id] ?? 0).clamp(0, l.sections.length);
  bool _isComplete(Lesson l) => _doneFor(l) >= l.sections.length;
  bool _isUnlocked(int i) =>
      !kLockLessons || i == 0 || _isComplete(widget.level.lessons[i - 1]);

  Future<void> _openLesson(Lesson lesson) async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      _route(
        LessonDetailScreen(
          lesson: lesson,
          onStartPractice: widget.onStartPractice,
        ),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final lv = widget.level;
    final lessons = lv.lessons;

    final doneSections = lessons.fold<int>(0, (s, l) => s + _doneFor(l));
    final progress = lv.totalSections == 0
        ? 0.0
        : (doneSections / lv.totalSections).clamp(0.0, 1.0);

    Lesson? current;
    for (int i = 0; i < lessons.length; i++) {
      if (_isUnlocked(i) && !_isComplete(lessons[i])) {
        current = lessons[i];
        break;
      }
    }

    return Scaffold(
      backgroundColor: _bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 12,
                20,
                56,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: lv.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: LessonArt(lessonNumber: lv.artMotif, opacity: 0.7),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          _LevelDots(step: lv.step),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        lv.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lv.tagline,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lessons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 14),
                for (int i = 0; i < lessons.length; i++) ...[
                  if (_isUnlocked(i))
                    _LessonCard(
                      lesson: lessons[i],
                      done: _doneFor(lessons[i]),
                      isCurrent: identical(lessons[i], current),
                      onTap: () => _openLesson(lessons[i]),
                    )
                  else
                    _LockedLessonCard(
                      lesson: lessons[i],
                      previousNumber: lessons[i - 1].number,
                    ),
                  const SizedBox(height: 14),
                ],
                _LevelGoalCard(
                  level: lv,
                  lessonsDone: lessons.where(_isComplete).length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<List<String>> _wordsOfDay = [
  ['Salamat', 'Thank you'],
  ['Balay', 'House'],
  ['Tubig', 'Water'],
  ['Yuhum', 'Smile'],
  ['Matahom', 'Beautiful'],
  ['Ngalan', 'Name'],
  ['Palihog', 'Please'],
  ['Kan-on', 'Cooked rice'],
  ['Tuig', 'Year'],
  ['Babayi', 'Woman'],
  ['Manunudlo', 'Teacher'],
  ['Tawo', 'Person'],
];

class _WordOfDayCard extends StatefulWidget {
  const _WordOfDayCard();

  @override
  State<_WordOfDayCard> createState() => _WordOfDayCardState();
}

class _WordOfDayCardState extends State<_WordOfDayCard> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final idx = now.difference(DateTime(now.year)).inDays % _wordsOfDay.length;
    final word = _wordsOfDay[idx];

    return _Bouncy(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _show = !_show);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _amber.withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _amber.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Word of the day',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word[0],
                    style: const TextStyle(
                      color: purple,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: _show
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const Text(
                      'Guess the meaning, then tap to check',
                      style: TextStyle(color: _muted, fontSize: 12.5),
                    ),
                    secondChild: Text(
                      word[1],
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _show ? Icons.visibility_off_rounded : Icons.touch_app_rounded,
              color: _amber,
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner gradient per lesson so each card looks distinct.
List<Color> _lessonGradient(int number) {
  switch (number % 3) {
    case 1:
      return const [purple, pink500];
    case 2:
      return const [purple600, teal300];
    default:
      return const [pink500, _amber];
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int done;
  final bool isCurrent;
  final VoidCallback onTap;
  const _LessonCard({
    required this.lesson,
    required this.done,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = lesson.sections.length;
    final progress = (done / total).clamp(0.0, 1.0);
    final completed = done >= total;
    final started = done > 0;
    final accent = completed ? teal300 : purple;

    return _Bouncy(
      onTap: onTap,
      scale: 0.985,
      child: _SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: text on the left, artwork on the right ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LESSON ${lesson.number}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: accent,
                            ),
                          ),
                          if (completed) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: teal300,
                            ),
                          ] else if (isCurrent) ...[
                            const SizedBox(width: 6),
                            _Pulse(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: purple,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Text(
                                  'NOW',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Everything the old chips said, in one quiet line.
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 12,
                            color: _muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$total parts',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '  ·  ',
                            style: TextStyle(fontSize: 11.5, color: _muted),
                          ),
                          Icon(Icons.schedule_rounded, size: 12, color: _muted),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.minutes} min',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (examFor(lesson.id).isNotEmpty) ...[
                            const Text(
                              '  ·  ',
                              style: TextStyle(fontSize: 11.5, color: _muted),
                            ),
                            const Icon(
                              Icons.extension_rounded,
                              size: 12,
                              color: pink500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'quiz',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: pink500,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Thumbnail, the same art the banner used to show.
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _lessonGradient(lesson.number),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        LessonArt(lessonNumber: lesson.number),
                        if (completed)
                          Container(
                            color: Colors.black.withOpacity(0.18),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Bottom: progress and one button ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v,
                            minHeight: 7,
                            backgroundColor: purple.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        completed ? 'Tapos na!' : '$done of $total parts done',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: completed ? teal300 : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PushButton(
                  onTap: onTap,
                  color: accent,
                  depth: 4,
                  radius: 13,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        completed
                            ? 'Review'
                            : started
                            ? 'Continue'
                            : 'Start',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        completed
                            ? Icons.replay_rounded
                            : Icons.arrow_forward_rounded,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A real lesson that exists but is still locked.
class _LockedLessonCard extends StatelessWidget {
  final Lesson lesson;
  final int previousNumber;
  const _LockedLessonCard({required this.lesson, required this.previousNumber});

  @override
  Widget build(BuildContext context) {
    return _Bouncy(
      onTap: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Finish Lesson $previousNumber first to unlock '
                'Lesson ${lesson.number}.',
              ),
            ),
          );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade500,
                        BlendMode.srcIn,
                      ),
                      child: LessonArt(lessonNumber: lesson.number),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson ${lesson.number}: ${lesson.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _ink.withOpacity(0.65),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Finish Lesson $previousNumber to unlock',
                    style: const TextStyle(color: _muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom of a level's lesson list: how far the learner is from finishing
/// the level, and what finishing it opens.
class _LevelGoalCard extends StatelessWidget {
  final LearningLevel level;
  final int lessonsDone;
  const _LevelGoalCard({required this.level, required this.lessonsDone});

  @override
  Widget build(BuildContext context) {
    final total = level.lessons.length;
    final done = lessonsDone >= total;
    final li = learningLevels.indexOf(level);
    final next = li >= 0 && li + 1 < learningLevels.length
        ? learningLevels[li + 1]
        : null;
    final left = total - lessonsDone;

    final String text;
    if (done) {
      text = next != null
          ? '${level.name} complete. ${next.name} is open on the home screen.'
          : 'You finished every level. Husto gid!';
    } else {
      final lessonsLeft = left == 1 ? '1 more lesson' : '$left more lessons';
      text = next != null
          ? 'Finish $lessonsLeft to open ${next.name}.'
          : 'Finish $lessonsLeft to complete the course.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done ? teal300.withOpacity(0.12) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done ? teal300.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (done ? teal300 : purple).withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              done ? '🏅' : '🎯',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$lessonsDone of $total lessons done',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2) DETAIL SCREEN — objectives, section path, CTA
// ═════════════════════════════════════════════════════════════════════════════
class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onStartPractice;
  const LessonDetailScreen({
    super.key,
    required this.lesson,
    this.onStartPractice,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _done = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final d = await LessonProgress.load(widget.lesson.id);
    if (mounted) setState(() => _done = d);
  }

  Future<void> _openReader(int startAt) async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      _route(
        LessonReaderScreen(
          lesson: widget.lesson,
          startIndex: startAt,
          onFinish: widget.onStartPractice,
        ),
      ),
    );
    _refresh();
  }

  Future<void> _openQuiz() async {
    final exam = examFor(widget.lesson.id);
    if (exam.isEmpty) return;
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      _route(
        LessonQuizScreen(
          lesson: widget.lesson,
          questions: exam,
          onPractice: widget.onStartPractice,
          isRetake: true,
        ),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final total = l.sections.length;
    final completed = _done >= total;
    final started = _done > 0;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(36),
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 12,
                      20,
                      52,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [purple900, purple600],
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -80,
                          top: 40,
                          child: _Blob(
                            size: 180,
                            color: pink500.withOpacity(0.18),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _CircleIconButton(
                                  icon: Icons.arrow_back_rounded,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const Spacer(),
                                _Pill(label: l.level, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: LessonArt(lessonNumber: l.number),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Lesson ${l.number}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SoftCard(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 6,
                          ),
                          child: Row(
                            children: [
                              _Stat(value: '$total', label: 'Sections'),
                              _divider(),
                              _Stat(value: '${l.minutes}m', label: 'Duration'),
                              _divider(),
                              _Stat(value: '${l.quizCount}', label: 'Checks'),
                              _divider(),
                              _Stat(
                                value: '${_done.clamp(0, total)}/$total',
                                label: 'Done',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SectionLabel('In this lesson'),
                        const SizedBox(height: 12),
                        _SoftCard(
                          child: Column(
                            children: [
                              for (int i = 0; i < l.objectives.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i == l.objectives.length - 1
                                        ? 0
                                        : 14,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: teal300.withOpacity(0.18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          size: 15,
                                          color: teal300,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          l.objectives[i],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.45,
                                            color: _ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        const _SectionLabel('Your path'),
                        const SizedBox(height: 14),
                        for (int i = 0; i < l.sections.length; i++)
                          _PathNode(
                            index: i,
                            section: l.sections[i],
                            isDone: i < _done,
                            isCurrent: i == _done && !completed,
                            isLast: i == l.sections.length - 1,
                            onTap: () => _openReader(i),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CTA
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: completed && examFor(l.id).isNotEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: _PushButton(
                          onTap: () => _openReader(0),
                          color: Colors.white,
                          foreground: purple,
                          border: purple.withOpacity(0.4),
                          child: const Text('Review'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _PushButton(
                          onTap: _openQuiz,
                          color: pink500,
                          child: const Text('🧩  Take the quiz'),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: _PushButton(
                      onTap: () => _openReader(
                        completed ? 0 : _done.clamp(0, total - 1),
                      ),
                      color: completed ? teal300 : purple,
                      child: Text(
                        completed
                            ? 'Review lesson'
                            : started
                            ? 'Ituloy ang aralin'
                            : 'Magsimula',
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.2));
}

class _PathNode extends StatelessWidget {
  final int index;
  final LessonSection section;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  final VoidCallback onTap;
  const _PathNode({
    required this.index,
    required this.section,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = isDone || isCurrent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                _Pulse(
                  active: isCurrent,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCurrent
                          ? const LinearGradient(colors: [purple, purple600])
                          : null,
                      color: isDone
                          ? teal300
                          : isCurrent
                          ? null
                          : Colors.white,
                      border: active
                          ? null
                          : Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 2,
                            ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: purple.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : section.icon,
                      color: active ? Colors.white : Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 4,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isDone
                            ? teal300.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: _Bouncy(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent
                          ? purple.withOpacity(0.55)
                          : Colors.grey.withOpacity(0.12),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Part ${index + 1}, ${section.minutes} min',
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                  ),
                                ),
                                if (section.hasQuiz) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _amber.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '⚡ Quick check',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: _darken(_amber, 0.2),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isDone)
                        const Icon(Icons.check_circle_rounded, color: teal300)
                      else if (isCurrent)
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          color: purple,
                        )
                      else
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3) READER SCREEN — paged content, live XP counter, push buttons
// ═════════════════════════════════════════════════════════════════════════════
class LessonReaderScreen extends StatefulWidget {
  final Lesson lesson;
  final int startIndex;
  final VoidCallback? onFinish;
  const LessonReaderScreen({
    super.key,
    required this.lesson,
    this.startIndex = 0,
    this.onFinish,
  });

  @override
  State<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends State<LessonReaderScreen> {
  late final PageController _controller;
  late int _index;
  int _xp = 0; // XP earned in this session
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _total => widget.lesson.sections.length;
  bool get _isLast => _index == _total - 1;

  void _go(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _award(int n) async {
    await Gamify.addXp(n);
    if (!mounted) return;
    setState(() => _xp += n);
  }

  Future<void> _next() async {
    if (_busy) return;
    _busy = true;
    try {
      final id = widget.lesson.id;
      await LessonProgress.save(id, _index + 1);
      await Gamify.touch();
      if (await Gamify.claim('sec:$id:$_index')) await _award(5);

      if (_isLast) {
        if (await Gamify.claim('done:$id')) await _award(20);
        if (!mounted) return;

        // Reading is done. Go to the end-of-lesson quiz if this lesson has one.
        final exam = examFor(id);
        if (exam.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            _route(
              LessonQuizScreen(
                lesson: widget.lesson,
                questions: exam,
                sessionXp: _xp,
                onPractice: widget.onFinish,
              ),
            ),
          );
          return;
        }

        final streak = await Gamify.streak();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          _route(
            LessonCompleteScreen(
              lesson: widget.lesson,
              xpEarned: _xp,
              streak: streak,
              onPractice: widget.onFinish,
            ),
          ),
        );
        return;
      }
      _go(_index + 1);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.lesson.sections;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: _muted),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(_total, (i) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: i == _index ? 8 : 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i < _index
                                  ? teal300
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, a) => ScaleTransition(
                      scale: CurvedAnimation(
                        parent: a,
                        curve: Curves.easeOutBack,
                      ),
                      child: child,
                    ),
                    child: Container(
                      key: ValueKey(_xp),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _amber.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⚡ $_xp',
                        style: TextStyle(
                          color: _darken(_amber, 0.2),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _total,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _SectionPage(
                  lesson: widget.lesson,
                  section: sections[i],
                  index: i,
                  total: _total,
                  onXp: _award,
                ),
              ),
            ),

            // Bottom nav
            Container(
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
              child: Row(
                children: [
                  if (_index > 0) ...[
                    _PushButton(
                      onTap: () => _go(_index - 1),
                      color: Colors.white,
                      foreground: _muted,
                      border: Colors.grey.withOpacity(0.3),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _PushButton(
                      onTap: _next,
                      color: _isLast ? pink500 : purple,
                      child: Text(
                        _isLast ? '🧠  Tapusin & mag-practice' : 'Susunod',
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
}

class _SectionPage extends StatelessWidget {
  final Lesson lesson;
  final LessonSection section;
  final int index;
  final int total;
  final Future<void> Function(int xp) onXp;
  const _SectionPage({
    required this.lesson,
    required this.section,
    required this.index,
    required this.total,
    required this.onXp,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [purple, purple600]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: purple.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(section.icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson ${lesson.number}, part ${index + 1} of $total',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        for (final b in section.blocks) ...[
          _BlockView(block: b, onXp: onXp),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4) COMPLETION SCREEN — confetti, XP and streak summary
// ═════════════════════════════════════════════════════════════════════════════
class LessonCompleteScreen extends StatefulWidget {
  final Lesson lesson;
  final int xpEarned;
  final int streak;
  final VoidCallback? onPractice;

  /// Quiz result, when the lesson ended with a quiz.
  final int? quizScore;
  final int? quizTotal;

  const LessonCompleteScreen({
    super.key,
    required this.lesson,
    required this.xpEarned,
    required this.streak,
    this.onPractice,
    this.quizScore,
    this.quizTotal,
  });

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Confetto> _bits;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    const colors = [teal300, pink500, _amber, Colors.white, purple];
    _bits = List.generate(
      90,
      (_) => _Confetto(
        x: r.nextDouble(),
        delay: r.nextDouble() * 0.35,
        speed: 0.7 + r.nextDouble() * 0.6,
        size: 6 + r.nextDouble() * 6,
        spin: (r.nextDouble() - 0.5) * 14,
        sway: 0.5 + r.nextDouble() * 1.5,
        color: colors[r.nextInt(colors.length)],
      ),
    );
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPractice = widget.onPractice != null;

    // Is there a lesson after this one?
    // What this finish unlocks: the next lesson in the level, or, after the
    // last lesson of a level, the next level.
    final level = levelOf(widget.lesson);
    String? unlockText;
    if (level != null) {
      final idx = level.lessons.indexWhere((l) => l.id == widget.lesson.id);
      if (idx >= 0 && idx + 1 < level.lessons.length) {
        final next = level.lessons[idx + 1];
        unlockText = '🔓 Lesson ${next.number} unlocked: ${next.title}';
      } else {
        final li = learningLevels.indexOf(level);
        if (li >= 0 && li + 1 < learningLevels.length) {
          unlockText =
              '🏅 ${level.name} complete! ${learningLevels[li + 1].name} '
              'is now open.';
        } else {
          unlockText = '👑 You finished the whole course. Husto gid!';
        }
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [purple900, purple600],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) =>
                      CustomPaint(painter: _ConfettiPainter(_bits, _c.value)),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  children: [
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: const FilipinianaCheer(size: 200),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Tapos na!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You finished ${widget.lesson.level} Lesson '
                      '${widget.lesson.number}: ${widget.lesson.title}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                    if (unlockText != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          unlockText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        _ResultTile(
                          emoji: '⚡',
                          value: '+${widget.xpEarned}',
                          label: 'XP earned',
                        ),
                        const SizedBox(width: 10),
                        _ResultTile(
                          emoji: '🔥',
                          value: '${widget.streak}',
                          label: widget.streak == 1
                              ? 'Day streak'
                              : 'Days streak',
                        ),
                        const SizedBox(width: 10),
                        if (widget.quizScore != null &&
                            widget.quizTotal != null)
                          _ResultTile(
                            emoji: '✅',
                            value: '${widget.quizScore}/${widget.quizTotal}',
                            label: 'Quiz score',
                          )
                        else
                          _ResultTile(
                            emoji: '📚',
                            value: '${widget.lesson.sections.length}',
                            label: 'Sections',
                          ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: _PushButton(
                        color: Colors.white,
                        foreground: purple,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onPractice?.call();
                        },
                        child: Text(
                          hasPractice ? '🧠  Start practice' : 'Done',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Back to lesson',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _ResultTile({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Confetto {
  final double x, delay, speed, size, spin, sway;
  final Color color;
  const _Confetto({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.spin,
    required this.sway,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetto> bits;
  final double t;
  _ConfettiPainter(this.bits, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bits) {
      final lt = ((t - b.delay) / (1 - b.delay)).clamp(0.0, 1.0);
      if (lt <= 0 || lt >= 1) continue;
      final y = -20 + lt * b.speed * (size.height + 80);
      final x = b.x * size.width + math.sin(lt * math.pi * 2 * b.sway) * 24;
      final paint = Paint()
        ..color = b.color.withOpacity((1 - lt * 0.8).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(lt * b.spin);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: b.size,
            height: b.size * 0.55,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

// ═════════════════════════════════════════════════════════════════════════════
// BLOCK RENDERERS
// ═════════════════════════════════════════════════════════════════════════════
class _BlockView extends StatelessWidget {
  final Block block;
  final Future<void> Function(int xp)? onXp;
  const _BlockView({required this.block, this.onXp});

  @override
  Widget build(BuildContext context) {
    final b = block;
    if (b is SubheadingBlock) {
      return Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: pink500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              b.text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
          ),
        ],
      );
    }
    if (b is ParagraphBlock) {
      return _RichText(
        b.text,
        const TextStyle(fontSize: 15, height: 1.6, color: _ink),
      );
    }
    if (b is BulletsBlock) {
      return _SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < b.items.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == b.items.length - 1 ? 0 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: purple,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RichText(
                        b.items[i],
                        const TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: _ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    if (b is TableBlock) return _TableView(table: b);
    if (b is CalloutBlock) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [b.color.withOpacity(0.16), b.color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: b.color.withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(b.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: _darken(b.color, 0.1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.text,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (b is DialogueBlock) return _DialogueView(dialogue: b);
    if (b is QuizBlock) return _QuizView(quiz: b, onXp: onXp);
    if (b is FlashcardsBlock) return _FlashcardsView(block: b);
    if (b is LetterCardsBlock) return _LetterCardsView(block: b);
    return const SizedBox.shrink();
  }
}

class _TableView extends StatelessWidget {
  final TableBlock table;
  const _TableView({required this.table});

  /// Every table is drawn as a stack of cards, one per row. A real table
  /// cannot fit a phone in portrait, and sideways scrolling hides exactly
  /// the columns that matter, such as the example and its meaning.
  @override
  Widget build(BuildContext context) {
    final h = table.headers;
    if (h.isEmpty || table.rows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int r = 0; r < table.rows.length; r++)
          Padding(
            padding: EdgeInsets.only(
              bottom: r == table.rows.length - 1 ? 0 : 10,
            ),
            child: _rowCard(r),
          ),
      ],
    );
  }

  /// The column used as the card's heading: the Hiligaynon one when it has
  /// something in it, otherwise the first column that does.
  int _leadFor(List<String> row) {
    final want = table.italicColumn.clamp(0, table.headers.length - 1);
    if (want < row.length && row[want].trim().isNotEmpty) return want;
    for (int c = 0; c < row.length; c++) {
      if (row[c].trim().isNotEmpty) return c;
    }
    return 0;
  }

  Widget _rowCard(int r) {
    final h = table.headers;
    final row = table.rows[r];
    final lead = _leadFor(row);

    // The other columns, in order, skipping anything empty.
    final rest = <int>[
      for (int c = 0; c < h.length; c++)
        if (c != lead && c < row.length && row[c].trim().isNotEmpty) c,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading: the word being taught, with the column it came from.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  row[lead],
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: purple,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  h[lead],
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: purple,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.grey.withOpacity(0.12)),
            const SizedBox(height: 10),
            // One line per remaining column: label on the left, value right.
            for (int i = 0; i < rest.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == rest.length - 1 ? 0 : 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 78,
                      child: Text(
                        h[rest[i]].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: _muted,
                          letterSpacing: 0.5,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        row[rest[i]],
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: _ink,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Quick check (multiple choice) ───────────────────────────────────────────
class _QuizView extends StatefulWidget {
  final QuizBlock quiz;
  final Future<void> Function(int xp)? onXp;
  const _QuizView({required this.quiz, this.onXp});

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;
  int? _picked;
  bool _solved = false;
  bool _firstTry = true;
  bool _earned = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _pick(int i) async {
    if (_solved) return;
    final right = i == widget.quiz.answer;
    setState(() {
      _picked = i;
      if (right) _solved = true;
    });
    if (right) {
      HapticFeedback.mediumImpact();
      if (_firstTry && await Gamify.claim('quiz:${widget.quiz.id}')) {
        if (mounted) setState(() => _earned = true);
        await widget.onXp?.call(10);
      }
    } else {
      _firstTry = false;
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _solved ? teal300.withOpacity(0.7) : _amber.withOpacity(0.45),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '⚡ Quick check',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _darken(_amber, 0.2),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _earned
                    ? '+10 XP earned'
                    : _solved
                    ? 'Solved'
                    : '+10 XP on first try',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: _earned ? teal300 : _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RichText(
            q.question,
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _shake,
            builder: (_, child) {
              final v = _shake.value;
              final dx = math.sin(v * math.pi * 6) * 8 * (1 - v);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: Column(
              children: [for (int i = 0; i < q.options.length; i++) _option(i)],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _solved
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: teal300.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RichText(
                            '**Husto!** ${q.explain}',
                            const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: _ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _picked != null
                ? const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Sayop. That one\'s wrong, so try another answer.',
                      style: TextStyle(
                        color: pink500,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _option(int i) {
    final q = widget.quiz;
    final isAnswer = i == q.answer;
    final picked = _picked == i;

    Color border = Colors.grey.withOpacity(0.22);
    Color fill = Colors.white;
    Color badge = purple;
    IconData? trailing;

    if (_solved && isAnswer) {
      border = teal300;
      fill = teal300.withOpacity(0.12);
      badge = teal300;
      trailing = Icons.check_circle_rounded;
    } else if (picked && !isAnswer) {
      border = pink500;
      fill = pink500.withOpacity(0.08);
      badge = pink500;
      trailing = Icons.cancel_rounded;
    }
    final dim = _solved && !isAnswer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Bouncy(
        onTap: () => _pick(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.6),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: dim ? 0.45 : 1,
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
                  child: _RichText(
                    q.options[i],
                    const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                ),
                if (trailing != null) Icon(trailing, color: border, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Letter cards: one big card at a time, swipe through the alphabet ───────
class _LetterCardsView extends StatefulWidget {
  final LetterCardsBlock block;
  const _LetterCardsView({required this.block});

  @override
  State<_LetterCardsView> createState() => _LetterCardsViewState();
}

class _LetterCardsViewState extends State<_LetterCardsView> {
  late final PageController _pages;
  final Set<int> _seen = {0};
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pages = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) {
    final letters = widget.block.letters;
    if (i < 0 || i >= letters.length) return;
    HapticFeedback.selectionClick();
    _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = widget.block.letters;
    final allSeen = _seen.length == letters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.abc_rounded, color: purple, size: 22),
            const SizedBox(width: 8),
            Text(
              widget.block.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
                color: _ink,
              ),
            ),
            const Spacer(),
            Text(
              allSeen
                  ? 'All seen 🎉'
                  : '${_seen.length}/${letters.length} seen',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: allSeen ? teal300 : _muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Swipe through the letters. Say each example word out loud.',
          style: TextStyle(color: _muted, fontSize: 12.5),
        ),
        const SizedBox(height: 12),

        // The deck.
        SizedBox(
          height: 228,
          child: PageView.builder(
            controller: _pages,
            itemCount: letters.length,
            onPageChanged: (i) {
              setState(() {
                _index = i;
                _seen.add(i);
              });
              if (_seen.length == letters.length) {
                HapticFeedback.mediumImpact();
              }
            },
            itemBuilder: (_, i) => _card(letters[i], i),
          ),
        ),

        const SizedBox(height: 12),

        // Prev / next and the position.
        Row(
          children: [
            _arrow(Icons.arrow_back_rounded, _index > 0, () => _go(_index - 1)),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (_index + 1) / letters.length,
                  minHeight: 6,
                  backgroundColor: purple.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(purple),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_index + 1} / ${letters.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _muted,
              ),
            ),
            const SizedBox(width: 10),
            _arrow(
              Icons.arrow_forward_rounded,
              _index < letters.length - 1,
              () => _go(_index + 1),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Jump straight to any letter.
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (int i = 0; i < letters.length; i++)
              _Bouncy(
                onTap: () => _go(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? purple
                        : _seen.contains(i)
                        ? purple.withOpacity(0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: i == _index
                          ? purple
                          : Colors.grey.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    letters[i].letter.split(' ').first,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: i == _index ? Colors.white : purple,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _arrow(IconData icon, bool on, VoidCallback onTap) {
    return GestureDetector(
      onTap: on ? onTap : null,
      child: Opacity(
        opacity: on ? 1 : 0.3,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.25)),
          ),
          child: Icon(icon, size: 18, color: purple),
        ),
      ),
    );
  }

  Widget _card(LetterEntry e, int i) {
    final active = i == _index;
    return AnimatedScale(
      scale: active ? 1 : 0.93,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: purple.withOpacity(0.18), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: purple.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The letter itself, big.
                  Container(
                    width: 74,
                    height: 74,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [purple, purple600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          e.letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CALLED',
                          style: TextStyle(
                            fontSize: 9.5,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"${e.name}"',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: purple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              size: 14,
                              color: _muted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.sound,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: _muted,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // The example word, which is the part worth remembering.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: teal300.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: teal300.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.example,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: purple,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.meaning,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Bouncy(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        LessonAudio.speak?.call(e.example);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: teal300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Flip cards ──────────────────────────────────────────────────────────────
class _FlashcardsView extends StatefulWidget {
  final FlashcardsBlock block;
  const _FlashcardsView({required this.block});

  @override
  State<_FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<_FlashcardsView> {
  final Set<int> _seen = {};

  @override
  Widget build(BuildContext context) {
    final cards = widget.block.cards;
    final allSeen = _seen.length == cards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.style_rounded, color: purple, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.block.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
                color: _ink,
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                allSeen ? 'All flipped 🎉' : '${_seen.length}/${cards.length}',
                key: ValueKey(_seen.length),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: allSeen ? teal300 : _muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Say the word out loud, guess the meaning, then tap to check.',
          style: TextStyle(color: _muted, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (_, c) {
            final w = (c.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < cards.length; i++)
                  SizedBox(
                    width: w,
                    height: 96,
                    child: _FlipCard(
                      front: cards[i].front,
                      back: cards[i].back,
                      onFirstFlip: () {
                        if (_seen.add(i)) {
                          setState(() {});
                          if (_seen.length == cards.length) {
                            HapticFeedback.mediumImpact();
                          }
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  final String front;
  final String back;
  final VoidCallback? onFirstFlip;
  const _FlipCard({required this.front, required this.back, this.onFirstFlip});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _showingFront = true;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.selectionClick();
    if (_showingFront) {
      _c.forward();
      widget.onFirstFlip?.call();
    } else {
      _c.reverse();
    }
    _showingFront = !_showingFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = Curves.easeInOut.transform(_c.value);
          final angle = t * math.pi;
          final backVisible = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: backVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: _face(widget.back, front: false),
                  )
                : _face(widget.front, front: true),
          );
        },
      ),
    );
  }

  Widget _face(String text, {required bool front}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: front
            ? const LinearGradient(
                colors: [purple, purple600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: front ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: front ? null : Border.all(color: teal300, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: (front ? purple : teal300).withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: front ? Colors.white : _ink,
              fontSize: front ? 16.5 : 15,
              fontWeight: FontWeight.w800,
              fontStyle: front ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            front ? 'tap to flip' : 'meaning',
            style: TextStyle(
              color: front ? Colors.white.withOpacity(0.65) : teal300,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialogue: plays out like a chat thread ─────────────────────────────────
class _DialogueView extends StatefulWidget {
  final DialogueBlock dialogue;
  const _DialogueView({required this.dialogue});

  @override
  State<_DialogueView> createState() => _DialogueViewState();
}

class _DialogueViewState extends State<_DialogueView> {
  /// How many lines have arrived so far.
  int _visible = 0;

  /// True while the typing dots are showing, before the next line lands.
  bool _typing = false;

  /// Bumped on replay so an old playback stops writing to a new one.
  int _run = 0;

  final Set<int> _shown = {}; // translations revealed

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void dispose() {
    _run++; // stop any pending steps
    super.dispose();
  }

  /// Plays the thread: typing dots, then the message, one line at a time.
  Future<void> _play() async {
    final token = ++_run;
    setState(() {
      _visible = 0;
      _typing = false;
      _shown.clear();
    });

    final lines = widget.dialogue.lines;
    for (int i = 0; i < lines.length; i++) {
      // Longer lines take longer to "type".
      final chars = lines[i].hiligaynon.length;
      final think = Duration(milliseconds: i == 0 ? 350 : 500);
      final type = Duration(milliseconds: (380 + chars * 22).clamp(500, 1600));

      await Future.delayed(think);
      if (!mounted || token != _run) return;
      setState(() => _typing = true);

      await Future.delayed(type);
      if (!mounted || token != _run) return;
      setState(() {
        _typing = false;
        _visible = i + 1;
      });
      HapticFeedback.selectionClick();
    }
  }

  bool get _finished => _visible == widget.dialogue.lines.length && !_typing;
  bool get _allShown => _shown.length == widget.dialogue.lines.length;

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(() => _shown.contains(i) ? _shown.remove(i) : _shown.add(i));
  }

  void _toggleAll() {
    setState(() {
      if (_allShown) {
        _shown.clear();
      } else {
        _shown.addAll(List.generate(_visible, (i) => i));
      }
    });
  }

  /// Who is on the right: "You", or the first speaker when there is no "You".
  bool _isMe(DialogueLine line) {
    final lines = widget.dialogue.lines;
    final hasYou = lines.any((l) => l.speaker == 'You');
    return hasYou ? line.speaker == 'You' : line.speaker == lines.first.speaker;
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.dialogue.lines;
    final maxW = MediaQuery.of(context).size.width * 0.66;

    // The other person's name, for the chat header.
    final other = lines
        .firstWhere((l) => !_isMe(l), orElse: () => lines.first)
        .speaker;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _header(other),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: [
                for (int i = 0; i < _visible; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Appear(
                      key: ValueKey('$_run-$i'),
                      fromRight: _isMe(lines[i]),
                      child: _bubble(i, lines[i], maxW),
                    ),
                  ),
                if (_typing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _typingRow(
                      _visible < lines.length && _isMe(lines[_visible]),
                    ),
                  ),
                if (_finished) _footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat header, like a messaging app ──
  Widget _header(String other) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: purple.withOpacity(0.06),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: teal300.withOpacity(0.2),
                child: const Text('🧑', style: TextStyle(fontSize: 17)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: teal300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  other,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: _ink,
                  ),
                ),
                Text(
                  _typing
                      ? 'typing…'
                      : _finished
                      ? 'Tap a message to translate'
                      : 'online',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _typing ? purple : _muted,
                  ),
                ),
              ],
            ),
          ),
          if (_finished) ...[
            _headerBtn(
              icon: _allShown
                  ? Icons.visibility_off_rounded
                  : Icons.translate_rounded,
              tooltip: _allShown ? 'Hide translations' : 'Show all',
              onTap: _toggleAll,
            ),
            const SizedBox(width: 6),
            _headerBtn(
              icon: Icons.replay_rounded,
              tooltip: 'Play again',
              onTap: () {
                HapticFeedback.lightImpact();
                _play();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: _Bouncy(
        onTap: onTap,
        scale: 0.88,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 17, color: purple),
        ),
      ),
    );
  }

  // ── The three bouncing dots ──
  Widget _typingRow(bool me) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: me ? purple.withOpacity(0.18) : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(me ? 18 : 4),
          bottomRight: Radius.circular(me ? 4 : 18),
        ),
      ),
      child: _TypingDots(color: me ? purple : _muted),
    );

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: (me ? pink500 : teal300).withOpacity(0.18),
      child: Text(me ? '🙂' : '🧑', style: const TextStyle(fontSize: 14)),
    );

    return Row(
      mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: me
          ? [bubble, const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), bubble],
    );
  }

  // ── Once the thread is done ──
  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: teal300),
          const SizedBox(width: 6),
          Text(
            'Read each line aloud, then tap it to check the English.',
            style: TextStyle(
              fontSize: 11.5,
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── One message ──
  Widget _bubble(int i, DialogueLine line, double maxW) {
    final me = _isMe(line);
    final shown = _shown.contains(i);

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: (me ? pink500 : teal300).withOpacity(0.18),
      child: Text(me ? '🙂' : '🧑', style: const TextStyle(fontSize: 14)),
    );

    final bubble = _Bouncy(
      onTap: () => _toggle(i),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: me ? purple : const Color(0xFFF2EFFA),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(me ? 18 : 4),
              bottomRight: Radius.circular(me ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.hiligaynon,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: me ? Colors.white : purple,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: shown
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 12,
                      color: me ? Colors.white70 : _muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to translate',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: me ? Colors.white70 : _muted,
                      ),
                    ),
                    // A read tick, like a chat app.
                    if (me) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 13,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),
                secondChild: Text(
                  line.english,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: me ? Colors.white.withOpacity(0.85) : _muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: me
          ? [Flexible(child: bubble), const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), Flexible(child: bubble)],
    );
  }
}

/// A message sliding in from its own side as it arrives.
class _Appear extends StatefulWidget {
  final Widget child;
  final bool fromRight;
  const _Appear({super.key, required this.child, required this.fromRight});

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return AnimatedBuilder(
      animation: curve,
      builder: (_, child) {
        final v = curve.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: _c.value,
          child: Transform.translate(
            offset: Offset((1 - v) * (widget.fromRight ? 26 : -26), 0),
            child: Transform.scale(scale: 0.94 + v * 0.06, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Three dots that bounce, the usual "someone is typing" sign.
class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final v = math.sin((_c.value - i / 6) * 2 * math.pi).clamp(0.0, 1.0);
          return Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
            transform: Matrix4.translationValues(0, -v * 4, 0),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.4 + v * 0.6),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED UI BITS
// ═════════════════════════════════════════════════════════════════════════════

/// Chunky 3D button that physically presses down, with haptics.
class _PushButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color foreground;
  final Color? border;
  final EdgeInsetsGeometry padding;
  final double depth;
  final double radius;
  const _PushButton({
    required this.child,
    required this.onTap,
    this.color = purple,
    this.foreground = Colors.white,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.depth = 5,
    this.radius = 16,
  });

  @override
  State<_PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<_PushButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final base = enabled ? widget.color : Colors.grey.shade300;
    final edge = widget.border != null
        ? _darken(widget.border!, 0.05)
        : _darken(base, 0.14);
    final d = widget.depth;

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
        padding: widget.padding,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.border != null
              ? Border.all(color: widget.border!, width: 1.5)
              : null,
          boxShadow: [BoxShadow(color: edge, offset: Offset(0, _down ? 0 : d))],
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: enabled ? widget.foreground : Colors.grey.shade600,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              fontSize: 15.5,
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: enabled ? widget.foreground : Colors.grey.shade600,
                size: 22,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shrinks slightly while pressed, for cards and tiles.
class _Bouncy extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const _Bouncy({required this.child, this.onTap, this.scale = 0.97});

  @override
  State<_Bouncy> createState() => _BouncyState();
}

class _BouncyState extends State<_Bouncy> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) {
        _set(false);
        widget.onTap?.call();
      },
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Gentle breathing scale used to mark "you are here".
class _Pulse extends StatefulWidget {
  final Widget child;
  final bool active;
  const _Pulse({required this.child, this.active = true});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = Tween(
      begin: 1.0,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _Pulse old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _GlassChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String tooltip;
  const _GlassChip({
    required this.emoji,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool solid;
  const _Pill({required this.label, required this.color, this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: solid ? color : color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: solid ? null : Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: solid ? purple : color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: _ink,
    ),
  );
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Bouncy(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      scale: 0.9,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

/// Tiny inline markup: **bold** and _italic_.
class _RichText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _RichText(this.text, this.style);

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
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
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

/// Backwards-compatible alias.
typedef LessonModuleScreen = LibraryScreen;
