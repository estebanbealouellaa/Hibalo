// GENERATED from Hibalo-Learning_Module_Curriculum_Shortened.docx.
// Edit the source document and re-run the generator rather than editing
// this file by hand, or your changes will be overwritten.
//
// Beginner lessons 1 and 2 stay hand-written in library_screen.dart.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/library_screen.dart';

const Lesson beginnerLesson3 = Lesson(
  id: 'beginner_3',
  number: 3,
  title: 'Introducing Yourself',
  subtitle: 'Ask and answer questions about name, origin, age, and occupation.',
  emoji: '🤝',
  level: 'Beginner',
  objectives: [
    'Ask and answer questions about name, origin, age, and occupation.',
    'Give a short, natural self-introduction and ask the other person follow-up questions.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'A good introduction follows a natural order: greeting, name, origin, work or study, and a question back. Adjust it to the listener, using _ho_ and _kamo_ with elders.',
        ),
      ],
    ),
    LessonSection(
      title: 'Asking and giving a name',
      icon: Icons.badge_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Ano ang imo ngalan?',
              'Ano ang pangalan mo?',
              'What is your name?',
            ],
            [
              'Ang ngalan ko amo si Ana.',
              'Ang pangalan ko ay Ana.',
              'My name is Ana.',
            ],
            ['Ako si Ana.', 'Ako si Ana.', 'I\'m Ana.'],
            [
              'Ano ang ngalan ninyo?',
              'Ano po ang pangalan ninyo?',
              'What is your name? (polite)',
            ],
          ],
        ),
        ParagraphBlock(
          '_Ngalan_ is "name." _Imo_ is "your" (before the noun). _Amo_ means "that\'s it / that is" and _Ang ngalan ko amo si..._ literally says "My name, that is Ana." It is the classic full-sentence way to introduce yourself; the short _Ako si Ana_ is also natural.',
        ),
        QuizBlock(
          id: 'beginner_3_qc1',
          question: 'What does _Ano ang imo ngalan?_ mean in English?',
          options: [
            'My name is Ana.',
            'What is your name? (polite)',
            'What is your name?',
          ],
          answer: 2,
          explain: '_Ano ang imo ngalan?_ = What is your name?.',
        ),
      ],
    ),
    LessonSection(
      title: 'Origin: taga-',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('_Taga-_ plus a place means "from (that place)."'),
        BulletsBlock([
          '_Taga-diin ka?_ (Where are you from?)',
          '_Taga-Iloilo ako._ (I\'m from Iloilo.)',
          '_Taga-Bacolod siya._ (She/he is from Bacolod.)',
        ]),
        ParagraphBlock(
          'Another common question is _Diin ka gikan?_ ("Where do you come from?"), which is usually about where you are coming from _right now_.',
        ),
      ],
    ),
    LessonSection(
      title: 'Age',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('Age is asked with _pila_ (how many):'),
        BulletsBlock([
          '_Pila ka tuig ka na?_ (How old are you? literally, "how many years are you already?")',
          '_Baynte anyos na ako._ (I am already twenty.)',
          '_Duha ka pulo kag lima ka tuig na ako._ (I am twenty-five years old.)',
        ]),
        ParagraphBlock(
          'The Spanish-derived numbers (_baynte_, _trenta_, _kwarenta_) are extremely common for age. You will study both number systems in Lesson 4.',
        ),
      ],
    ),
    LessonSection(
      title: 'Occupation and study',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '_Ano ang imo trabaho?_ (What is your work?)',
          '_Doktor ako._ / _Nars ako._ / _Manunudlo ako._ (I am a doctor / nurse / teacher.)',
          '_Nagaeskwela ako._ (I am studying, I am in school.)',
          '_Nagatrabaho ako sa opisina._ (I work in an office.)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Building a full introduction',
      icon: Icons.badge_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('A natural, four-part self-introduction:'),
        BulletsBlock([
          '1. Greeting: _Maayong aga!_',
          '2. Name: _Ang ngalan ko amo si Ana._',
          '3. Origin: _Taga-Iloilo ako._',
          '4. Work or study + question: _Estudyante ako. Ikaw man?_',
        ]),
        ParagraphBlock(
          'Together: _Maayong aga! Ang ngalan ko amo si Ana. Taga-Iloilo ako. Estudyante ako. Ikaw man?_',
        ),
      ],
    ),
    LessonSection(
      title: 'Vocabulary',
      icon: Icons.translate_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['edad', 'edad', 'age'],
            ['eskwelahan', 'paaralan', 'school'],
            ['higala', 'kaibigan', 'friend'],
            ['kalipay', 'kasiyahan', 'joy / happiness'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('edad', 'age'),
          Flashcard('eskwelahan', 'school'),
          Flashcard('higala', 'friend'),
          Flashcard('kalipay', 'joy / happiness'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_3_qc6',
          question: 'What does _kalipay_ mean in English?',
          options: ['joy / happiness', 'friend', 'age'],
          answer: 0,
          explain: '_kalipay_ = joy / happiness.',
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
              'Ano ang imo ngalan? — Ako si Ana.',
              'Ano ang pangalan mo? — Ako si Ana.',
              'What is your name? — I\'m Ana.',
            ],
            [
              'Taga-diin ka? — Taga-Iloilo ako.',
              'Taga-saan ka? — Taga-Iloilo ako.',
              'Where are you from? — I\'m from Iloilo.',
            ],
            [
              'Pila ka tuig ka na? — Baynte na ako.',
              'Ilang taon ka na? — Dalawampu na ako.',
              'How old are you? — I\'m twenty.',
            ],
            [
              'Ano ang imo trabaho? — Nars ako.',
              'Ano ang trabaho mo? — Nars ako.',
              'What is your job? — I am a nurse.',
            ],
            ['Ikaw man?', 'Ikaw naman?', 'And you?'],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Each answer follows the same pattern: description first, then _ako_. _Na_ in _Pila ka tuig ka na?_ means "already," and _man_ in _Ikaw man?_ means "also," a common way to turn the question back to the other person.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'The Philippines has a strong tradition of "where are you from?" as a first question, because your hometown says a lot about your accent, food, and family. In Panay and Negros, taga-Iloilo, taga-Capiz, taga-Bacolod, and taga-Guimaras are all understood immediately.',
        ),
        QuizBlock(
          id: 'beginner_3_qc7',
          question:
              'What does _Taga-diin ka? — Taga-Iloilo ako._ mean in English?',
          options: [
            'How old are you? — I\'m twenty.',
            'And you?',
            'Where are you from? — I\'m from Iloilo.',
          ],
          answer: 2,
          explain:
              '_Taga-diin ka? — Taga-Iloilo ako._ = Where are you from? — I\'m from Iloilo..',
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
          '_Ngalan_ corresponds to Filipino _pangalan_, and the shared root is the same _ngalan_, but Hiligaynon drops _pa-_.',
          '_Imo_ can mean "your" before a noun (_imo ngalan_), while _mo_ follows a noun (_ngalan mo_).',
          '_Taga-_ is the same prefix in both languages.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Translating _Ang pangalan ko ay Ana_ word for word: _Ang ngalan ko ay Ana_ is not natural. Use _amo si_.',
          'Using _ikaw_ where _ka_ is needed (_Taga-diin ikaw?_ sounds off; say _Taga-diin ka?_).',
          'Forgetting _ka_ in _Pila ka tuig ka na?_ (the first _ka_ is the counting linker; the second is "you").',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you introduce yourself in four sentences without reading?',
          'Can you ask someone their name, origin, age, and job?',
          'Can you explain the meaning of _na_ in _Pila ka tuig ka na?_',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson4 = Lesson(
  id: 'beginner_4',
  number: 4,
  title: 'Numbers and Counting',
  subtitle: 'Count from 1 to 100 and beyond with the native system.',
  emoji: '🔢',
  level: 'Beginner',
  objectives: [
    'Count from 1 to 100 and beyond with the native system.',
    'Recognize and use the Spanish-derived system for money, time, and age.',
    'Use ordinal numbers, counting words, and simple fractions.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Hiligaynon has two number systems: the **native** one for counting people and things, and the **Spanish-derived** one for time, money, and age. You need both.',
        ),
      ],
    ),
    LessonSection(
      title: 'The basic numbers, 1 to 10',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: [
            'Number',
            'Native Hiligaynon',
            'Spanish-derived',
            'Filipino',
          ],
          italicColumn: 1,
          rows: [
            ['1', 'isa', 'uno', 'isa'],
            ['2', 'duha', 'dos', 'dalawa'],
            ['3', 'tatlo', 'tres', 'tatlo'],
            ['4', 'apat', 'kwatro', 'apat'],
            ['5', 'lima', 'singko', 'lima'],
            ['6', 'anom', 'sais', 'anim'],
            ['7', 'pito', 'siyete', 'pito'],
            ['8', 'walo', 'otso', 'walo'],
            ['9', 'siyam', 'nwebe', 'siyam'],
            ['10', 'napulo', 'dies', 'sampu'],
          ],
        ),
        QuizBlock(
          id: 'beginner_4_qc1',
          question: 'What does _tatlo_ mean in Filipino?',
          options: ['dalawa', 'pito', 'tatlo'],
          answer: 2,
          explain: '_tatlo_ = tatlo.',
        ),
      ],
    ),
    LessonSection(
      title: 'The counting linker ka',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'When you count a noun, the number is followed by **ka**, then the noun:',
        ),
        BulletsBlock([
          '_isa ka libro_ (one book)',
          '_duha ka bata_ (two children)',
          '_tatlo ka manok_ (three chickens)',
          '_napulo ka pesos_ (ten pesos)',
        ]),
        ParagraphBlock(
          'Do not confuse this _ka_ with the pronoun _ka_ ("you"): _Pila ka bata?_ means "How many children?" while _Pila ka na?_ would be "How many are you now?"',
        ),
      ],
    ),
    LessonSection(
      title: 'Numbers 11 to 19',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Hiligaynon builds them with _napulo kag_ ("ten and") plus the unit:',
        ),
        TableBlock(
          headers: ['Number', 'Hiligaynon'],
          italicColumn: 1,
          rows: [
            ['11', 'napulo kag isa'],
            ['12', 'napulo kag duha'],
            ['13', 'napulo kag tatlo'],
            ['14', 'napulo kag apat'],
            ['15', 'napulo kag lima'],
            ['16', 'napulo kag anom'],
            ['17', 'napulo kag pito'],
            ['18', 'napulo kag walo'],
            ['19', 'napulo kag siyam'],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Tens, 20 to 90',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Tens are formed with the number, _ka_, and _pulo_ ("ten"):',
        ),
        TableBlock(
          headers: ['Number', 'Native', 'Spanish-derived'],
          italicColumn: -1,
          rows: [
            ['20', 'duha ka pulo', 'baynte'],
            ['30', 'tatlo ka pulo', 'trenta'],
            ['40', 'apat ka pulo', 'kwarenta'],
            ['50', 'lima ka pulo', 'singkwenta'],
            ['60', 'anom ka pulo', 'sesenta'],
            ['70', 'pito ka pulo', 'sitenta'],
            ['80', 'walo ka pulo', 'otsenta'],
            ['90', 'siyam ka pulo', 'nobenta'],
          ],
        ),
        ParagraphBlock(
          'Combine tens and units with _kag_: _duha ka pulo kag isa_ (21), _apat ka pulo kag lima_ (45), _siyam ka pulo kag siyam_ (99).',
        ),
      ],
    ),
    LessonSection(
      title: 'Hundreds, thousands, and larger numbers',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Number', 'Hiligaynon'],
          italicColumn: 1,
          rows: [
            ['100', 'isa ka gatos'],
            ['200', 'duha ka gatos'],
            ['500', 'lima ka gatos'],
            ['1,000', 'isa ka libo'],
            ['2,500', 'duha ka libo kag lima ka gatos'],
            ['1,000,000', 'isa ka milyon'],
          ],
        ),
        ParagraphBlock(
          'Spanish-derived hundreds (_siyento_, _dos siyentos_, _kinyentos_) and _mil_ are also used, especially for prices: _singko siyentos_ (five hundred).',
        ),
      ],
    ),
    LessonSection(
      title: 'Zero, half, and ordinals',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**Zero**: _wala_ (none) or _sero_.',
          '**Half**: _tunga_ or _katunga_.',
          '**Ordinals**: _una_ (first), _ikaduha_ (second), _ikatlo_ (third), _ikap-at_ (fourth), _ikalima_ (fifth). The prefix **ika-** plus the number makes an ordinal.',
          '**Once, twice**: _makaisa_ (once), _makaduha_ (twice), _makatlo_ (three times).',
          '**Each**: _tag-isa_ (one each), _tag-duha_ (two each).',
        ]),
      ],
    ),
    LessonSection(
      title: 'Which system should I use?',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Situation', 'Usual system', 'Example'],
          italicColumn: -1,
          rows: [
            ['Counting people or objects', 'Native', 'tatlo ka bata'],
            ['Age', 'Spanish (very common)', 'baynte anyos'],
            ['Money and prices', 'Spanish (very common)', 'trenta pesos'],
            ['Clock time', 'Spanish', 'alas-dos'],
            ['Dates', 'Spanish', 'Enero singko (January 5)'],
            [
              'Phone numbers',
              'Digit by digit, often Spanish',
              'nwebe-singko...',
            ],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Vocabulary',
      icon: Icons.translate_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['kwarta', 'pera', 'money'],
            ['sentimo', 'sentimo', 'centavo'],
            ['madamo', 'marami', 'many / much'],
            ['kadyot / gamay', 'kaunti', 'a little / few'],
            ['tanan', 'lahat', 'all'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('kwarta', 'money'),
          Flashcard('sentimo', 'centavo'),
          Flashcard('madamo', 'many / much'),
          Flashcard('kadyot / gamay', 'a little / few'),
          Flashcard('tanan', 'all'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_4_qc8',
          question: 'What does _madamo_ mean in English?',
          options: ['many / much', 'a little / few', 'centavo'],
          answer: 0,
          explain: '_madamo_ = many / much.',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Isa ka libro, duha ka lapis.',
              'Isang libro, dalawang lapis.',
              'One book, two pencils.',
            ],
            [
              'Napulo kag isa ka estudyante.',
              'Labing-isang estudyante.',
              'Eleven students.',
            ],
            [
              'Duha ka pulo kag apat ka manok.',
              'Dalawampu\'t apat na manok.',
              'Twenty-four chickens.',
            ],
            [
              'Pila ka bata ang ara?',
              'Ilang bata ang nandiyan?',
              'How many children are there?',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** The first rows use the native system with _ka_ before the noun; _kag_ ("and") joins tens and units only. The price uses Spanish-derived _trenta_, as most speakers do in the market, and _ika-_ makes ordinals. Don\'t mix systems inside one number; pick one.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Native isa, duha, tatlo, apat, lima are shared across many Philippine languages, but Hiligaynon differs from Cebuano for some numbers: Hiligaynon isa / tatlo / apat / anom correspond to Cebuano usa / tulo / upat / unom. If you can count in Hiligaynon, you already understand a lot of Cebuano number words, and vice versa, but the shapes differ.',
        ),
        QuizBlock(
          id: 'beginner_4_qc9',
          question:
              'What does _Napulo kag isa ka estudyante._ mean in English?',
          options: [
            'Twenty-four chickens.',
            'How many children are there?',
            'Eleven students.',
          ],
          answer: 2,
          explain: '_Napulo kag isa ka estudyante._ = Eleven students..',
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
          'Filipino has _dalawa_, _anim_, _sampu_; Hiligaynon has _duha_, _anom_, _napulo_. Learn these three first because they are the most different.',
          'Filipino links number and noun with **-ng/na** (_dalawang bata_); Hiligaynon uses **ka** (_duha ka bata_).',
          'Filipino _labing-isa_ (11) becomes _napulo kag isa_ in Hiligaynon.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Leaving out _ka_ (_duha bata_) or using _na/ng_ instead.',
          'Mixing native and Spanish parts in one number.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you count to 20 and by tens to 100 in the native system?',
          'Can you say 45 in both systems?',
          'Can you ask and answer the price of an item?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson5 = Lesson(
  id: 'beginner_5',
  number: 5,
  title: 'Time, Days, Months & the Calendar',
  subtitle: 'Name the seven days and twelve months.',
  emoji: '📅',
  level: 'Beginner',
  objectives: [
    'Name the seven days and twelve months.',
    'Tell the time, use parts of the day, and talk about today, tomorrow, and yesterday.',
    'Understand how dates and greetings for holidays are expressed.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Time words mix native terms (_adlaw_, _simana_, _bulan_) with Spanish-derived day names, month names, and clock hours. Together they let you make plans and greet people on special days.',
        ),
      ],
    ),
    LessonSection(
      title: 'Units of time',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['segundo', 'segundo', 'second'],
            ['minuto', 'minuto', 'minute'],
            ['oras', 'oras', 'hour / time'],
            ['adlaw', 'araw', 'day (also "sun")'],
            ['simana', 'linggo', 'week'],
            ['bulan', 'buwan', 'month (also "moon")'],
            ['tuig', 'taon', 'year'],
          ],
        ),
        ParagraphBlock(
          '_Adlaw_ means both "day" and "sun," and _bulan_ means both "month" and "moon," a reminder of the old timekeeping by sun and moon. Note that Hiligaynon uses _simana_ for "week," since Filipino _linggo_ also means "Sunday" and Hiligaynon uses _Domingo_ for that.',
        ),
        FlashcardsBlock([
          Flashcard('segundo', 'second'),
          Flashcard('minuto', 'minute'),
          Flashcard('oras', 'hour / time'),
          Flashcard('adlaw', 'day (also "sun")'),
          Flashcard('simana', 'week'),
          Flashcard('bulan', 'month (also "moon")'),
          Flashcard('tuig', 'year'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_5_qc1',
          question: 'What does _segundo_ mean in English?',
          options: ['second', 'minute', 'year'],
          answer: 0,
          explain: '_segundo_ = second.',
        ),
      ],
    ),
    LessonSection(
      title: 'Days of the week',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['English', 'Hiligaynon', 'Filipino'],
          italicColumn: 1,
          rows: [
            ['Sunday', 'Domingo', 'Linggo'],
            ['Monday', 'Lunes', 'Lunes'],
            ['Tuesday', 'Martes', 'Martes'],
            ['Wednesday', 'Miyerkoles (also Miyerkules)', 'Miyerkules'],
            ['Thursday', 'Huwebes', 'Huwebes'],
            ['Friday', 'Biyernes', 'Biyernes'],
            ['Saturday', 'Sabado', 'Sabado'],
          ],
        ),
        ParagraphBlock(
          'Day names come from Spanish. They are capitalized in writing. Use **sang** before a past day and **sa** before a future or recurring day:',
        ),
        BulletsBlock([
          '_Sang Sabado nagkadto kami sa merkado._ (Last Saturday we went to the market.)',
          '_Sa Lunes may klase kami._ (On Monday we have class.)',
          '_Kada Domingo nagasimba kami._ (Every Sunday we go to church.)',
        ]),
        QuizBlock(
          id: 'beginner_5_qc2',
          question: 'What does _Lunes_ mean in English?',
          options: ['Wednesday', 'Monday', 'Friday'],
          answer: 1,
          explain: '_Lunes_ = Monday.',
        ),
      ],
    ),
    LessonSection(
      title: 'Months',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['English', 'Hiligaynon', 'English', 'Hiligaynon'],
          italicColumn: 1,
          rows: [
            ['January', 'Enero', 'July', 'Hulyo'],
            ['February', 'Pebrero', 'August', 'Agosto'],
            ['March', 'Marso', 'September', 'Septyembre'],
            ['April', 'Abril', 'October', 'Oktubre'],
            ['May', 'Mayo', 'November', 'Nobyembre'],
            ['June', 'Hunyo', 'December', 'Disyembre'],
          ],
        ),
        QuizBlock(
          id: 'beginner_5_qc3',
          question: 'What does _Abril_ mean in English?',
          options: ['March', 'April', 'February'],
          answer: 1,
          explain: '_Abril_ = April.',
        ),
      ],
    ),
    LessonSection(
      title: 'Today, tomorrow, yesterday, and relative time',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['subong', 'ngayon', 'now / today'],
            ['subong nga adlaw', 'ngayong araw', 'today'],
            ['buas', 'bukas', 'tomorrow'],
            ['kahapon', 'kahapon', 'yesterday'],
            ['kagab-i', 'kagabi', 'last night'],
            ['kaina', 'kanina', 'a while ago'],
            ['sang una', 'noong una', 'formerly / long ago'],
            ['sunod nga simana', 'susunod na linggo', 'next week'],
            ['sang miaging simana', 'noong nakaraang linggo', 'last week'],
            ['kada adlaw', 'araw-araw / tuwing araw', 'every day'],
          ],
        ),
        QuizBlock(
          id: 'beginner_5_qc4',
          question: 'What does _sang miaging simana_ mean in English?',
          options: ['formerly / long ago', 'every day', 'last week'],
          answer: 2,
          explain: '_sang miaging simana_ = last week.',
        ),
      ],
    ),
    LessonSection(
      title: 'Parts of the day',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'Meaning'],
          italicColumn: 0,
          rows: [
            ['aga / kaagahon', 'umaga', 'morning'],
            ['udto', 'tanghali', 'noon / midday'],
            ['hapon / kahaponon', 'hapon', 'afternoon'],
            ['gab-i / kagab-ihon', 'gabi', 'night / evening'],
            ['tunga sang gab-i', 'hatinggabi', 'midnight'],
          ],
        ),
        ParagraphBlock(
          'Use **sang** to place an event within a part of the day: _sang aga_ (in the morning), _sang hapon_ (in the afternoon), _sang gab-i_ (at night).',
        ),
        QuizBlock(
          id: 'beginner_5_qc5',
          question: 'What does _hapon / kahaponon_ mean in Filipino?',
          options: ['tanghali', 'hapon', 'umaga'],
          answer: 1,
          explain: '_hapon / kahaponon_ = hapon.',
        ),
      ],
    ),
    LessonSection(
      title: 'Telling the time',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'The pattern is **alas-** + number, then **sang** + part of the day:',
        ),
        BulletsBlock([
          '_Alas-siete sang aga._ (7:00 in the morning.)',
          '_Alas-dose sang udto._ (12:00 noon.)',
          '_Alas-tres sang hapon._ (3:00 in the afternoon.)',
          '_Alas-otso sang gab-i._ (8:00 at night.)',
          '_Alas-dos y medya._ (2:30, "two and a half.")',
        ]),
        ParagraphBlock(
          'For "1 o\'clock," use _ala-una_. To ask the time: **Ano oras na?** ("What time is it now?") Answer: **Alas-kwatro na.** ("It\'s already four o\'clock.")',
        ),
        ParagraphBlock(
          'For asking "at what time," use _Anong oras...?_: _Anong oras ang klase?_ (What time is the class?) _Alas-nwebe sang aga._ (At nine in the morning.)',
        ),
      ],
    ),
    LessonSection(
      title: 'Dates',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'To ask the day: _Ano nga adlaw subong?_ — _Miyerkoles subong._ (What day is today? — Today is Wednesday.)',
        ),
        ParagraphBlock(
          'To ask the date: _Ano ang petsa subong?_ — _Septyembre trenta._ (What\'s today\'s date? — September 30.)',
        ),
        ParagraphBlock(
          'The usual form is **month + Spanish-derived number**: _Enero singko_ (January 5), _Disyembre baynte-singko_ (December 25).',
        ),
      ],
    ),
    LessonSection(
      title: 'Special-day greetings',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Malipayon nga Kaadlawan!', 'Happy birthday!'],
            ['Malipayon nga Pasko!', 'Merry Christmas!'],
            ['Malipayon nga Bag-ong Tuig!', 'Happy New Year!'],
            ['Malipayon nga Pagkabanhaw!', 'Happy Easter!'],
          ],
        ),
        ParagraphBlock(
          '_Kaadlawan_ is a birthday (from _adlaw_, "day"), and _malipayon_ means "joyful, happy" (from _lipay_, "joy").',
        ),
        QuizBlock(
          id: 'beginner_5_qc8',
          question: 'What does _Malipayon nga Bag-ong Tuig!_ mean in English?',
          options: ['Happy Easter!', 'Happy New Year!', 'Happy birthday!'],
          answer: 1,
          explain: '_Malipayon nga Bag-ong Tuig!_ = Happy New Year!.',
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
              'Ano nga adlaw subong? — Miyerkoles.',
              'Anong araw ngayon? — Miyerkules.',
              'What day is it today? — Wednesday.',
            ],
            [
              'Subong Lunes; buas Martes.',
              'Lunes ngayon; Martes bukas.',
              'Today is Monday; tomorrow is Tuesday.',
            ],
            [
              'Ano oras na? — Alas-tres na sang hapon.',
              'Anong oras na? — Alas-tres na ng hapon.',
              'What time is it? — It\'s already 3 in the afternoon.',
            ],
            [
              'Ang klase alas-siete sang aga.',
              'Ang klase ay alas-siyete ng umaga.',
              'Class is at 7 in the morning.',
            ],
            [
              'Ang kaadlawan ko Marso baynte.',
              'Ang kaarawan ko ay Marso 20.',
              'My birthday is March 20.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Hiligaynon needs no "to be" word: _Subong Lunes_ is literally "Now Monday." _Na_ adds "already/now," _sang aga_ goes at the end for "in the morning," and _kada_ ("every") comes before the time word. Row 6 shows the date pattern: month + Spanish-derived number.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Panay has a long-standing fiesta calendar. The Dinagyang of Iloilo City is held every fourth Sunday of January in honor of the Santo Niño. Paraw Regatta (Iloilo to Guimaras) is held in February. Bacolod\'s MassKara takes place in October. Knowing the months makes it easier to talk about them.',
        ),
        QuizBlock(
          id: 'beginner_5_qc9',
          question:
              'What does _Ano nga adlaw subong? — Miyerkoles._ mean in English?',
          options: [
            'Class is at 7 in the morning.',
            'What day is it today? — Wednesday.',
            'Today is Monday; tomorrow is Tuesday.',
          ],
          answer: 1,
          explain:
              '_Ano nga adlaw subong? — Miyerkoles._ = What day is it today? — Wednesday..',
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
          'Hiligaynon _simana_ = Filipino _linggo_ (week); Hiligaynon _Domingo_ = Filipino _Linggo_ (Sunday).',
          '_Ngayon_ (Filipino) = _subong_ (Hiligaynon); _bukas_ = _buas_.',
          'Both use _alas-_ for clock hours; Hiligaynon uses _sang_ where Filipino uses _ng_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _ngayon_ or _bukas_.',
          'Writing _alas-siete ng umaga_ with _ng_ instead of _sang_.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you say the days and months in order without looking?',
          'Can you say what day and date it is today?',
          'Can you tell the time at 6:00 a.m., 12:00 noon, and 8:00 p.m.?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson6 = Lesson(
  id: 'beginner_6',
  number: 6,
  title: 'Family & People',
  subtitle: 'Name close family members and relatives.',
  emoji: '👪',
  level: 'Beginner',
  objectives: [
    'Name close family members and relatives.',
    'Talk about whose person or thing is meant (possessives).',
    'Address people respectfully.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Family words are used every day, along with respect terms for elders. Knowing them helps you follow conversations at home and in the neighborhood.',
        ),
      ],
    ),
    LessonSection(
      title: 'Immediate family',
      icon: Icons.family_restroom_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['pamilya', 'pamilya', 'family'],
            ['ginikanan', 'magulang', 'parents'],
            ['iloy / nanay', 'ina / nanay', 'mother'],
            ['amay / tatay', 'ama / tatay', 'father'],
            ['anak', 'anak', 'child (son/daughter)'],
            ['utod', 'kapatid', 'sibling'],
            ['utod nga lalaki', 'kapatid na lalaki', 'brother'],
            ['utod nga babayi', 'kapatid na babae', 'sister'],
            ['manghod', 'bunsong kapatid', 'younger sibling'],
            ['bana', 'asawang lalaki', 'husband'],
          ],
        ),
        ParagraphBlock(
          '_Nanay_ and _tatay_ are used everywhere (like Filipino). _Iloy_ and _amay_ are the native words and are still common, especially in rural areas and in writing.',
        ),
        FlashcardsBlock([
          Flashcard('pamilya', 'family'),
          Flashcard('ginikanan', 'parents'),
          Flashcard('iloy / nanay', 'mother'),
          Flashcard('amay / tatay', 'father'),
          Flashcard('anak', 'child (son/daughter)'),
          Flashcard('utod', 'sibling'),
          Flashcard('utod nga lalaki', 'brother'),
          Flashcard('utod nga babayi', 'sister'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_6_qc1',
          question: 'What does _utod nga lalaki_ mean in English?',
          options: ['mother', 'child (son/daughter)', 'brother'],
          answer: 2,
          explain: '_utod nga lalaki_ = brother.',
        ),
      ],
    ),
    LessonSection(
      title: 'Extended family',
      icon: Icons.family_restroom_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['lolo', 'lolo', 'grandfather'],
            ['lola', 'lola', 'grandmother'],
            ['tiyo', 'tiyo / tito', 'uncle'],
            ['tiya', 'tiya / tita', 'aunt'],
            ['ig-agaw', 'pinsan', 'cousin'],
            ['umagad', 'pamangkin', 'nephew / niece'],
            ['apo', 'apo', 'grandchild'],
            ['ninong / ninang', 'ninong / ninang', 'godfather / godmother'],
          ],
        ),
        ParagraphBlock(
          'Some of these terms are used broadly: _Tiya_ and _Tiyo_ are commonly used for older neighbors who are not actual relatives.',
        ),
        QuizBlock(
          id: 'beginner_6_qc2',
          question: 'What does _lola_ mean in English?',
          options: ['godfather / godmother', 'cousin', 'grandmother'],
          answer: 2,
          explain: '_lola_ = grandmother.',
        ),
      ],
    ),
    LessonSection(
      title: 'Terms of address and respect',
      icon: Icons.family_restroom_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Term', 'Used for'],
          italicColumn: -1,
          rows: [
            ['Manang', 'an older woman or older sister'],
            ['Manong', 'an older man or older brother'],
            ['Nay / Nanay', 'mother or an older woman (respectful)'],
            ['Tay / Tatay', 'father or an older man (respectful)'],
            ['Inday', 'a young girl or young woman (affectionate)'],
            ['Nonoy', 'a young boy (affectionate)'],
            ['Day', 'short form of Inday, used casually'],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'People words',
      icon: Icons.family_restroom_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['mga tawo', 'mga tao', 'people'],
            ['batan-on', 'kabataan', 'youth / young person'],
            ['tigulang', 'matanda', 'old person'],
            ['silingan', 'kapitbahay', 'neighbor'],
            ['manunudlo', 'guro', 'teacher'],
            ['estudyante', 'estudyante', 'student'],
          ],
        ),
        QuizBlock(
          id: 'beginner_6_qc4',
          question: 'What does _batan-on_ mean in English?',
          options: ['youth / young person', 'neighbor', 'student'],
          answer: 0,
          explain: '_batan-on_ = youth / young person.',
        ),
      ],
    ),
    LessonSection(
      title: 'Possession',
      icon: Icons.family_restroom_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Hiligaynon marks possession with the pronoun sets from Lesson 2. Two patterns:',
        ),
        BulletsBlock([
          '**Short form after the noun:** _Ang iloy ko._ (My mother.) _Ang balay nila._ (Their house.)',
          'Long form before the noun with _nga_: _Akon nga iloy._ (My mother.) _Ila nga balay._ (Their house.)',
        ]),
        ParagraphBlock(
          'For a person\'s name, use **ni**: _Ang iloy ni Ana._ (Ana\'s mother.) _Ang balay ni Jose._ (Jose\'s house.)',
        ),
        ParagraphBlock(
          'Inclusive and exclusive "our" matter: _ang aton nga pamilya_ means "our family" including the listener (_aton_), and _ang amon nga pamilya_ means "our family" without the listener (_amon_).',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Ang iloy ko si Rosa.',
              'Ang nanay ko si Rosa.',
              'My mother is Rosa.',
            ],
            [
              'May duha ka utod ako.',
              'May dalawa akong kapatid.',
              'I have two siblings.',
            ],
            [
              'Ang akon nga tatay doktor.',
              'Ang tatay ko ay doktor.',
              'My father is a doctor.',
            ],
            [
              'Ang lola ko taga-Capiz.',
              'Ang lola ko ay taga-Capiz.',
              'My grandmother is from Capiz.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _May_ means "there is/has": _May duha ka utod ako_ is literally "There are two siblings for me." Row 1 shows short _ko_ after the noun, and the "our" rows repeat the _aton/amon_ split of _kita/kami_. In the last row, _sang_ links a noun to its possessor.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'In Filipino culture, respect for elders is strong, and in Panay and Negros, greeting elders and asking for their blessing (mano or pagmano) is still common.',
        ),
        QuizBlock(
          id: 'beginner_6_qc6',
          question: 'What does _Ang akon nga tatay doktor._ mean in English?',
          options: [
            'My grandmother is from Capiz.',
            'My father is a doctor.',
            'I have two siblings.',
          ],
          answer: 1,
          explain: '_Ang akon nga tatay doktor._ = My father is a doctor..',
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
          '_Kapatid_ (Filipino) = _utod_ (Hiligaynon).',
          '_Kapitbahay_ (Filipino) = _silingan_; _pinsan_ = _ig-agaw_; _pamangkin_ = _umagad_.',
          'Filipino _ang nanay ko_ and Hiligaynon _ang iloy ko/nanay ko_ follow the same word order.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _pinsan_ for "cousin"; say _ig-agaw_.',
          'Using _aton_ when you mean "our (but not yours)."',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you name ten family members?',
          'Can you say "This is my mother\'s house" in two ways?',
          'Can you explain the difference between _aton_ and _amon_?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson7 = Lesson(
  id: 'beginner_7',
  number: 7,
  title: 'Everyday Objects, Places & Directions',
  subtitle: 'Name common objects, rooms, and places.',
  emoji: '🧭',
  level: 'Beginner',
  objectives: [
    'Name common objects, rooms, and places.',
    'Ask where something is and describe locations.',
    'Use this / that words and simple directions.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'This lesson gives you the words for your house, your community, and where things are, so you can describe places and ask for directions.',
        ),
      ],
    ),
    LessonSection(
      title: 'The house and the objects in it',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['balay', 'bahay', 'house'],
            ['kwarto', 'kuwarto', 'room / bedroom'],
            ['kusina', 'kusina', 'kitchen'],
            ['banyo', 'banyo', 'bathroom'],
            ['purtahan', 'pinto', 'door'],
            ['bintana', 'bintana', 'window'],
            ['lamesa', 'mesa', 'table'],
            ['lingkuran', 'upuan', 'chair'],
            ['kama', 'kama', 'bed'],
            ['libro', 'libro', 'book'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('balay', 'house'),
          Flashcard('kwarto', 'room / bedroom'),
          Flashcard('kusina', 'kitchen'),
          Flashcard('banyo', 'bathroom'),
          Flashcard('purtahan', 'door'),
          Flashcard('bintana', 'window'),
          Flashcard('lamesa', 'table'),
          Flashcard('lingkuran', 'chair'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_7_qc1',
          question: 'What does _purtahan_ mean in English?',
          options: ['book', 'door', 'bed'],
          answer: 1,
          explain: '_purtahan_ = door.',
        ),
      ],
    ),
    LessonSection(
      title: 'Places in the community',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['simbahan', 'simbahan', 'church'],
            ['merkado', 'palengke', 'market'],
            ['tindahan', 'tindahan', 'store'],
            ['ospital', 'ospital', 'hospital'],
            ['plasa', 'plasa', 'town plaza'],
            ['dalan', 'daan / kalsada', 'road'],
            ['baybay', 'dagat / baybayin', 'sea / beach'],
            ['bukid', 'bundok', 'mountain / countryside'],
            ['suba', 'ilog', 'river'],
            ['opisina', 'opisina', 'office'],
          ],
        ),
        QuizBlock(
          id: 'beginner_7_qc2',
          question: 'What does _plasa_ mean in English?',
          options: ['river', 'office', 'town plaza'],
          answer: 2,
          explain: '_plasa_ = town plaza.',
        ),
      ],
    ),
    LessonSection(
      title: 'This, that, here, there',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('Hiligaynon has three levels of distance:'),
        TableBlock(
          headers: ['Meaning', 'Near me', 'Near you', 'Far from both'],
          italicColumn: -1,
          rows: [
            ['this / that', 'ini', 'ina', 'ato'],
            ['here / there', 'diri', 'dira', 'didto'],
          ],
        ),
        BulletsBlock([
          '_Ano ini?_ (What is this?)',
          '_Ano ina?_ (What is that (near you)?)',
          '_Ano ato?_ (What is that (far away)?)',
          '_Diri ako._ (I\'m here.) _Dira ka._ (You\'re there.) _Didto siya._ (He/she is over there.)',
        ]),
        ParagraphBlock(
          'Filipino has the same three levels: _ito/iyan/iyon_ and _dito/diyan/doon_.',
        ),
      ],
    ),
    LessonSection(
      title: 'Asking where and saying where',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Diin_ means "where." To say something is at a place, use **Ara sa** ("is at"):',
        ),
        BulletsBlock([
          '_Diin ang merkado?_ (Where is the market?)',
          '_Ara sa tupad sang eskwelahan._ (It\'s next to the school.)',
          '_Ang libro ara sa lamesa._ (The book is on the table.)',
          '_Wala si Nanay diri._ (Mother is not here.)',
        ]),
        ParagraphBlock(
          'Note **ara** (present, is at) and **wala** (absent, is not at). _Wala_ also means "none" and "left (side)."',
        ),
      ],
    ),
    LessonSection(
      title: 'Location words',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['sa tupad sang', 'sa tabi ng', 'beside'],
            ['sa atubang sang', 'sa harap ng', 'in front of'],
            ['sa luyo sang', 'sa likod ng', 'behind'],
            ['sa ibabaw sang', 'sa ibabaw ng', 'on top of / above'],
            ['sa idalom sang', 'sa ilalim ng', 'under'],
            ['sa sulod sang', 'sa loob ng', 'inside'],
            ['sa gwa sang', 'sa labas ng', 'outside'],
            ['sa tunga sang', 'sa gitna ng', 'in the middle of'],
            ['malapit sa', 'malapit sa', 'near'],
            ['malayo sa', 'malayo sa', 'far from'],
          ],
        ),
        QuizBlock(
          id: 'beginner_7_qc5',
          question: 'What does _sa gwa sang_ mean in English?',
          options: ['on top of / above', 'outside', 'beside'],
          answer: 1,
          explain: '_sa gwa sang_ = outside.',
        ),
      ],
    ),
    LessonSection(
      title: 'Simple directions',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['sa tuo', 'sa kanan', 'to the right'],
            ['sa wala', 'sa kaliwa', 'to the left'],
            ['diretso', 'diretso', 'straight ahead'],
            ['liko', 'liko', 'turn'],
            ['para / hunong', 'para / hinto', 'stop'],
            ['manaog', 'bumaba', 'get off / go down'],
          ],
        ),
        ParagraphBlock(
          '_Tuo_ means "right" and _wala_ means "left." This is one of the surprises for Filipino speakers because _kanan_ (Filipino for "right") is not a word for "right" in Hiligaynon. Hiligaynon _kan-on_ means "cooked rice."',
        ),
        QuizBlock(
          id: 'beginner_7_qc6',
          question: 'What does _para / hunong_ mean in English?',
          options: ['straight ahead', 'stop', 'get off / go down'],
          answer: 1,
          explain: '_para / hunong_ = stop.',
        ),
      ],
    ),
    LessonSection(
      title: 'The markers sa and sang',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**sa** marks a place or direction: _sa merkado_, _sa balay_, _sa Iloilo_.',
          '**sang** links nouns like "of": _ang balay sang bata_ (the house of the child) and _ang atubang sang eskwelahan_ (the front of the school).',
        ]),
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
            ['Diin ang banyo?', 'Nasaan ang banyo?', 'Where is the bathroom?'],
            [
              'Ara sa likod sang kusina.',
              'Nasa likod ng kusina.',
              'It\'s behind the kitchen.',
            ],
            [
              'Ano ini? — Libro ini.',
              'Ano ito? — Libro ito.',
              'What is this? — This is a book.',
            ],
            [
              'Ang lapis ara sa ibabaw sang lamesa.',
              'Ang lapis ay nasa ibabaw ng mesa.',
              'The pencil is on top of the table.',
            ],
            [
              'Malapit ang eskwelahan sa simbahan.',
              'Malapit ang paaralan sa simbahan.',
              'The school is near the church.',
            ],
            [
              'Liko sa tuo, dayon diretso.',
              'Kumanan, tapos diretso.',
              'Turn right, then go straight.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** In "where" answers, _ara sa_ introduces the place. In _Malapit ang eskwelahan sa simbahan_, the predicate _malapit_ comes first. _Liko sa tuo_ is a command with no pronoun. Learn _sa tupad sang_ as one chunk.',
        ),
        ParagraphBlock('A short dialogue asking directions:'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Palihog, diin ang merkado?',
            'Excuse me, where is the market?',
          ),
          DialogueLine(
            'Friend',
            'Diretso lang, dayon liko sa tuo.',
            'Just go straight, then turn right.',
          ),
          DialogueLine('You', 'Malayo bala?', 'Is it far?'),
          DialogueLine('Friend', 'Indi, malapit lang.', 'No, it\'s just near.'),
          DialogueLine('You', 'Salamat gid!', 'Thank you very much!'),
        ]),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Iloilo City has a historic downtown area with heritage buildings, and its famed Molo Church (a Gothic-Renaissance church known as the "Feminist Church" for its rows of female saints) and Jaro Cathedral are landmarks. Names like Molo, Jaro, and La Paz are districts of Iloilo City.',
        ),
        QuizBlock(
          id: 'beginner_7_qc8',
          question:
              'What does _Ang lapis ara sa ibabaw sang lamesa._ mean in English?',
          options: [
            'The school is near the church.',
            'The pencil is on top of the table.',
            'Turn right, then go straight.',
          ],
          answer: 1,
          explain:
              '_Ang lapis ara sa ibabaw sang lamesa._ = The pencil is on top of the table..',
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
          '_Nasaan_ (Filipino) = _diin ang...?_ (Hiligaynon).',
          '_Nasa_ (is at) = _ara sa_.',
          '_Kanan/kaliwa_ = _tuo/wala_. Be careful with _wala_ (also "none").',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _nasa_ instead of _ara sa_.',
          'Using _dito/diyan/doon_ instead of _diri/dira/didto_.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you name ten objects and ten places?',
          'Can you ask where the bathroom is and understand the answer?',
          'Can you give directions using _tuo_, _wala_, and _diretso_?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson8 = Lesson(
  id: 'beginner_8',
  number: 8,
  title: 'Food, Ordering & Money',
  subtitle: 'Name common foods and drinks and describe taste.',
  emoji: '🍲',
  level: 'Beginner',
  objectives: [
    'Name common foods and drinks and describe taste.',
    'Order food and shop politely, ask prices, and pay.',
    'Use the pattern Gusto ko sang... to express wants.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Food is central to Ilonggo life. This lesson gives you the words and patterns for ordering, asking prices, and talking about taste and wants.',
        ),
      ],
    ),
    LessonSection(
      title: 'Meals',
      icon: Icons.restaurant_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['pagkaon', 'pagkain', 'food'],
            ['pamahaw', 'almusal', 'breakfast'],
            ['paniudto', 'tanghalian', 'lunch'],
            ['panihapon', 'hapunan', 'dinner / supper'],
            ['merienda', 'meryenda', 'snack'],
            ['kan-on', 'kanin', 'cooked rice'],
            ['bugas', 'bigas', 'uncooked rice'],
            ['sud-an', 'ulam', 'dish eaten with rice'],
          ],
        ),
        ParagraphBlock(
          '_Kan-on_ (cooked rice) and _bugas_ (uncooked rice) are different words in Hiligaynon, and the meal is centered on _kan-on_ and a _sud-an_.',
        ),
        FlashcardsBlock([
          Flashcard('pagkaon', 'food'),
          Flashcard('pamahaw', 'breakfast'),
          Flashcard('paniudto', 'lunch'),
          Flashcard('panihapon', 'dinner / supper'),
          Flashcard('merienda', 'snack'),
          Flashcard('kan-on', 'cooked rice'),
          Flashcard('bugas', 'uncooked rice'),
          Flashcard('sud-an', 'dish eaten with rice'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_8_qc1',
          question: 'What does _bugas_ mean in English?',
          options: ['uncooked rice', 'cooked rice', 'snack'],
          answer: 0,
          explain: '_bugas_ = uncooked rice.',
        ),
      ],
    ),
    LessonSection(
      title: 'Foods and drinks',
      icon: Icons.restaurant_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['isda', 'isda', 'fish'],
            ['manok', 'manok', 'chicken'],
            ['baboy', 'baboy', 'pork / pig'],
            ['baka', 'baka', 'beef'],
            ['itlog', 'itlog', 'egg'],
            ['utan', 'gulay', 'vegetables'],
            ['prutas', 'prutas', 'fruit'],
            ['saging', 'saging', 'banana'],
            ['mangga', 'mangga', 'mango'],
            ['tinapay', 'tinapay', 'bread'],
          ],
        ),
        QuizBlock(
          id: 'beginner_8_qc2',
          question: 'What does _isda_ mean in English?',
          options: ['fish', 'chicken', 'banana'],
          answer: 0,
          explain: '_isda_ = fish.',
        ),
      ],
    ),
    LessonSection(
      title: 'Tastes and reactions',
      icon: Icons.restaurant_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['namit', 'masarap', 'delicious'],
            ['tam-is', 'matamis', 'sweet'],
            ['maalat', 'maalat', 'salty'],
            ['maaslom', 'maasim', 'sour'],
            ['mapait', 'mapait', 'bitter'],
            ['mainit', 'mainit', 'hot (temperature)'],
            ['matugnaw', 'malamig', 'cold'],
            ['gutom', 'gutom', 'hungry'],
            ['uhaw', 'uhaw', 'thirsty'],
            ['busog', 'busog', 'full'],
          ],
        ),
        QuizBlock(
          id: 'beginner_8_qc3',
          question: 'What does _mapait_ mean in English?',
          options: ['hungry', 'hot (temperature)', 'bitter'],
          answer: 2,
          explain: '_mapait_ = bitter.',
        ),
      ],
    ),
    LessonSection(
      title: 'Expressing wants',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'The core pattern is **Gusto ko sang...** ("I want...")',
        ),
        BulletsBlock([
          '_Gusto ko sang tubig._ (I want water.)',
          '_Gusto ko sang kape._ (I want coffee.)',
          '_Gusto mo sang kan-on?_ (Do you want rice?)',
        ]),
        ParagraphBlock(
          'Add **palihog** to make it a polite request: _Palihog, hatagi ako sang tubig._ (Please give me water.) You can also use _pwede_ ("can/may"): _Pwede bala mangayo sang tubig?_ (May I ask for some water?)',
        ),
        ParagraphBlock(
          '**Sang** here marks the thing wanted. You will also hear **sing** in the same place, which is the older form for an unspecific thing: _Gusto ko sing tubig._ Both forms are correct; _sang_ is more widely used today.',
        ),
      ],
    ),
    LessonSection(
      title: 'Asking prices and money',
      icon: Icons.payments_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['Tagpila ini?', 'Magkano ito?', 'How much is this?'],
            ['Pila tanan?', 'Magkano lahat?', 'How much is it all together?'],
            ['mahal', 'mahal', 'expensive'],
            ['barato', 'mura', 'cheap'],
            ['bayad', 'bayad', 'payment'],
            ['sukli', 'sukli', 'change'],
            ['piso / pesos', 'piso', 'peso'],
          ],
        ),
        BulletsBlock([
          '_Tagpila ini?_ — _Trenta pesos._ (How much is this? — Thirty pesos.)',
          '_Mahal gid!_ (That\'s really expensive!)',
          '_Barato lang ini._ (This is cheap.)',
          '_Wala ako sing sukli._ (I have no change.)',
        ]),
        ParagraphBlock(
          '_Tagpila_ means "how much _each_" (a per-item price); _Pila tanan?_ asks for the total.',
        ),
        QuizBlock(
          id: 'beginner_8_qc5',
          question: 'What does _Tagpila ini?_ mean in English?',
          options: ['peso', 'change', 'How much is this?'],
          answer: 2,
          explain: '_Tagpila ini?_ = How much is this?.',
        ),
      ],
    ),
    LessonSection(
      title: 'At the table',
      icon: Icons.restaurant_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Kaon ta!', 'Let\'s eat!'],
            ['Kaon na.', 'Come and eat.'],
            ['Gutom na ako.', 'I\'m already hungry.'],
            ['Busog na ako.', 'I\'m already full.'],
            ['Namit gid!', 'So delicious!'],
            ['Isa pa, palihog.', 'One more, please.'],
            ['Tama na.', 'That\'s enough.'],
          ],
        ),
        QuizBlock(
          id: 'beginner_8_qc6',
          question: 'What does _Kaon ta!_ mean in English?',
          options: ['I\'m already hungry.', 'So delicious!', 'Let\'s eat!'],
          answer: 2,
          explain: '_Kaon ta!_ = Let\'s eat!.',
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
            ['Gusto ko sang tubig.', 'Gusto ko ng tubig.', 'I want water.'],
            [
              'Tagpila ini? — Baynte pesos.',
              'Magkano ito? — Dalawampung piso.',
              'How much is this? — Twenty pesos.',
            ],
            [
              'Mahal gid ang isda subong.',
              'Mahal na mahal ang isda ngayon.',
              'Fish is really expensive today.',
            ],
            [
              'Palihog, hatagi ako sang duha ka kilo nga bugas.',
              'Pakibigyan mo ako ng dalawang kilong bigas.',
              'Please give me two kilos of rice.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Gusto ko sang tubig_ uses _sang_ for the thing wanted. _Hatagi_ is a command form of _hatag_ ("give"); the ending _-i_ means "give to me." _Duha ka kilo nga bugas_ uses _ka_ and the linker _nga_, and _lang_ in _Kape lang_ means "just."',
        ),
        ParagraphBlock('A market role-play:'),
        DialogueBlock([
          DialogueLine(
            'Buyer',
            'Maayong aga. Tagpila ang mangga?',
            'Good morning. How much is the mango?',
          ),
          DialogueLine(
            'Seller',
            'Singkwenta pesos ang kilo.',
            'Fifty pesos a kilo.',
          ),
          DialogueLine(
            'Buyer',
            'Mahal! Pwede bala matawaran?',
            'Expensive! Can I bargain?',
          ),
          DialogueLine(
            'Seller',
            'Kwarenta y singko na lang.',
            'Forty-five, then.',
          ),
          DialogueLine('Buyer', 'Sige, duha ka kilo.', 'Okay, two kilos.'),
          DialogueLine(
            'Seller',
            'Salamat. Isa ka gatos ang tanan.',
            'Thanks. It\'s a hundred in all.',
          ),
        ]),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Iloilo is known for La Paz Batchoy (noodle soup with pork, liver, chicharon, and egg, from the La Paz district) and Pancit Molo (dumpling soup from the Molo district). Bacolod is famous for chicken inasal (grilled chicken marinated with lemongrass and annatto oil), piaya (a flat pastry filled with muscovado sugar), and butterscotch and napoleones are famous sweets and pastries of the region. KBL (kadyos, baboy, langka) is a beloved Ilonggo soup.',
        ),
        QuizBlock(
          id: 'beginner_8_qc7',
          question: 'What does _Tagpila ini? — Baynte pesos._ mean in English?',
          options: [
            'How much is this? — Twenty pesos.',
            'I want water.',
            'Fish is really expensive today.',
          ],
          answer: 0,
          explain:
              '_Tagpila ini? — Baynte pesos._ = How much is this? — Twenty pesos..',
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
          '_Masarap_ (Filipino) = _namit_ (Hiligaynon).',
          '_Kanin_ (Filipino) = _kan-on_; _bigas_ = _bugas_.',
          '_Ulam_ (Filipino) = _sud-an_; _gulay_ = _utan_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _ng_ instead of _sang_ (_Gusto ko ng tubig_).',
          'Mixing up _kan-on_ (cooked rice) and _bugas_ (raw rice).',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you order a meal and a drink?',
          'Can you ask the price of an item and say it is too expensive?',
          'Can you say you are hungry, thirsty, and full?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson9 = Lesson(
  id: 'beginner_9',
  number: 9,
  title: 'Basic Verbs & Aspect',
  subtitle: 'Recognize and use twenty common verbs.',
  emoji: '🏃',
  level: 'Beginner',
  objectives: [
    'Recognize and use twenty common verbs.',
    'Understand the three basic aspects: ongoing, completed, and future.',
    'Give simple commands and invitations.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Hiligaynon verbs show **aspect** (ongoing, completed, not yet begun) rather than past, present, and future. Learn the pattern once with _kaon_ ("eat") and reuse it.',
        ),
      ],
    ),
    LessonSection(
      title: 'The root word',
      icon: Icons.translate_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Most verbs start as a **root**: _kaon_ (eat), _inom_ (drink), _kadto_ (go), _tulog_ (sleep), _basa_ (read), _sulat_ (write), _luto_ (cook). Prefixes turn the root into a specific form.',
        ),
      ],
    ),
    LessonSection(
      title: 'The three basic aspects (actor-focus with mag-)',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Aspect', 'Pattern', 'Example', 'Meaning'],
          italicColumn: -1,
          rows: [
            [
              'Ongoing / habitual',
              'naga- + root',
              'nagakaon ako',
              'I am eating / I (usually) eat',
            ],
            ['Completed', 'nag- + root', 'nagkaon ako', 'I ate / I have eaten'],
            [
              'Future / intended',
              'mag- or maga- + root',
              'magkaon ako / magakaon ako',
              'I will eat',
            ],
          ],
        ),
        ParagraphBlock(
          'The prefix changes; the root stays the same. Some speakers say _gina-_ or _ga-_ in place of _naga-_ in the ongoing form; you will hear _gakaon_ and _nagakaon_ both.',
        ),
        ParagraphBlock(
          'Compare English, which changes the verb _eat → ate → will eat_, with Hiligaynon, which keeps _kaon_ and changes the prefix.',
        ),
      ],
    ),
    LessonSection(
      title: 'Common verbs',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Root', 'Ongoing', 'Completed', 'Future', 'English'],
          italicColumn: -1,
          rows: [
            ['kaon', 'nagakaon', 'nagkaon', 'magkaon', 'eat'],
            ['inom', 'nagainom', 'naginom', 'maginom', 'drink'],
            ['kadto', 'nagakadto', 'nagkadto', 'magkadto', 'go (there)'],
            ['tulog', 'nagatulog', 'nagtulog', 'matulog', 'sleep'],
            ['basa', 'nagabasa', 'nagbasa', 'magbasa', 'read'],
            ['sulat', 'nagasulat', 'nagsulat', 'magsulat', 'write'],
            ['luto', 'nagaluto', 'nagluto', 'magluto', 'cook'],
            ['palit', 'nagapalit', 'nagpalit', 'magpalit', 'buy'],
            ['trabaho', 'nagatrabaho', 'nagtrabaho', 'magtrabaho', 'work'],
            [
              'eskwela',
              'nagaeskwela',
              'nag-eskwela',
              'mag-eskwela',
              'study, go to school',
            ],
          ],
        ),
        ParagraphBlock(
          'Additional verbs to learn as roots: _lakat_ (walk), _dalagan_ (run), _hulat_ (wait), _tan-aw_ (watch), _pamati_ (listen), _hambal_ (say), _istorya_ (talk), _hatag_ (give), _tabang_ / _bulig_ (help), _uli_ (go home), _kari_ (come).',
        ),
      ],
    ),
    LessonSection(
      title: 'The pronouns with verbs',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'In the basic actor-focus pattern the pronoun comes **after** the verb: _Nagakaon ako._ _Nagbasa siya._ _Magkadto kami._ Names take **si**: _Nagakaon si Ana._',
        ),
      ],
    ),
    LessonSection(
      title: 'Commands and invitations',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '_Kaon na._ (Come eat.)',
          '_Kaon ta!_ (Let\'s eat!)',
          '_Kadto ta sa merkado._ (Let\'s go to the market.)',
          '_Hulata ako._ (Wait for me.)',
          '_Palihog, basaha ini._ (Please read this.)',
          '_Ayaw pag-alis._ (Don\'t leave.)',
        ]),
        ParagraphBlock(
          '**Ta** is a short form that means "let\'s" (from _kita_, "we"). **Ayaw** means "don\'t."',
        ),
      ],
    ),
    LessonSection(
      title: 'Preview: object focus',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'You can also say _Ginkaon ko ang isda_ ("I ate the fish") with _gin-_ on the verb and the object marked as _ang_. This is called **object focus**, and you will study it fully in Intermediate Lesson 3 and Advanced Lesson 1. For now, notice that **nagkaon ako sang isda** and **ginkaon ko ang isda** describe the same event with a different emphasis: the first foregrounds _who_ ate, the second foregrounds _what_ was eaten.',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['Nagakaon ako.', 'Kumakain ako.', 'I am eating.'],
            [
              'Nagkaon siya sang kan-on.',
              'Kumain siya ng kanin.',
              'He/she ate rice.',
            ],
            [
              'Magkaon kami sa udto.',
              'Kakain kami sa tanghali.',
              'We will eat at noon.',
            ],
            [
              'Nagabasa si Ana sang libro.',
              'Nagbabasa si Ana ng libro.',
              'Ana is reading a book.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** The three forms of _kaon_ (rows 1 to 3) are the core lesson. _Sang_ introduces the thing eaten, read, or cooked. There is no separate past or future tense, so time words like _kagab-i_ and _buas_ work together with the aspect prefix.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Hiligaynon and other Philippine languages use verbal affixes as an essential grammatical tool. Linguists describe them as "focus" or "voice" systems. Even native speakers learn these systems intuitively from childhood; there are actually many more forms than the three introduced here.',
        ),
        QuizBlock(
          id: 'beginner_9_qc7',
          question: 'What does _Nagabasa si Ana sang libro._ mean in English?',
          options: [
            'Ana is reading a book.',
            'We will eat at noon.',
            'I am eating.',
          ],
          answer: 0,
          explain: '_Nagabasa si Ana sang libro._ = Ana is reading a book..',
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
          'Filipino _kumakain / kumain / kakain_ = Hiligaynon _nagakaon / nagkaon / magkaon_. Both languages show aspect by changing the verb form, but the affixes look different.',
          'Filipino _mag-_ and Hiligaynon _mag-_ look alike, but the internal patterns are not identical.',
          'Filipino often uses **-um-** infixes (_kumain_); Hiligaynon uses **nag-/mag-** more often.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using English-style tense thinking (_Ako nagakaon kahapon_ is not natural; use _nagkaon_ for a completed action).',
          'Putting the pronoun before the verb (_Ako nagakaon_). Put it after: _Nagakaon ako_.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you conjugate _kaon_ in the three aspects?',
          'Can you say what you ate, what you are doing now, and what you will do tomorrow?',
          'Can you give a command and an invitation?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson10 = Lesson(
  id: 'beginner_10',
  number: 10,
  title: 'Question Words & Answers',
  subtitle:
      'Ask about people, things, places, time, reasons, manner, quantity,…',
  emoji: '❓',
  level: 'Beginner',
  objectives: [
    'Ask about people, things, places, time, reasons, manner, quantity, and choice.',
    'Answer with complete phrases.',
    'Use bala and rising intonation for yes/no questions.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Most questions start with a question word followed by a predicate-first sentence. Yes/no questions use the particle _bala_ or a rising voice.',
        ),
      ],
    ),
    LessonSection(
      title: 'The question words',
      icon: Icons.help_outline_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English', 'Example'],
          italicColumn: 0,
          rows: [
            ['ano', 'ano', 'what', 'Ano ini?'],
            ['sin-o', 'sino', 'who', 'Sin-o siya?'],
            ['diin', 'saan / nasaan', 'where', 'Diin ang merkado?'],
            ['san-o', 'kailan', 'when', 'San-o ka magkadto?'],
            ['ngaa', 'bakit', 'why', 'Ngaa wala ka nagkadto?'],
            ['paano', 'paano', 'how', 'Paano mag-adto sa Jaro?'],
            ['pila', 'ilan / magkano', 'how many / how much', 'Pila ka bata?'],
            ['ano nga', 'alin', 'which', 'Ano nga libro?'],
            ['kay sin-o', 'kanino', 'whose', 'Kay sin-o ini?'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('ano', 'what'),
          Flashcard('sin-o', 'who'),
          Flashcard('diin', 'where'),
          Flashcard('san-o', 'when'),
          Flashcard('ngaa', 'why'),
          Flashcard('paano', 'how'),
          Flashcard('pila', 'how many / how much'),
          Flashcard('ano nga', 'which'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_10_qc1',
          question: 'What does _ano nga_ mean in English?',
          options: ['which', 'how', 'what'],
          answer: 0,
          explain: '_ano nga_ = which.',
        ),
      ],
    ),
    LessonSection(
      title: 'Question words with a verb',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '_Ano ang ginakaon mo?_ (What are you eating?)',
          '_Sin-o ang nagkadto sa merkado?_ (Who went to the market?)',
          '_Diin ka makadto?_ (Where are you going?)',
          '_San-o ka mag-abot?_ (When will you arrive?)',
          '_Ngaa nagakadlaw ka?_ (Why are you laughing?)',
          '_Paano mo nabal-an?_ (How did you know?)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Yes/no questions',
      icon: Icons.help_outline_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('Hiligaynon has three ways to make a yes/no question:'),
        BulletsBlock([
          'Rising intonation: _Gusto mo?_ (Do you want it?)',
          'The particle **bala**: _Gusto mo bala?_ (Do you want it?), _Nagkaon ka na bala?_ (Have you eaten already?)',
          'The tag **ayhan** ("I wonder / perhaps"): _Nagaulan ayhan?_ (I wonder if it\'s raining.)',
        ]),
        ParagraphBlock(
          'Answers: _Oo_ (yes), _Indi_ (no), _Wala pa_ (not yet), _Ambot_ (I don\'t know).',
        ),
      ],
    ),
    LessonSection(
      title: 'Answering with full phrases',
      icon: Icons.help_outline_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('Practice both parts of the exchange:'),
        TableBlock(
          headers: ['Question', 'Full answer'],
          italicColumn: -1,
          rows: [
            ['Ano ang imo ngalan?', 'Ang ngalan ko amo si Ana.'],
            ['Diin ang balay mo?', 'Ang balay ko sa Jaro.'],
            ['San-o ka magkadto?', 'Magkadto ako buas.'],
            ['Sin-o ang imo manunudlo?', 'Si Ma\'am Rosa ang akon manunudlo.'],
            ['Pila ka tuig ka na?', 'Baynte anyos na ako.'],
            ['Ngaa nalate ka?', 'Nalate ako kay nagaulan.'],
          ],
        ),
        ParagraphBlock(
          '_Kay_ means "because," so _Nalate ako kay nagaulan_ is "I was late because it was raining."',
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
              'Ano ini? — Mangga ini.',
              'Ano ito? — Mangga ito.',
              'What is this? — This is a mango.',
            ],
            [
              'Sin-o siya? — Siya ang akon manunudlo.',
              'Sino siya? — Siya ang guro ko.',
              'Who is he/she? — He/she is my teacher.',
            ],
            [
              'Diin ka makadto? — Makadto ako sa merkado.',
              'Saan ka pupunta? — Pupunta ako sa palengke.',
              'Where are you going? — I\'m going to the market.',
            ],
            [
              'San-o ka magkadto sa Bacolod? — Sa Sabado.',
              'Kailan ka pupunta sa Bacolod? — Sa Sabado.',
              'When are you going to Bacolod? — On Saturday.',
            ],
            [
              'Nagkaon ka na bala? — Wala pa.',
              'Kumain ka na ba? — Hindi pa.',
              'Have you eaten already? — Not yet.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Diin ka makadto?_ is the usual way to ask "Where are you going?" and also a friendly roadside greeting. _Nagkaon ka na bala?_ combines _na_ ("already") and _bala_; _Wala pa_ ("not yet") is the natural answer. Answers to _diin_ take _sa_ + place.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'In Filipino and Hiligaynon communities, "Where are you going?" (Diin ka makadto? / Saan ka pupunta?) and "Have you eaten?" (Nagkaon ka na bala? / Kumain ka na ba?) are polite greetings and not intrusive questions.',
        ),
        QuizBlock(
          id: 'beginner_10_qc5',
          question: 'What does _Ano ini? — Mangga ini._ mean in English?',
          options: [
            'What is this? — This is a mango.',
            'When are you going to Bacolod? — On Saturday.',
            'Who is he/she? — He/she is my teacher.',
          ],
          answer: 0,
          explain:
              '_Ano ini? — Mangga ini._ = What is this? — This is a mango..',
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
          '_Saan_ and _nasaan_ both map to _diin_.',
          '_Kailan_ = _san-o_; _bakit_ = _ngaa_; _sino_ = _sin-o_; _ilan/magkano_ = _pila_.',
          'Filipino _ba_ = Hiligaynon _bala_. Both are optional.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _saan_ with a location answer instead of _diin_.',
          'Mixing up _ngaa_ (why) with _nga_ (linker).',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you ask one question with each question word?',
          'Can you answer _Nagkaon ka na bala?_ in three ways?',
          'Can you make a yes/no question with _bala_?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson11 = Lesson(
  id: 'beginner_11',
  number: 11,
  title: 'Sentence Building: Order, Negation & Markers',
  subtitle: 'Build affirmative, negative, and question sentences.',
  emoji: '🧱',
  level: 'Beginner',
  objectives: [
    'Build affirmative, negative, and question sentences.',
    'Understand predicate-first word order.',
    'Use the markers ang, sang, sa, si, ni, kay and the linker nga.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Three habits shape Hiligaynon sentences: the **predicate comes first**, small **markers** show each noun\'s role, and the **linker** _nga_ joins words.',
        ),
      ],
    ),
    LessonSection(
      title: 'Predicate-first word order',
      icon: Icons.translate_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'The **predicate** (the verb, adjective, or identity) comes first, followed by the subject:',
        ),
        TableBlock(
          headers: ['Type', 'Example', 'Literal order'],
          italicColumn: -1,
          rows: [
            ['Identity', 'Estudyante ako.', 'student I'],
            ['Description', 'Matahom ang balay.', 'beautiful the house'],
            ['Action', 'Nagakaon si Ana.', 'eating Ana'],
            ['Location', 'Ara siya sa balay.', 'is-at he/she at house'],
          ],
        ),
        ParagraphBlock(
          'This is the same "predicate-first" tendency that Filipino has, so it will feel familiar. What is different is the vocabulary and the markers.',
        ),
      ],
    ),
    LessonSection(
      title: 'The markers',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Marker', 'Role', 'Example'],
          italicColumn: -1,
          rows: [
            ['ang', 'the topic / subject (definite)', 'ang bata (the child)'],
            ['si', 'topic marker for a personal name', 'si Ana'],
            ['sang', 'of / definite object or doer', 'sang bata, sang libro'],
            ['ni', 'of a person / doer (personal name)', 'ni Ana'],
            ['sa', 'place, direction', 'sa balay, sa Iloilo'],
            ['kay', 'to / for (a person)', 'kay Ana'],
            ['mga', 'plural', 'ang mga bata'],
          ],
        ),
        ParagraphBlock(
          'In older and regional usage, **sing** replaces **sang** when the noun is indefinite or non-specific: _Nagkaon ako sing isda_ ("I ate some fish") versus _Nagkaon ako sang isda_ ("I ate the fish"). Many speakers use _sang_ for both today.',
        ),
      ],
    ),
    LessonSection(
      title: 'The linker nga',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '**Nga** joins a modifier to a noun or a clause to a noun:',
        ),
        BulletsBlock([
          '_matahom nga bata_ (a beautiful child)',
          '_daku nga balay_ (a big house)',
          '_ang bata nga nagakaon_ (the child who is eating)',
          '_duha ka libro nga bag-o_ (two new books)',
        ]),
        ParagraphBlock(
          '_Nga_ is written as a separate word and is pronounced with the _ng_ sound (see Lesson 1). It is the same job that _na/-ng_ does in Filipino.',
        ),
      ],
    ),
    LessonSection(
      title: 'Negation: indi, wala, ayaw',
      icon: Icons.block_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Word', 'Use', 'Example'],
          italicColumn: -1,
          rows: [
            [
              'indi',
              '"not / no" for descriptions, identity, future, and refusals',
              'Indi ako doktor. (I\'m not a doctor.) Indi ako magkadto. (I won\'t go.)',
            ],
            [
              'wala',
              '"did not (completed)" and "there is none"',
              'Wala ako nagkaon. (I didn\'t eat.) Wala ako sing kwarta. (I have no money.)',
            ],
            ['ayaw', '"don\'t" (command)', 'Ayaw pagkadto. (Don\'t go.)'],
            [
              'wala pa',
              '"not yet"',
              'Wala pa ako nagkaon. (I haven\'t eaten yet.)',
            ],
          ],
        ),
        ParagraphBlock(
          'Use **may** for "there is / have": _May kwarta ako._ (I have money.) Use **wala** for "there isn\'t": _Wala ako sing kwarta._ (I have no money.)',
        ),
        ParagraphBlock(
          'The choice between _indi_ and _wala_ is a common stumbling block:',
        ),
        BulletsBlock([
          '**Indi** = the answer to "will you...?" or "are you...?"',
          '**Wala** = the answer to "did you...?" or "do you have...?"',
        ]),
      ],
    ),
    LessonSection(
      title: 'The particles na, pa, lang',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Particle', 'Meaning', 'Example'],
          italicColumn: -1,
          rows: [
            ['na', 'already / now', 'Gutom na ako. (I\'m hungry now.)'],
            [
              'pa',
              'still / yet / more',
              'Ara pa siya. (He/she is still here.)',
            ],
            ['lang', 'only / just', 'Isa lang. (Just one.)'],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Yes/no questions and answers',
      icon: Icons.help_outline_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '_Estudyante ka bala?_ — _Oo, estudyante ako._ / _Indi, manunudlo ako._',
          '_Nagakaon ka?_ — _Oo._ / _Wala pa._',
          '_May kwarta ka?_ — _Oo, may kwarta ako._ / _Wala._',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Matahom ang balay.',
              'Maganda ang bahay.',
              'The house is beautiful.',
            ],
            [
              'Daku nga balay ang amon.',
              'Malaking bahay ang amin.',
              'Ours is a big house.',
            ],
            ['Indi ako doktor.', 'Hindi ako doktor.', 'I am not a doctor.'],
            [
              'Wala ako nagkadto sa eskwelahan.',
              'Hindi ako pumunta sa paaralan.',
              'I didn\'t go to school.',
            ],
            [
              'Ara pa si Nanay sa balay.',
              'Nasa bahay pa si Nanay.',
              'Mother is still at home.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** In _Matahom ang balay_, the adjective is the predicate and comes first, and _nga_ joins "big house" in _Daku nga balay_. _Indi_ negates an identity (_Indi ako doktor_); _wala_ negates a completed event (_Wala ako nagkadto_). _Ara pa_ combines "is here" with "still."',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'The word order "predicate first" is shared by Filipino, Hiligaynon, Cebuano, and most Philippine languages. Linguists consider it one of the defining features of the family.',
        ),
        FlashcardsBlock([
          Flashcard('Matahom ang balay.', 'The house is beautiful.'),
          Flashcard('Daku nga balay ang amon.', 'Ours is a big house.'),
          Flashcard('Indi ako doktor.', 'I am not a doctor.'),
          Flashcard('Ara pa si Nanay sa balay.', 'Mother is still at home.'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_11_qc7',
          question: 'What does _Ara pa si Nanay sa balay._ mean in English?',
          options: [
            'Ours is a big house.',
            'Mother is still at home.',
            'I didn\'t go to school.',
          ],
          answer: 1,
          explain: '_Ara pa si Nanay sa balay._ = Mother is still at home..',
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
          'Filipino _ang / ng / sa_ correspond to Hiligaynon _ang / sang / sa_.',
          'Filipino _hindi_ = _indi_; Filipino _huwag_ = _ayaw_.',
          'Filipino _na/-ng_ linker = Hiligaynon _nga_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _hindi_ or _huwag_.',
          'Using _indi_ for a past event (_Indi ako nagkaon_ means "I won\'t eat"; for "I didn\'t eat," say _Wala ako nagkaon_).',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you write three affirmative, three negative, and three question sentences?',
          'Can you explain the difference between _indi_ and _wala_?',
          'Can you translate "The child who is eating is Ben"?',
        ]),
      ],
    ),
  ],
);

const Lesson beginnerLesson12 = Lesson(
  id: 'beginner_12',
  number: 12,
  title: 'Daily Conversations',
  subtitle: 'Combine greetings, introductions, shopping, and directions into…',
  emoji: '💬',
  level: 'Beginner',
  objectives: [
    'Combine greetings, introductions, shopping, and directions into short conversations.',
    'Use repair strategies when you do not understand.',
    'Open, keep going, and close a conversation politely.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Real conversations have an opening, a middle, and a closing, and sometimes you need to ask someone to repeat or slow down. This lesson combines Lessons 1 to 11 with phrases for when things go wrong.',
        ),
      ],
    ),
    LessonSection(
      title: 'The shape of a conversation',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. **Greet**: _Maayong aga! Kamusta ka?_',
          '2. **Respond and ask back**: _Maayo man. Ikaw man?_',
          '3. **Main topic**: _Diin ka makadto?_ / _Gusto ko sang tubig._',
          '4. **Confirm**: _Amo ina?_ (Is that right?) _Sige._ (Okay.)',
          '5. **Close**: _Salamat gid. Ingat._ (Thank you very much. Take care.)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Repair phrases',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['Palihog liwata.', 'Pakiulit po.', 'Please repeat.'],
            ['Hinay-hinay lang.', 'Dahan-dahan lang.', 'Slowly, please.'],
            [
              'Wala ko nahangpan.',
              'Hindi ko naintindihan.',
              'I didn\'t understand.',
            ],
            [
              'Ano ang kahulugan sini?',
              'Ano ang ibig sabihin nito?',
              'What does this mean?',
            ],
            [
              'Ano ang Hiligaynon sang "thank you"?',
              'Ano ang Hiligaynon ng "thank you"?',
              'What is the Hiligaynon for "thank you"?',
            ],
            ['Indi ako kabalo.', 'Hindi ko alam.', 'I don\'t know.'],
            ['Amo ina?', 'Ganoon ba?', 'Is that so? / Is that right?'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('Palihog liwata.', 'Please repeat.'),
          Flashcard('Hinay-hinay lang.', 'Slowly, please.'),
          Flashcard('Wala ko nahangpan.', 'I didn\'t understand.'),
          Flashcard('Ano ang kahulugan sini?', 'What does this mean?'),
          Flashcard('Indi ako kabalo.', 'I don\'t know.'),
          Flashcard('Amo ina?', 'Is that so? / Is that right?'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'beginner_12_qc2',
          question: 'What does _Hinay-hinay lang._ mean in English?',
          options: [
            'What does this mean?',
            'Is that so? / Is that right?',
            'Slowly, please.',
          ],
          answer: 2,
          explain: '_Hinay-hinay lang._ = Slowly, please..',
        ),
      ],
    ),
    LessonSection(
      title: 'Useful small words',
      icon: Icons.translate_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Use'],
          italicColumn: 0,
          rows: [
            ['Sige', 'okay / go ahead', 'agreement'],
            ['Amo', 'that\'s it / yes, that\'s right', 'confirmation'],
            ['Basi', 'maybe', 'possibility'],
            ['Ay', 'oh', 'surprise'],
            ['Abaw', 'wow / oh my', 'surprise'],
            ['Ingat', 'take care', 'farewell'],
          ],
        ),
        QuizBlock(
          id: 'beginner_12_qc3',
          question: 'What does _Basi_ mean in English?',
          options: ['maybe', 'okay / go ahead', 'oh'],
          answer: 0,
          explain: '_Basi_ = maybe.',
        ),
      ],
    ),
    LessonSection(
      title: 'Farewells',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '_Ingat!_ (Take care!)',
          '_Hasta buas!_ (Until tomorrow!)',
          '_Mauna na ako._ (I\'ll go ahead.)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 2,
      blocks: [
        SubheadingBlock('Dialogue 1: Meeting a neighbor'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Maayong hapon, Manang!',
            'Good afternoon, ma\'am!',
          ),
          DialogueLine(
            'Friend',
            'Maayong hapon man. Diin ka makadto?',
            'Good afternoon. Where are you going?',
          ),
          DialogueLine(
            'You',
            'Makadto ako sa merkado.',
            'I\'m going to the market.',
          ),
          DialogueLine('Friend', 'Amo? Ingat.', 'Is that so? Take care.'),
          DialogueLine(
            'You',
            'Salamat gid. Hasta buas!',
            'Thank you very much. See you tomorrow!',
          ),
        ]),
        SubheadingBlock('Dialogue 2: Buying a drink'),
        DialogueBlock([
          DialogueLine(
            'Buyer',
            'Maayong aga. Gusto ko sang tubig.',
            'Good morning. I\'d like water.',
          ),
          DialogueLine('Seller', 'Ari.', 'Here you go.'),
          DialogueLine('Buyer', 'Tagpila ini?', 'How much is this?'),
          DialogueLine('Seller', 'Napulo ka pesos.', 'Ten pesos.'),
          DialogueLine(
            'Buyer',
            'Salamat. Ari ang bayad.',
            'Thanks. Here\'s the payment.',
          ),
        ]),
        SubheadingBlock('Dialogue 3: Asking for help'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Pasayloa ako. Diin ang ospital?',
            'Excuse me. Where is the hospital?',
          ),
          DialogueLine(
            'Friend',
            'Sa sunod nga dalan, liko sa wala.',
            'On the next street, turn left.',
          ),
          DialogueLine('You', 'Hinay-hinay lang, palihog.', 'Slowly, please.'),
          DialogueLine(
            'Friend',
            'Liko sa wala. Malapit lang.',
            'Turn left. It\'s near.',
          ),
          DialogueLine('You', 'Salamat gid.', 'Thank you very much.'),
        ]),
        ParagraphBlock(
          '**Discussion.** Dialogue 1 shows the standard opening, Dialogue 2 a practical purchase (_gusto ko sang_, _tagpila_), and Dialogue 3 repair (_hinay-hinay lang_, _palihog_). If you can act out all three, you can handle basic daily situations.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Ilonggos are widely known for being gentle-spoken and hospitable. It is common for a stranger who asks for directions to be walked to the place or given a drink of water.',
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
          'Plan your message in Filipino if it helps, but **rebuild it in Hiligaynon** rather than translating word by word.',
          'Many everyday closings (_ingat, sige, salamat_) are shared.',
          'Politeness: keep _ho/po_ with elders, use _palihog_ for requests.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Answering in Filipino as soon as you get stuck.',
          'Translating word-for-word (_Nasaan ka pupunta?_ is wrong; the natural forms are _Diin ka makadto?_ and _Saan ka pupunta?_).',
          'Not asking a follow-up question, which makes the conversation feel one-sided.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you perform three role-plays (greeting, buying, asking directions) without reading?',
          'Can you ask someone to repeat and slow down?',
          'Can you close a conversation politely?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson1 = Lesson(
  id: 'intermediate_1',
  number: 1,
  title: 'Expanded Vocabulary',
  subtitle:
      'Learn vocabulary in topic groups: emotions, health, weather, work,…',
  emoji: '📚',
  level: 'Intermediate',
  objectives: [
    'Learn vocabulary in topic groups: emotions, health, weather, work, transport, and school.',
    'Place new words in complete sentences and collocations.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Learn words in groups and phrases, not one at a time, so you see how they behave in real speech.',
        ),
      ],
    ),
    LessonSection(
      title: 'Feelings and emotions',
      icon: Icons.psychology_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English', 'Example'],
          italicColumn: 0,
          rows: [
            [
              'lipay / malipayon',
              'masaya',
              'happy',
              'Nalipay ako. (I was happy.)',
            ],
            ['subo', 'malungkot', 'sad', 'Nasubo siya. (She/he was sad.)'],
            ['kapoy', 'pagod', 'tired', 'Kapoy na ako. (I\'m already tired.)'],
            ['akig', 'galit', 'anger', 'Naakig siya. (He/she got angry.)'],
            ['kahadlok', 'takot', 'fear', 'Nahadlok ako. (I was scared.)'],
            [
              'kaibog',
              'inggit / pananabik',
              'envy / longing',
              'Naibog ako. (I felt envy/longing.)',
            ],
            [
              'kahuya',
              'hiya',
              'shame / shyness',
              'Nakahuya gid! (How embarrassing!)',
            ],
          ],
        ),
        ParagraphBlock(
          'The pattern _na-_ + feeling root ("became / felt") is very common: _nalipay, nasubo, naakig, nahadlok_.',
        ),
        FlashcardsBlock([
          Flashcard('lipay / malipayon', 'happy'),
          Flashcard('subo', 'sad'),
          Flashcard('kapoy', 'tired'),
          Flashcard('akig', 'anger'),
          Flashcard('kahadlok', 'fear'),
          Flashcard('kaibog', 'envy / longing'),
          Flashcard('kahuya', 'shame / shyness'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_1_qc1',
          question: 'What does _kahadlok_ mean in English?',
          options: ['fear', 'shame / shyness', 'happy'],
          answer: 0,
          explain: '_kahadlok_ = fear.',
        ),
      ],
    ),
    LessonSection(
      title: 'Health',
      icon: Icons.healing_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['hilanat', 'lagnat', 'fever'],
            ['sakit', 'sakit', 'sickness / pain'],
            ['masakit', 'masakit', 'painful'],
            ['ubo', 'ubo', 'cough'],
            ['sip-on', 'sipon', 'cold (runny nose)'],
            ['sakit sang ulo', 'sakit ng ulo', 'headache'],
            ['sakit sang tiyan', 'sakit ng tiyan', 'stomachache'],
            ['tambal', 'gamot', 'medicine'],
            ['doktor / nars', 'doktor / nars', 'doctor / nurse'],
            ['maayo na', 'magaling na', 'better / recovered'],
          ],
        ),
        BulletsBlock([
          '_Ginahilanat ako._ (I have a fever.)',
          '_Ginasakit ang ulo ko._ (My head hurts.)',
          '_Ano ang ginabatyag mo?_ (What are you feeling?)',
          '_Inom ka sang tambal._ (Take some medicine.)',
        ]),
        QuizBlock(
          id: 'intermediate_1_qc2',
          question: 'What does _ubo_ mean in English?',
          options: ['cough', 'painful', 'better / recovered'],
          answer: 0,
          explain: '_ubo_ = cough.',
        ),
      ],
    ),
    LessonSection(
      title: 'Weather',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['ulan', 'ulan', 'rain'],
            ['init / mainit', 'init / mainit', 'heat / hot'],
            ['hangin', 'hangin', 'wind'],
            ['bagyo', 'bagyo', 'typhoon / storm'],
            ['kilat', 'kidlat', 'lightning'],
            ['dag-om', 'ulap', 'cloud'],
            ['baha', 'baha', 'flood'],
          ],
        ),
        BulletsBlock([
          '_Mainit subong._ (It\'s hot today.)',
          '_Nagaulan._ (It\'s raining.)',
          '_May bagyo._ (There\'s a typhoon.)',
        ]),
        QuizBlock(
          id: 'intermediate_1_qc3',
          question: 'What does _ulan_ mean in English?',
          options: ['typhoon / storm', 'heat / hot', 'rain'],
          answer: 2,
          explain: '_ulan_ = rain.',
        ),
      ],
    ),
    LessonSection(
      title: 'Work and school',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['trabaho', 'trabaho', 'work'],
            ['kompanya', 'kumpanya', 'company'],
            ['sweldo', 'sweldo', 'salary'],
            ['kaupod sa trabaho', 'katrabaho', 'coworker'],
            ['klase', 'klase', 'class'],
            ['leksyon', 'aralin', 'lesson'],
            ['eksamen', 'pagsusulit', 'exam'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_1_qc4',
          question: 'What does _kompanya_ mean in English?',
          options: ['work', 'salary', 'company'],
          answer: 2,
          explain: '_kompanya_ = company.',
        ),
      ],
    ),
    LessonSection(
      title: 'Transport',
      icon: Icons.commute_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['dyip', 'dyip', 'jeepney'],
            ['traysikad', 'padyak', 'pedicab'],
            ['traysikel', 'traysikel', 'motor tricycle'],
            ['bus', 'bus', 'bus'],
            ['barko', 'barko', 'ship'],
            ['pump boat', 'bangka', 'motorized boat'],
            ['eroplano', 'eroplano', 'airplane'],
            ['pamasahe', 'pamasahe', 'fare'],
            ['sakay', 'sakay', 'ride'],
            ['para', 'para', 'stop (say to driver)'],
          ],
        ),
        ParagraphBlock(
          'Useful phrases: _Para!_ (Stop!, to a jeepney driver), _Pila ang pamasahe?_ (How much is the fare?), _Diin ako manaog?_ (Where do I get off?).',
        ),
        QuizBlock(
          id: 'intermediate_1_qc5',
          question: 'What does _pamasahe_ mean in English?',
          options: ['fare', 'pedicab', 'bus'],
          answer: 0,
          explain: '_pamasahe_ = fare.',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Kapoy na ako sang trabaho.',
              'Pagod na ako sa trabaho.',
              'I\'m tired from work.',
            ],
            [
              'Ginahilanat ako kag nagaubo.',
              'May lagnat ako at inuubo.',
              'I have a fever and I\'m coughing.',
            ],
            [
              'Nalipay ako kay nakapasar ako.',
              'Natuwa ako dahil pumasa ako.',
              'I was happy because I passed.',
            ],
            [
              'Mainit subong, pero buas basi mag-ulan.',
              'Mainit ngayon, pero bukas baka umulan.',
              'It\'s hot today, but tomorrow it may rain.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** These sentences combine vocabulary groups with earlier grammar: _kay_ gives a reason, _basi_ adds "maybe," and _pero_ contrasts. Describing a situation usually draws on several groups at once.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'The Philippines is a typhoon-prone country, so weather words like bagyo and baha appear often in news and conversation. The jeepney is a symbol of Filipino transport, and in Iloilo you will also see traysikad (pedicabs) in many neighborhoods.',
        ),
        QuizBlock(
          id: 'intermediate_1_qc6',
          question:
              'What does _Nalipay ako kay nakapasar ako._ mean in English?',
          options: [
            'I have a fever and I\'m coughing.',
            'I\'m tired from work.',
            'I was happy because I passed.',
          ],
          answer: 2,
          explain:
              '_Nalipay ako kay nakapasar ako._ = I was happy because I passed..',
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
          '_Masaya_ = _malipayon_; _malungkot_ = _nasubo_; _galit_ = _naakig_; _takot_ = _nahadlok_.',
          '_Gamot_ = _tambal_; _lagnat_ = _hilanat_.',
          '_Padyak_ = _traysikad_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Treating _kapoy_ as "lazy" (it means tired).',
          'Forgetting the _na-_ pattern for feelings in the past.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you describe your feelings today in three sentences?',
          'Can you explain to a doctor what hurts?',
          'Can you say what the weather is like and how you travel?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson2 = Lesson(
  id: 'intermediate_2',
  number: 2,
  title: 'Verb Aspect & Time Frames',
  subtitle: 'Narrate past, present, habitual, and future events with the…',
  emoji: '⏳',
  level: 'Intermediate',
  objectives: [
    'Narrate past, present, habitual, and future events with the correct verb form.',
    'Combine verbs with time expressions and the particles na and pa.',
    'Recognize the three main verb "families": mag-, ma-, and object-focus forms.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Building on Beginner Lesson 9, Hiligaynon thinks in two layers: **aspect** (ongoing, finished, not yet begun) plus **time words** that say when.',
        ),
      ],
    ),
    LessonSection(
      title: 'Two layers: aspect + time word',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**Aspect** (in the verb form): ongoing, completed, not yet begun.',
          '**Time word** (outside the verb): _subong_ (now), _buas_ (tomorrow), _kahapon_ (yesterday), _kada aga_ (every morning), _sang Sabado_ (last Saturday).',
        ]),
        ParagraphBlock(
          '_Nagakadto ako sa merkado kada Sabado._ (I go to the market every Saturday.) The verb says "ongoing/habitual," and _kada Sabado_ says how often.',
        ),
      ],
    ),
    LessonSection(
      title: 'The main verb families',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Family', 'Marker', 'What it does', 'Example'],
          italicColumn: -1,
          rows: [
            [
              'Actor-focus (mag- verbs)',
              'naga-, nag-, mag-',
              'the doer is in focus',
              'Nagabasa ako.',
            ],
            [
              'Actor-focus (ma- verbs)',
              'naga-, na-, ma-',
              'states, sudden events, involuntary actions',
              'Nalipay ako. / Matulog ako.',
            ],
            [
              'Object-focus',
              'gina-, gin-, -on',
              'the thing acted on is in focus',
              'Ginakaon ko ang isda.',
            ],
          ],
        ),
        ParagraphBlock(
          'The **ma-** family often describes states and results. Compare:',
        ),
        BulletsBlock([
          '_Nagtulog ako._ (I slept, deliberately.)',
          '_Nakatulog ako._ (I fell asleep, I managed to sleep.)',
          '_Nalipay ako._ (I became happy.)',
          '_Nakalakat ako._ (I was able to walk.)',
        ]),
        ParagraphBlock(
          'The prefix **naka-** often means "was able to" or "happened to": _Nakabasa ako sang libro._ (I was able to read the book.)',
        ),
      ],
    ),
    LessonSection(
      title: 'Object-focus in three aspects',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Aspect', 'Form', 'Example', 'Meaning'],
          italicColumn: -1,
          rows: [
            [
              'Ongoing',
              'gina- + root',
              'Ginakaon ko ang isda.',
              'I am eating the fish.',
            ],
            [
              'Completed',
              'gin- + root',
              'Ginkaon ko ang isda.',
              'I ate the fish.',
            ],
            [
              'Future',
              'root + -on',
              'Kaunon ko ang isda.',
              'I will eat the fish.',
            ],
          ],
        ),
        ParagraphBlock(
          'Notice the vowel change **kaon → kaunon**: the _o_ becomes _u_ when a suffix is added. Other examples: _inom → inumon_ (will drink it), _basa → basahon_ (will read it), _sulat → sulaton_ (will write it).',
        ),
      ],
    ),
    LessonSection(
      title: '"Already," "not yet," "still," and "just now"',
      icon: Icons.menu_book_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Example'],
          italicColumn: 0,
          rows: [
            ['na', 'already / now', 'Nagkaon na ako. (I\'ve already eaten.)'],
            [
              'wala pa',
              'not yet',
              'Wala pa ako nagkaon. (I haven\'t eaten yet.)',
            ],
            ['pa', 'still / more', 'Nagakaon pa ako. (I\'m still eating.)'],
            ['bag-o lang', 'just now', 'Bag-o lang ako nagkaon. (I just ate.)'],
          ],
        ),
        ParagraphBlock(
          'Position of the particles: **predicate + particle + pronoun**: _Nagkaon na ako._ _Nagakaon pa siya._ _Gutom na gid ako._',
        ),
        FlashcardsBlock([
          Flashcard('na', 'already / now'),
          Flashcard('wala pa', 'not yet'),
          Flashcard('pa', 'still / more'),
          Flashcard('bag-o lang', 'just now'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_2_qc4',
          question: 'What does _na_ mean in English?',
          options: ['already / now', 'still / more', 'not yet'],
          answer: 0,
          explain: '_na_ = already / now.',
        ),
      ],
    ),
    LessonSection(
      title: 'Time expressions for sequencing',
      icon: Icons.calendar_month_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['una', 'first'],
            ['dayon', 'then / next'],
            ['pagkatapos', 'afterward'],
            ['sa ulihi', 'finally / in the end'],
            ['kada aga / hapon / gab-i', 'every morning / afternoon / night'],
            ['sa aga', 'in the morning'],
            ['sang miaging bulan', 'last month'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_2_qc5',
          question: 'What does _kada aga / hapon / gab-i_ mean in English?',
          options: [
            'in the morning',
            'afterward',
            'every morning / afternoon / night',
          ],
          answer: 2,
          explain:
              '_kada aga / hapon / gab-i_ = every morning / afternoon / night.',
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
              'Kada aga nagabasa ako sang balita.',
              'Tuwing umaga nagbabasa ako ng balita.',
              'Every morning I read the news.',
            ],
            [
              'Sang Sabado nagkadto kami sa merkado.',
              'Noong Sabado pumunta kami sa palengke.',
              'Last Saturday we went to the market.',
            ],
            [
              'Buas magkadto ako sa Bacolod.',
              'Bukas pupunta ako sa Bacolod.',
              'Tomorrow I\'ll go to Bacolod.',
            ],
            [
              'Nakatulog ako sa dyip.',
              'Nakatulog ako sa dyip.',
              'I fell asleep in the jeepney.',
            ],
            [
              'Ginluto ni Nanay ang adobo.',
              'Niluto ni Nanay ang adobo.',
              'Mother cooked the adobo.',
            ],
            [
              'Wala pa ako nagkaon, pero gutom na gid ako.',
              'Hindi pa ako kumakain, pero gutom na gutom na ako.',
              'I haven\'t eaten yet, but I\'m very hungry now.',
            ],
            [
              'Una nagligo ako, dayon nagkaon.',
              'Una naligo ako, tapos kumain.',
              'First I bathed, then I ate.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Rows 1 to 3 show the two layers: aspect prefix plus time word. Row 4 uses _naka-_ for something that "happened to" the speaker, and row 5 uses object-focus _gin-_ so _ang adobo_ becomes the topic. Row 6 packs _wala pa_, _pero_, _na_, and _gid_ into one natural sentence; row 7 shows sequence with _una_ and _dayon_.',
        ),
        ParagraphBlock('Write a short diary in three parts:'),
        BulletsBlock([
          '_Kahapon: Nagtrabaho ako kag nagkadto sa merkado._',
          '_Subong: Nagatuon ako sang Hiligaynon._',
          '_Buas: Magkadto ako sa simbahan._',
        ]),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Linguists group Hiligaynon with the Philippine-type languages, whose verbs express "focus" (which participant is highlighted) rather than English-style tense. This is why a single Hiligaynon verb form can be translated into English past, present, or future depending on the time word.',
        ),
        QuizBlock(
          id: 'intermediate_2_qc6',
          question:
              'What does _Una nagligo ako, dayon nagkaon._ mean in English?',
          options: [
            'Tomorrow I\'ll go to Bacolod.',
            'First I bathed, then I ate.',
            'I fell asleep in the jeepney.',
          ],
          answer: 1,
          explain:
              '_Una nagligo ako, dayon nagkaon._ = First I bathed, then I ate..',
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
          'Filipino _na_ and _pa_ have close cousins in Hiligaynon (_na_, _pa_).',
          'Filipino _kakain / kumain / kumakain_ correspond to _magkaon / nagkaon / nagakaon_.',
          'Filipino _-in_ (object focus, _kinain_) corresponds to Hiligaynon _gin-_ (_ginkaon_) and _-on_ (_kaunon_).',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using Filipino affixes (_-um-_, _-in-_).',
          'Using _nagakaon_ with _kahapon_ (use _nagkaon_).',
          'Forgetting the vowel change in _-on_ forms (_kaonon_ instead of _kaunon_).',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you narrate yesterday, today, and tomorrow in three sentences?',
          'Can you make the object-focus forms for _inom_ and _basa_?',
          'Can you explain the difference between _nagtulog_ and _nakatulog_?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson3 = Lesson(
  id: 'intermediate_3',
  number: 3,
  title: 'Markers, Linkers & Introduction to Focus',
  subtitle: 'Distinguish the functions of ang, sang, sa, si, ni, kay, and nga.',
  emoji: '🔗',
  level: 'Intermediate',
  objectives: [
    'Distinguish the functions of ang, sang, sa, si, ni, kay, and nga.',
    'Recognize the difference between actor-focus and object-focus sentences.',
    'Choose the correct pronoun set for each role.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Small markers show who does what to whom. This is the map of the focus (voice) system you will study fully in the Advanced level.',
        ),
      ],
    ),
    LessonSection(
      title: 'The markers, in full',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Function', 'Common noun', 'Personal name', 'Pronoun set'],
          italicColumn: -1,
          rows: [
            [
              'Topic / "ang" phrase (the spotlighted participant)',
              'ang',
              'si',
              'ako, ikaw/ka, siya, kami, kita, kamo, sila',
            ],
            [
              'Doer / possessor / object (non-topic)',
              'sang',
              'ni',
              'ko, mo, niya, namon, naton, ninyo, nila',
            ],
            [
              'Place / goal / recipient',
              'sa',
              'kay',
              'akon, imo, iya, amon, aton, inyo, ila (after sa)',
            ],
          ],
        ),
        ParagraphBlock('Examples:'),
        BulletsBlock([
          '_Ang bata_ / _Si Ana_ (the child / Ana: topic)',
          '_Sang bata_ / _Ni Ana_ (of the child / of Ana)',
          '_Sa balay_ / _Kay Ana_ (to the house / to Ana)',
        ]),
      ],
    ),
    LessonSection(
      title: 'The two most important sentence types',
      icon: Icons.auto_awesome_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock(
          '**Actor-focus (AF).** The **doer** is the "ang" phrase. The object, if any, takes _sang_.',
        ),
        BulletsBlock([
          '_Nagluto si Nanay sang adobo._ (Mother cooked adobo.)',
          '_Nagbasa ako sang libro._ (I read a book.)',
        ]),
        ParagraphBlock(
          '**Object-focus (OF).** The **thing acted on** is the "ang" phrase. The doer takes _sang/ni_ or the _ko/mo/niya_ pronouns.',
        ),
        BulletsBlock([
          '_Ginluto ni Nanay ang adobo._ (Mother cooked the adobo.)',
          '_Ginbasa ko ang libro._ (I read the book.)',
        ]),
        ParagraphBlock(
          'Notice what changed: in AF, _ako_ and _si Nanay_ are the "ang" phrases; in OF, _ko_ and _ni Nanay_ are the doers, and _ang libro_ and _ang adobo_ take over as the topic. In English translation, both are simply "I read the book," but the emphasis is different.',
        ),
        ParagraphBlock(
          '**A helpful way to think about it.** The "ang" phrase answers the question "which one?" or "who or what is this sentence about?" In _Ginbasa ko ang libro_, the sentence is about _the book_ (which specific book? The one I read). In _Nagbasa ako sang libro_, the sentence is about _me_ (I am the one who read a book).',
        ),
      ],
    ),
    LessonSection(
      title: 'Definite versus indefinite',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**Definite object** (a specific, known thing): usually object-focus. _Ginkaon ko ang isda._ (I ate the fish (the one we both know).)',
          '**Indefinite object** (a non-specific thing): usually actor-focus. _Nagkaon ako sang isda._ (I ate fish.)',
        ]),
        ParagraphBlock(
          'This is a strong tendency, not a rigid law, but it is a reliable guide.',
        ),
      ],
    ),
    LessonSection(
      title: 'The linker nga',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Nga_ links a modifier to a noun and a clause to a noun:',
        ),
        BulletsBlock([
          '_daku nga balay_ (a big house)',
          '_ang bata nga nagbasa sang libro_ (the child who read the book)',
          '_ang libro nga ginbasa ko_ (the book that I read)',
        ]),
        ParagraphBlock(
          'The last two examples show **relative clauses**. In Hiligaynon, the linker _nga_ does the job of English "who/that/which."',
        ),
      ],
    ),
    LessonSection(
      title: 'Pronoun sets in a sentence',
      icon: Icons.bolt_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Sentence', 'Analysis'],
          italicColumn: -1,
          rows: [
            [
              'Nagbasa ako sang libro.',
              'ako (topic set): the doer is the topic (AF)',
            ],
            [
              'Ginbasa ko ang libro.',
              'ko (doer set): the doer is not the topic (OF)',
            ],
            [
              'Ginhatag ko ang libro sa imo.',
              'sa imo (place/recipient set): to you',
            ],
            ['Akon nga libro ini.', 'akon (possessor before noun)'],
          ],
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
              'Nagbasa ako sang libro.',
              'Nagbasa ako ng libro.',
              'I read a book.',
            ],
            [
              'Ginbasa ko ang libro.',
              'Binasa ko ang libro.',
              'I read the book.',
            ],
            [
              'Nagluto si Nanay sang adobo.',
              'Nagluto si Nanay ng adobo.',
              'Mother cooked adobo.',
            ],
            [
              'Ginluto ni Nanay ang adobo.',
              'Niluto ni Nanay ang adobo.',
              'Mother cooked the adobo.',
            ],
            [
              'Ginhatag ko kay Maria ang libro.',
              'Ibinigay ko kay Maria ang libro.',
              'I gave the book to Maria.',
            ],
            [
              'Ang bata nga nagakaon amo si Ben.',
              'Ang batang kumakain ay si Ben.',
              'The child who is eating is Ben.',
            ],
            [
              'Ang balay ni Ana daku.',
              'Malaki ang bahay ni Ana.',
              'Ana\'s house is big.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Rows 1 and 2 are a pair: same meaning, different focus. Row 5 marks the recipient with _kay_ while _ang libro_ is the topic (OF). Row 6 is a relative clause with _nga_, and row 8 puts possessive _ni Ana_ after the noun.',
        ),
        ParagraphBlock('Try this drill with any transitive verb:'),
        BulletsBlock([
          '1. Write an AF sentence with a **doer** as topic: _Nagbasa si Ana sang libro._',
          '2. Rewrite it as an OF sentence with the **object** as topic: _Ginbasa ni Ana ang libro._',
          '3. Make the future OF: _Basahon ni Ana ang libro._',
        ]),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Philippine languages are famous among linguists for their focus systems. In some languages, the "topic" is called the subject, but that term does not fit perfectly; the "ang" phrase is more like a spotlight than a grammatical subject.',
        ),
        QuizBlock(
          id: 'intermediate_3_qc6',
          question: 'What does _Ang balay ni Ana daku._ mean in English?',
          options: [
            'The child who is eating is Ben.',
            'I read the book.',
            'Ana\'s house is big.',
          ],
          answer: 2,
          explain: '_Ang balay ni Ana daku._ = Ana\'s house is big..',
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
          'Filipino _ang / ng / sa_ = Hiligaynon _ang / sang / sa_.',
          'Filipino _si / ni / kay_ = Hiligaynon _si / ni / kay_ (same!).',
          'Filipino object-focus _-in / i- / -an_ = Hiligaynon _gin-_, _-on_, _-an_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _ako_ where _ko_ is needed in an OF sentence (_Ginbasa ako ang libro_).',
          'Using _ang_ for an indefinite object (_Nagbasa ako ang libro_).',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you transform an AF sentence into an OF sentence?',
          'Can you explain what the "ang" phrase means in your own words?',
          'Can you translate "the book that I read"?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson4 = Lesson(
  id: 'intermediate_4',
  number: 4,
  title: 'Particles for Natural Expression',
  subtitle: 'Recognize the most common Hiligaynon particles.',
  emoji: '✨',
  level: 'Intermediate',
  objectives: [
    'Recognize the most common Hiligaynon particles.',
    'Understand their meaning and typical position.',
    'Use particles to sound more natural, warm, and precise.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Particles add attitude (emphasis, softening, agreement, surprise). Without them, a sentence is correct but can sound stiff or "translated."',
        ),
      ],
    ),
    LessonSection(
      title: 'The core particles',
      icon: Icons.link_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Particle', 'Basic meaning', 'Example', 'Effect'],
          italicColumn: -1,
          rows: [
            ['gid', 'really / truly / very', 'Matahom gid.', 'emphasis'],
            [
              'man',
              'also / too / actually (softens)',
              'Ikaw man? / Maayo man.',
              'addition or soft tone',
            ],
            [
              'lang',
              'only / just',
              'Isa lang. / Wala lang.',
              'limitation, softening',
            ],
            ['pa', 'still / yet / more', 'Ara pa siya.', 'continuation'],
            ['na', 'already / now', 'Gutom na ako.', 'change of state'],
            ['bala', '(question marker)', 'Gusto mo bala?', 'question'],
            [
              'daw',
              'it seems / as if / reportedly',
              'Daw mainit.',
              'appearance, hearsay',
            ],
            ['basi', 'maybe', 'Basi mag-ulan.', 'possibility'],
            ['ayhan', 'I wonder / perhaps', 'Nagaulan ayhan?', 'wondering'],
            ['gani', 'that is why / indeed', 'Amo gani.', 'emphasis or reason'],
            ['kunta', 'hopefully / I wish', 'Magpauli kunta siya.', 'wish'],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Meaning in context',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '**Gid** strengthens the word it follows: _namit gid_ (really delicious), _salamat gid_ (thank you very much), _tuod gid_ (really true).',
        ),
        ParagraphBlock('**Man** has many uses:'),
        BulletsBlock([
          'Adds "also": _Ako man._ (Me too.)',
          'Returns a question: _Ikaw man?_ (And you?)',
          'Softens: _Maayo man._ (I\'m fine, actually / thanks for asking.)',
          'Contradicts gently: _Indi man._ (Not really.)',
        ]),
        ParagraphBlock(
          '**Lang** makes something small or gentle: _Sige lang._ (It\'s fine / go ahead.) _Wala lang._ (It\'s nothing.) _Diri lang._ (Just here.) _Isa lang._ (Only one.)',
        ),
        ParagraphBlock(
          '**Na** and **pa** are opposites of time: _na_ is "already," _pa_ is "still": _Nagkaon na ako._ / _Wala pa ako nagkaon._',
        ),
        ParagraphBlock(
          '**Daw** signals appearance or hearsay: _Daw hilanat ka._ (You seem to have a fever.) _Daw indi siya mag-abot._ (It seems he/she won\'t come.)',
        ),
      ],
    ),
    LessonSection(
      title: 'Where particles go',
      icon: Icons.place_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('The usual order is:'),
        SubheadingBlock('predicate + particle(s) + pronoun / topic'),
        BulletsBlock([
          '_Gutom na ako._ (hungry + already + I)',
          '_Nagakaon pa siya._ (eating + still + he/she)',
          '_Matahom gid ang balay._ (beautiful + really + the house)',
          '_Wala pa gid ako nagkaon._ (not yet + really + I + ate)',
        ]),
        ParagraphBlock(
          'When two particles combine, common orders include _na gid_, _pa gid_, and _lang man_.',
        ),
      ],
    ),
    LessonSection(
      title: 'Tone matters',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'The same word can change meaning with tone. _Ambot_ can mean:',
        ),
        BulletsBlock([
          '"I don\'t know" (neutral).',
          '"Whatever" (dismissive).',
          '"I\'m not sure, but..." (hesitant).',
        ]),
        ParagraphBlock(
          'A particle plus tone builds the meaning. Listen carefully to native speakers and imitate rhythm.',
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
            ['Tuod gid.', 'Totoo talaga.', 'It\'s really true.'],
            ['Ako man.', 'Ako rin.', 'Me too.'],
            ['Ikaw man?', 'Ikaw naman?', 'And you?'],
            [
              'Hinay-hinay lang.',
              'Dahan-dahan lang.',
              'Slowly, please. / Take it easy.',
            ],
            [
              'Gutom na gid ako.',
              'Gutom na gutom na ako.',
              'I\'m really hungry now.',
            ],
            [
              'Kabay pa kunta nga maayo ang tanan.',
              'Sana maging maayos ang lahat.',
              'I hope everything turns out well.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Tuod gid_ is a complete agreement phrase. _Ako man_ and _Ikaw man?_ show two uses of _man_. _Hinay-hinay lang_ softens a request through reduplication plus _lang_. _Gutom na gid ako_ stacks particles for emphasis, _daw_ and _basi_ express probability, and _kabay pa_ means "I hope" (_kunta_ strengthens the wish).',
        ),
        ParagraphBlock('A practice conversation:'),
        DialogueBlock([
          DialogueLine('You', 'Kamusta ka?', 'How are you?'),
          DialogueLine('Friend', 'Maayo man. Ikaw man?', 'Fine. And you?'),
          DialogueLine(
            'You',
            'Maayo man, pero kapoy na gid.',
            'Fine, but really tired now.',
          ),
          DialogueLine(
            'Friend',
            'Ako man. Sige, hinay-hinay lang.',
            'Me too. Okay, take it easy.',
          ),
        ]),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Particles are one of the biggest differences between textbook language and everyday speech. A learner who can use gid, man, lang, na, and pa correctly is often mistaken for a much more advanced speaker.',
        ),
        FlashcardsBlock([
          Flashcard('Tuod gid.', 'It\'s really true.'),
          Flashcard('Ako man.', 'Me too.'),
          Flashcard('Ikaw man?', 'And you?'),
          Flashcard('Gutom na gid ako.', 'I\'m really hungry now.'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_4_qc5',
          question: 'What does _Ikaw man?_ mean in English?',
          options: ['And you?', 'Me too.', 'It\'s really true.'],
          answer: 0,
          explain: '_Ikaw man?_ = And you?.',
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
          '_Talaga_ = _gid_; _rin/din/naman_ = _man_; _lang_ = _lang_; _pa_ = _pa_; _na_ = _na_.',
          'Filipino _ba_ = Hiligaynon _bala_; Filipino _baka_ = _basi_; Filipino _parang_ = _daw_; Filipino _sana_ = _kunta_.',
          'Do not translate particles mechanically: _man_ can be _rin_, _naman_, or "actually," depending on context.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Putting particles at the end of the sentence, after the pronoun.',
          'Using _man_ everywhere without understanding its meaning.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you use _gid_, _man_, _lang_, _na_, and _pa_ in one sentence each?',
          'Can you explain what _Ikaw man?_ means and why?',
          'Can you say "maybe," "it seems," and "I hope" in Hiligaynon?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson5 = Lesson(
  id: 'intermediate_5',
  number: 5,
  title: 'Describing & Comparing',
  subtitle: 'Describe people, places, and things with adjectives, colors, and…',
  emoji: '🎨',
  level: 'Intermediate',
  objectives: [
    'Describe people, places, and things with adjectives, colors, and sizes.',
    'Compare two things and name the "most" of a group.',
    'Use intensifiers and expressions of similarity.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Descriptions use _ma-_ adjectives, the linker _nga_, and particles that adjust strength. Comparison adds _mas_ ("more") and _pinaka-_ ("most").',
        ),
      ],
    ),
    LessonSection(
      title: 'Adjectives',
      icon: Icons.compare_arrows_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('Many Hiligaynon adjectives start with **ma-**:'),
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English', 'Opposite'],
          italicColumn: 0,
          rows: [
            ['matahom', 'maganda', 'beautiful', 'pangit (ugly)'],
            ['daku', 'malaki', 'big', 'gamay (small)'],
            ['mataas', 'mataas', 'tall / high', 'mubo (short)'],
            ['malayo', 'malayo', 'far', 'malapit (near)'],
            ['bag-o', 'bago', 'new', 'daan (old, for things)'],
            ['mabaskog', 'malakas', 'strong', 'mahuyang (weak)'],
            ['madasig', 'mabilis', 'fast', 'mahinay (slow)'],
            ['mabuot', 'mabait', 'kind', 'malain (bad)'],
            ['manggaranon', 'mayaman', 'rich', 'imol (poor)'],
          ],
        ),
        ParagraphBlock(
          'Use _tigulang_ for an old **person** and _daan_ for an old **thing**.',
        ),
        FlashcardsBlock([
          Flashcard('matahom', 'beautiful'),
          Flashcard('daku', 'big'),
          Flashcard('mataas', 'tall / high'),
          Flashcard('malayo', 'far'),
          Flashcard('bag-o', 'new'),
          Flashcard('mabaskog', 'strong'),
          Flashcard('madasig', 'fast'),
          Flashcard('mabuot', 'kind'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_5_qc1',
          question: 'What does _malayo_ mean in English?',
          options: ['far', 'new', 'strong'],
          answer: 0,
          explain: '_malayo_ = far.',
        ),
      ],
    ),
    LessonSection(
      title: 'Colors',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['puti', 'white'],
            ['itom', 'black'],
            ['pula', 'red'],
            ['dilaw (also dalag)', 'yellow'],
            ['berde (also lunhaw)', 'green'],
            ['asul', 'blue'],
            ['kayumanggi', 'brown'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_5_qc2',
          question: 'What does _dilaw (also dalag)_ mean in English?',
          options: ['yellow', 'blue', 'black'],
          answer: 0,
          explain: '_dilaw (also dalag)_ = yellow.',
        ),
      ],
    ),
    LessonSection(
      title: 'Describing a noun',
      icon: Icons.compare_arrows_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Use _nga_ between the adjective and the noun, or make the adjective a predicate:',
        ),
        BulletsBlock([
          '_matahom nga bata_ (a beautiful child)',
          '_Matahom ang bata._ (The child is beautiful.)',
          '_daku nga balay nga puti_ (a big white house)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Intensifiers',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Example'],
          italicColumn: 0,
          rows: [
            ['gid', 'very / really', 'Matahom gid.'],
            [
              'hilabihan',
              'extremely',
              'Hilabihan ka init. (It\'s extremely hot.)',
            ],
            ['medyo', 'somewhat', 'Medyo mahal. (Somewhat expensive.)'],
            ['sobra', 'too much', 'Sobra ka mahal. (Too expensive.)'],
            ['gamay lang', 'just a little', 'Gamay lang ang init.'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_5_qc4',
          question: 'What does _hilabihan_ mean in English?',
          options: ['extremely', 'very / really', 'somewhat'],
          answer: 0,
          explain: '_hilabihan_ = extremely.',
        ),
      ],
    ),
    LessonSection(
      title: 'Comparing two things',
      icon: Icons.compare_arrows_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('**"More than":** _mas_ + adjective + _kaysa_ (than):'),
        BulletsBlock([
          '_Mas daku ini kaysa dira._ (This is bigger than that.)',
          '_Mas mahal ang isda kaysa manok._ (Fish is more expensive than chicken.)',
        ]),
        ParagraphBlock('**"As ... as / same":** _pareho_ (same):'),
        BulletsBlock([
          '_Pareho kadaku ang duha ka balay._ (The two houses are equally big.)',
          '_Pareho kita sang edad._ (We\'re the same age.)',
        ]),
        ParagraphBlock('**"Most":** _pinaka-_ + adjective:'),
        BulletsBlock([
          '_Pinakamatahom siya._ (She/he is the most beautiful.)',
          '_Pinakadaku ini sa tanan._ (This is the biggest of all.)',
        ]),
        ParagraphBlock('**"Similar to":** _daw_:'),
        BulletsBlock([
          '_Daw amon ang imo balay._ (Your house looks like ours.)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Matahom nga balay ang amon.',
              'Magandang bahay ang amin.',
              'Ours is a beautiful house.',
            ],
            [
              'Mas mataas si Ben kaysa kay Jose.',
              'Mas matangkad si Ben kaysa kay Jose.',
              'Ben is taller than Jose.',
            ],
            [
              'Mas mahal ang bag-o kaysa sa daan.',
              'Mas mahal ang bago kaysa sa luma.',
              'The new one costs more than the old one.',
            ],
            [
              'Pinakamatahom nga baybay ang Guimaras.',
              'Pinakamagandang dalampasigan ang Guimaras.',
              'Guimaras has the most beautiful beach.',
            ],
            [
              'Pareho kita sang edad.',
              'Magkasing-edad tayo.',
              'We\'re the same age.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Mas ... kaysa_ makes a comparison; note _kay_ before the second name. _Pareho kita sang edad_ uses inclusive _kita_ for speaker and listener together. _Pinaka-_ attaches directly to the adjective.',
        ),
        ParagraphBlock('Describe a house using three features:'),
        ParagraphBlock(
          '_Ang amon nga balay daku, puti, kag malapit sa baybay._',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Guimaras is famed for its mangoes, considered among the sweetest in the Philippines, and for its beaches.',
        ),
        QuizBlock(
          id: 'intermediate_5_qc6',
          question:
              'What does _Pinakamatahom nga baybay ang Guimaras._ mean in English?',
          options: [
            'We\'re the same age.',
            'Ours is a beautiful house.',
            'Guimaras has the most beautiful beach.',
          ],
          answer: 2,
          explain:
              '_Pinakamatahom nga baybay ang Guimaras._ = Guimaras has the most beautiful beach..',
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
          'Filipino _maganda_ = _matahom_ (people, places) and _maayo_ (quality).',
          'Filipino _malaki/maliit_ = _daku/gamay_.',
          'Filipino _mas ... kaysa_ is the same pattern: _mas daku kaysa_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Forgetting _nga_ between adjective and noun.',
          'Forgetting _kay_ before a personal name in comparisons.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you describe your house or room in three sentences?',
          'Can you compare two foods, two places, and two people?',
          'Can you say "the most" for three different adjectives?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson6 = Lesson(
  id: 'intermediate_6',
  number: 6,
  title: 'Expressing Opinions',
  subtitle: 'State likes, dislikes, preferences, agreement, disagreement, and…',
  emoji: '💭',
  level: 'Intermediate',
  objectives: [
    'State likes, dislikes, preferences, agreement, disagreement, and uncertainty.',
    'Give reasons and contrast ideas.',
    'Disagree politely.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Opinion language lets you say what you think and why. In a culture that values harmony, _how_ you disagree matters as much as what you say.',
        ),
      ],
    ),
    LessonSection(
      title: 'Likes and dislikes',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['Gusto ko...', 'Gusto ko...', 'I like / want...'],
            ['Indi ko gusto...', 'Ayaw ko...', 'I don\'t like...'],
            [
              'Mas gusto ko ang... kaysa...',
              'Mas gusto ko ang... kaysa...',
              'I prefer... to...',
            ],
            [
              'Palangga ko...',
              'Mahal ko... / Paborito ko...',
              'I love / am fond of...',
            ],
            ['Wala ako kabalo...', 'Hindi ko alam...', 'I don\'t know...'],
            ['Kabalo ako...', 'Alam ko...', 'I know...'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('Gusto ko...', 'I like / want...'),
          Flashcard('Indi ko gusto...', 'I don\'t like...'),
          Flashcard('Palangga ko...', 'I love / am fond of...'),
          Flashcard('Wala ako kabalo...', 'I don\'t know...'),
          Flashcard('Kabalo ako...', 'I know...'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_6_qc1',
          question: 'What does _Kabalo ako..._ mean in English?',
          options: ['I love / am fond of...', 'I know...', 'I like / want...'],
          answer: 1,
          explain: '_Kabalo ako..._ = I know....',
        ),
      ],
    ),
    LessonSection(
      title: 'Opinion frames',
      icon: Icons.psychology_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Strength'],
          italicColumn: 0,
          rows: [
            ['Sa banta ko...', 'In my opinion...', 'neutral'],
            ['Sa akon nga hunahuna...', 'In my thinking...', 'neutral'],
            [
              'Sa akon nga panan-aw...',
              'From my point of view...',
              'thoughtful',
            ],
            ['Sigurado ako nga...', 'I am sure that...', 'strong'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_6_qc2',
          question: 'What does _Sa akon nga panan-aw..._ mean in English?',
          options: [
            'I am sure that...',
            'From my point of view...',
            'In my opinion...',
          ],
          answer: 1,
          explain: '_Sa akon nga panan-aw..._ = From my point of view....',
        ),
      ],
    ),
    LessonSection(
      title: 'Agreement and disagreement',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Nagasugot ako.', 'I agree.'],
            ['Amo man. / Ako man.', 'Same here. / Me too.'],
            ['Tuod gid.', 'That\'s really true.'],
            ['Tama ka.', 'You\'re right.'],
            ['Indi ako nagasugot.', 'I don\'t agree.'],
            ['Sayop.', 'That\'s wrong. (blunt)'],
            [
              'Tuod, pero sa banta ko...',
              'True, but in my opinion... (polite)',
            ],
            [
              'Nagatahod ako sang imo hunahuna, pero...',
              'I respect your thinking, but... (formal)',
            ],
          ],
        ),
        QuizBlock(
          id: 'intermediate_6_qc3',
          question: 'What does _Tuod gid._ mean in English?',
          options: ['I agree.', 'That\'s really true.', 'You\'re right.'],
          answer: 1,
          explain: '_Tuod gid._ = That\'s really true..',
        ),
      ],
    ),
    LessonSection(
      title: 'Giving reasons and contrasts',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['tungod kay', 'because of / since'],
            ['amo nga', 'that is why'],
            ['pero', 'but'],
            ['apang', 'however (formal)'],
            ['bisan', 'although / even if'],
            ['ukon', 'or'],
          ],
        ),
        ParagraphBlock(
          'A complete opinion has three parts: **opinion + reason + example or contrast**.',
        ),
        ParagraphBlock(
          '_Sa banta ko, mas maayo ang dyip kaysa bus kay mas barato. Pero mas komportable ang bus._ (In my opinion, the jeepney is better than the bus because it\'s cheaper. But the bus is more comfortable.)',
        ),
        QuizBlock(
          id: 'intermediate_6_qc4',
          question: 'What does _amo nga_ mean in English?',
          options: ['or', 'that is why', 'although / even if'],
          answer: 1,
          explain: '_amo nga_ = that is why.',
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
              'Gusto ko ang batchoy kay namit gid.',
              'Gusto ko ang batchoy dahil masarap talaga.',
              'I like batchoy because it\'s really delicious.',
            ],
            [
              'Indi ko gusto ang mainit nga panahon.',
              'Ayaw ko ng mainit na panahon.',
              'I don\'t like hot weather.',
            ],
            [
              'Mas gusto ko ang baybay kaysa bukid.',
              'Mas gusto ko ang dagat kaysa bundok.',
              'I prefer the sea to the mountains.',
            ],
            [
              'Sa banta ko, importante ang edukasyon.',
              'Sa palagay ko, mahalaga ang edukasyon.',
              'In my opinion, education is important.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Gusto ko_ + _kay_ + reason is the simplest complete opinion. In _Indi ko gusto_, _indi_ goes first. _Mas gusto ko... kaysa..._ states a preference. _Tuod, pero..._ softens disagreement by acknowledging the other person first, and _basi_ makes an idea tentative.',
        ),
        ParagraphBlock('A polite disagreement:'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Sa banta ko, mas maayo ang mag-uli sa aga.',
            'In my opinion, it\'s better to go home early.',
          ),
          DialogueLine(
            'Friend',
            'Tuod, pero madamo pa ang trabaho.',
            'True, but there\'s still a lot of work.',
          ),
          DialogueLine(
            'You',
            'Amo man. Sige, hinay-hinay lang.',
            'That\'s so. Okay, take it easy.',
          ),
        ]),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'In Filipino and Visayan culture, smooth interpersonal relationships (often called pakikisama) are valued. Direct disagreement is often softened with phrases like Tuod, pero... ("True, but...").',
        ),
        QuizBlock(
          id: 'intermediate_6_qc5',
          question:
              'What does _Mas gusto ko ang baybay kaysa bukid._ mean in English?',
          options: [
            'I don\'t like hot weather.',
            'In my opinion, education is important.',
            'I prefer the sea to the mountains.',
          ],
          answer: 2,
          explain:
              '_Mas gusto ko ang baybay kaysa bukid._ = I prefer the sea to the mountains..',
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
          '_Sa palagay ko_ = _sa banta ko_; _ayaw ko_ = _indi ko gusto_; _sang-ayon_ = _sugot_.',
          '_Kasi / dahil_ = _kay_; _pero_ = _pero_; _kahit_ = _bisan_.',
          'Filipino _mahal_ can mean "expensive" and "beloved"; Hiligaynon separates them: _mahal_ (expensive) and _palangga_ (beloved).',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Being too direct without softening.',
          'Forgetting _kay_ before the reason.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you state an opinion with a reason and a contrast?',
          'Can you politely disagree in two ways?',
          'Can you say what you prefer and why?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson7 = Lesson(
  id: 'intermediate_7',
  number: 7,
  title: 'Real-Life Simulations',
  subtitle: 'Handle common situations: shops, restaurants, clinics, school or…',
  emoji: '🛒',
  level: 'Intermediate',
  objectives: [
    'Handle common situations: shops, restaurants, clinics, school or work, and transport.',
    'Ask for clarification and respond to practical requests.',
    'Adjust politeness to the person you are speaking with.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Each situation needs a polite opening, a clear request or information, and a closing. This lesson gives ready-made frames for six everyday situations.',
        ),
        CalloutBlock(
          title: 'Note',
          emoji: '📝',
          color: pink500,
          text:
              'The clinic scenario is for basic practice only. In a real medical situation, ask for a qualified interpreter.',
        ),
      ],
    ),
    LessonSection(
      title: 'Scenario A: The restaurant',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Palihog, may lamesa pa bala?',
              'Please, is there a table still available?',
            ],
            ['Ano ang rekomendado ninyo?', 'What do you recommend?'],
            [
              'Gusto ko sang batchoy kag tubig.',
              'I\'d like batchoy and water.',
            ],
            ['Wala sing sili, palihog.', 'No chili, please.'],
            ['Palihog, ang bayad namon.', 'Our bill, please.'],
          ],
        ),
        ParagraphBlock(
          '_Bayad_ means "payment." _Wala sing..._ means "without / none of..."',
        ),
        QuizBlock(
          id: 'intermediate_7_qc1',
          question: 'What does _Palihog, may lamesa pa bala?_ mean in English?',
          options: [
            'What do you recommend?',
            'I\'d like batchoy and water.',
            'Please, is there a table still available?',
          ],
          answer: 2,
          explain:
              '_Palihog, may lamesa pa bala?_ = Please, is there a table still available?.',
        ),
      ],
    ),
    LessonSection(
      title: 'Scenario B: The market or store',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Tagpila ang kilo?', 'How much per kilo?'],
            ['Pwede bala matawaran?', 'Can I bargain?'],
            ['Duha ka kilo, palihog.', 'Two kilos, please.'],
            ['Ara ang bayad.', 'Here\'s the payment.'],
            ['Ang sukli?', 'The change?'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('Tagpila ang kilo?', 'How much per kilo?'),
          Flashcard('Pwede bala matawaran?', 'Can I bargain?'),
          Flashcard('Duha ka kilo, palihog.', 'Two kilos, please.'),
          Flashcard('Ara ang bayad.', 'Here\'s the payment.'),
          Flashcard('Ang sukli?', 'The change?'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_7_qc2',
          question: 'What does _Pwede bala matawaran?_ mean in English?',
          options: ['The change?', 'Can I bargain?', 'Two kilos, please.'],
          answer: 1,
          explain: '_Pwede bala matawaran?_ = Can I bargain?.',
        ),
      ],
    ),
    LessonSection(
      title: 'Scenario C: The clinic',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Ginasakit ang ulo ko.', 'My head hurts.'],
            [
              'Ginahilanat ako halin pa kahapon.',
              'I\'ve had a fever since yesterday.',
            ],
            ['Nagaubo ako kag may sipon.', 'I\'m coughing and have a cold.'],
            ['Ano ang tambal?', 'What is the medicine?'],
            ['Pila ka beses sa isa ka adlaw?', 'How many times a day?'],
            ['Hinay-hinay lang, palihog.', 'Slowly, please.'],
          ],
        ),
        ParagraphBlock(
          '_Halin pa kahapon_ means "since (as far back as) yesterday." _Beses_ (times, occasions) is a Spanish loanword.',
        ),
        QuizBlock(
          id: 'intermediate_7_qc3',
          question: 'What does _Hinay-hinay lang, palihog._ mean in English?',
          options: [
            'Slowly, please.',
            'What is the medicine?',
            'How many times a day?',
          ],
          answer: 0,
          explain: '_Hinay-hinay lang, palihog._ = Slowly, please..',
        ),
      ],
    ),
    LessonSection(
      title: 'Scenario D: Transport',
      icon: Icons.commute_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            [
              'Diin ang sakayan pakadto sa Jaro?',
              'Where do I catch a ride to Jaro?',
            ],
            ['Pila ang pamasahe?', 'How much is the fare?'],
            ['Para! / Diri lang!', 'Stop! / Here only!'],
            ['Diin ako manaog?', 'Where should I get off?'],
            ['Malayo pa bala?', 'Is it still far?'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_7_qc4',
          question: 'What does _Malayo pa bala?_ mean in English?',
          options: [
            'Stop! / Here only!',
            'Is it still far?',
            'Where do I catch a ride to Jaro?',
          ],
          answer: 1,
          explain: '_Malayo pa bala?_ = Is it still far?.',
        ),
      ],
    ),
    LessonSection(
      title: 'Scenario E: School or work',
      icon: Icons.bolt_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Pasayloa ako, nalate ako.', 'Sorry, I\'m late.'],
            [
              'Ma\'am, mahimo bala ako mangutana?',
              'Ma\'am, may I ask a question?',
            ],
            [
              'Indi ko nahangpan. Mahimo bala liwaton?',
              'I didn\'t understand. Could you repeat it?',
            ],
            ['Ara na ang report ko.', 'My report is ready.'],
            ['Salamat sa bulig ninyo.', 'Thank you for your help.'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_7_qc5',
          question: 'What does _Ara na ang report ko._ mean in English?',
          options: [
            'Ma\'am, may I ask a question?',
            'Sorry, I\'m late.',
            'My report is ready.',
          ],
          answer: 2,
          explain: '_Ara na ang report ko._ = My report is ready..',
        ),
      ],
    ),
    LessonSection(
      title: 'Scenario F: Helping someone or asking for help',
      icon: Icons.help_outline_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Palihog, buligi ako.', 'Please help me.'],
            ['Ano ang mabuligan ko sa imo?', 'How can I help you?'],
            ['Wala ako sing telepono.', 'I don\'t have a phone.'],
            ['Nawala ang bag ko.', 'My bag is lost.'],
            ['Ari lang ako.', 'I\'m right here.'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_7_qc6',
          question: 'What does _Palihog, buligi ako._ mean in English?',
          options: [
            'Please help me.',
            'I\'m right here.',
            'How can I help you?',
          ],
          answer: 0,
          explain: '_Palihog, buligi ako._ = Please help me..',
        ),
      ],
    ),
    LessonSection(
      title: 'Formal versus friendly',
      icon: Icons.waving_hand_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'The same request can be adjusted by adding _ho_, _palihog_, or _kamo_, or by changing the verb:',
        ),
        BulletsBlock([
          'Friend: _Hatagi ako sang tubig._ (Give me water.)',
          'Polite: _Palihog, hatagi ako sang tubig._ (Please give me water.)',
          'Very polite: _Pwede bala mangayo sang tubig, ho?_ (May I ask for some water, please?)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock('Full role-play: at a small restaurant.'),
        DialogueBlock([
          DialogueLine(
            'Server',
            'Maayong aga. Ano ang gusto ninyo?',
            'Good morning. What would you like?',
          ),
          DialogueLine(
            'You',
            'Gusto ko sang batchoy kag isa ka tubig.',
            'I\'d like batchoy and a water.',
          ),
          DialogueLine(
            'Server',
            'Sige. Mainit ba ukon matugnaw ang tubig?',
            'Okay. Hot or cold water?',
          ),
          DialogueLine('You', 'Matugnaw, palihog.', 'Cold, please.'),
          DialogueLine(
            'Server',
            'Sige, hulat lang.',
            'Okay, please wait a moment.',
          ),
          DialogueLine('You', 'Tagpila tanan?', 'How much in total?'),
          DialogueLine(
            'Server',
            'Isa ka gatos kag baynte pesos.',
            'One hundred twenty pesos.',
          ),
          DialogueLine(
            'You',
            'Salamat gid. Namit gid ang batchoy!',
            'Thank you very much. The batchoy is delicious!',
          ),
        ]),
        ParagraphBlock(
          '**Discussion.** Politeness appears at three points: the opening (_Maayong aga_), the request (_palihog_), and the closing (_Salamat gid_). Note _ukon_ ("or") in the server\'s question.',
        ),
        ParagraphBlock(
          '**Practice plan.** Do each scenario three times: read it, act it from memory, then change one detail (item, price, or place). List the words you missed.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Iloilo\'s La Paz Public Market is famous for its batchoy. Many locals say that batchoy tastes best at the market stalls where it is made.',
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
          '_Pakiusap_ = _palihog_; _sukli_ = _sukli_; _bayad po_ = _bayad ho_.',
          'Filipino _Magkano ang kilo?_ = Hiligaynon _Tagpila ang kilo?_.',
          '_Puwede po ba...?_ = _Pwede bala...?_.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using Filipino phrases in high-pressure situations.',
          'Not confirming numbers and prices.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you perform the six scenarios without reading?',
          'Can you make each request more polite?',
          'Can you ask for repetition and slower speech?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson8 = Lesson(
  id: 'intermediate_8',
  number: 8,
  title: 'Reading & Storytelling',
  subtitle: 'Read short narratives and identify people, place, time, events,…',
  emoji: '📖',
  level: 'Intermediate',
  objectives: [
    'Read short narratives and identify people, place, time, events, and reasons.',
    'Retell a story in your own words.',
    'Use linking words to organize a story.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Reading means building meaning from words you know, grammar, and story structure, not translating every word. Ask in order: who, where, when, what happened, why.',
        ),
      ],
    ),
    LessonSection(
      title: 'Story linkers',
      icon: Icons.menu_book_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['sang ulihi / sa ulihi', 'sa huli', 'finally'],
            ['gani', 'kaya', 'therefore'],
            ['samtang', 'habang', 'while'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_8_qc1',
          question: 'What does _sang ulihi / sa ulihi_ mean in English?',
          options: ['therefore', 'finally', 'while'],
          answer: 1,
          explain: '_sang ulihi / sa ulihi_ = finally.',
        ),
      ],
    ),
    LessonSection(
      title: 'Story structure',
      icon: Icons.menu_book_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. **Setting**: who, where, when.',
          '2. **Problem or event**: what happened.',
          '3. **Response**: what did they do?',
          '4. **Result**: how did it end?',
          '5. **Reflection**: how did they feel or what did they learn?',
        ]),
      ],
    ),
    LessonSection(
      title: 'Model story: "Sa Merkado" ("At the Market")',
      icon: Icons.menu_book_rounded,
      minutes: 1,
      blocks: [
        CalloutBlock(
          title: 'Read it aloud',
          emoji: '📖',
          color: purple,
          text:
              'Sang Sabado, nagkadto kami ni Nanay sa merkado. Madamo ang tawo kag mainit ang adlaw. Una, nagpalit kami sing isda kag utan. Dayon, nagpalit man kami sang mangga. Pagkatapos, nag-uli kami sa balay. Nagluto si Nanay sang paniudto. Nalipay ako kay namit gid ang pagkaon.',
        ),
        ParagraphBlock(
          '**Reading translation:** "On Saturday, Mother and I went to the market. There were many people and the sun was hot. First, we bought fish and vegetables. Then we also bought mangoes. After that, we went home. Mother cooked lunch. I was happy because the food was really delicious."',
        ),
        SubheadingBlock('Comprehension questions (answer in Hiligaynon)'),
        BulletsBlock([
          '1. Sin-o ang nagkadto sa merkado? (_Kami ni Nanay._)',
          '2. San-o sila nagkadto? (_Sang Sabado._)',
          '3. Ano ang ginpalit nila? (_Isda, utan, kag mangga._)',
          '4. Ngaa nalipay ang nagasugid? (_Kay namit ang pagkaon._)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Reading strategy',
      icon: Icons.menu_book_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. Read once quickly for the general idea.',
          '2. Underline known words and linkers (_una_, _dayon_, _kay_).',
          '3. Guess unknown words from context.',
          '4. Read again and answer _sin-o, diin, san-o, ano, ngaa_.',
          '5. Retell aloud without looking.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Retelling',
      icon: Icons.bolt_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Do not memorize. Use a skeleton: _Sang ＿＿＿ , nagkadto ＿＿＿ sa ＿＿＿ . Una, ＿＿＿ . Dayon, ＿＿＿ . Sa ulihi, ＿＿＿ . Nalipay/Nasubo ako kay ＿＿＿ ._',
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
              'Sang Sabado, nagkadto kami sa baybay.',
              'Noong Sabado, pumunta kami sa dagat.',
              'On Saturday, we went to the beach.',
            ],
            ['Una, nagligo kami.', 'Una, naligo kami.', 'First, we swam.'],
            [
              'Dayon, nagkaon kami sang inasal.',
              'Tapos, kumain kami ng inasal.',
              'Then, we ate grilled chicken.',
            ],
            [
              'Nag-ulan sang hapon, gani nag-uli kami.',
              'Umulan noong hapon, kaya umuwi kami.',
              'It rained in the afternoon, so we went home.',
            ],
            [
              'Nalipay ako bisan nabasa ako.',
              'Natuwa ako kahit nabasa ako.',
              'I was happy even though I got wet.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** _Dayon_ marks sequence, _gani_ result, and _bisan_ contrast. When retelling, also use _una_ (first) and _kay_ (reason).',
        ),
        ParagraphBlock('A second short text for practice:'),
        CalloutBlock(
          title: 'Read it aloud',
          emoji: '📖',
          color: purple,
          text:
              'Si Ana estudyante sa Iloilo. Kada aga, nagabasa siya sa dyip. Sang isa ka adlaw, nalimtan niya ang iya bag. Nahadlok siya, pero ginbalik sang drayber. Nagpasalamat gid si Ana.',
        ),
        ParagraphBlock(
          '("Ana is a student in Iloilo. Every morning she reads in the jeepney. One day she forgot her bag. She was scared, but the driver returned it. Ana thanked him very much.") _Nalimtan_ means "was forgotten"; _ginbalik_ means "returned."',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Hiligaynon has a rich literary tradition, including poetry (balak), short stories, plays, and songs. Visayan folk songs such as Dandansoy are widely loved and are a fun way to hear the rhythm of the language.',
        ),
        QuizBlock(
          id: 'intermediate_8_qc6',
          question:
              'What does _Sang Sabado, nagkadto kami sa baybay._ mean in English?',
          options: [
            'It rained in the afternoon, so we went home.',
            'First, we swam.',
            'On Saturday, we went to the beach.',
          ],
          answer: 2,
          explain:
              '_Sang Sabado, nagkadto kami sa baybay._ = On Saturday, we went to the beach..',
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
          'Sequence words (_una, dayon, pagkatapos_) are close to Filipino.',
          '_Kay_ = _dahil/kasi_; _gani_ = _kaya_; _samtang_ = _habang_; _bisan_ = _kahit_.',
          'Sentence structure differs; retell the _meaning_, not the Filipino order.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Translating each word instead of understanding the sentence.',
          'Forgetting the aspect prefix (_nagkadto_ for past).',
          'Using only _at_ (_kag_) to link all sentences.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you read the model story and answer the questions?',
          'Can you retell it using _una, dayon, kay,_ and _gani_?',
          'Can you write a five-sentence story about your weekend?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson9 = Lesson(
  id: 'intermediate_9',
  number: 9,
  title: 'Listening Comprehension',
  subtitle: 'Understand short conversations at increasing speed.',
  emoji: '🎧',
  level: 'Intermediate',
  objectives: [
    'Understand short conversations at increasing speed.',
    'Identify main idea, key details, and speaker attitude.',
    'Use context to guess unknown words.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Speech is fast and blended, with particles that seem invisible at first. Good listening is trained, and this lesson gives you a method and common patterns to expect.',
        ),
      ],
    ),
    LessonSection(
      title: 'The three-listen method',
      icon: Icons.hearing_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. **Listen 1: Gist.** Do not pause. What is the topic? Who is speaking?',
          '2. **Listen 2: Details.** Catch names, numbers, places, times, and actions.',
          '3. **Listen 3: Language.** Notice particles, verb prefixes, and tone.',
        ]),
        ParagraphBlock(
          'Only after three listens should you read the transcript.',
        ),
      ],
    ),
    LessonSection(
      title: 'Things that make speech sound different',
      icon: Icons.hearing_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Feature', 'What happens', 'Example'],
          italicColumn: -1,
          rows: [
            [
              'Blending',
              'Words run together',
              'Diin ka makadto? sounds like "diinka makadto"',
            ],
            [
              'Short pronouns',
              'ka, ko, mo, na, pa are quick',
              'Nagkaon na ako.',
            ],
            ['Particles', 'Small words carry mood', 'Sige lang. / Ambot lang.'],
            [
              'Loanwords',
              'Spanish and English words appear',
              'Alas-tres na. / okay lang.',
            ],
            [
              'Code-switching',
              'Speakers mix Hiligaynon, Filipino, and English',
              'Ma-late na ako.',
            ],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Numbers and times in fast speech',
      icon: Icons.pin_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Practice recognizing numbers 1 to 100 and clock times in both native and Spanish-derived systems. Prices and times are the most useful details to catch quickly.',
        ),
      ],
    ),
    LessonSection(
      title: 'Speaker intention',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Ask: Is the speaker asking, telling, inviting, complaining, or joking? Tone, particles (_bala_, _gid_, _lang_), and endings help you decide.',
        ),
      ],
    ),
    LessonSection(
      title: 'Dictation practice',
      icon: Icons.bolt_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Listen to a short phrase, write it, then compare with the transcript. Note every error and classify it: **sound** (did not hear), **spelling** (heard but wrote wrong), or **word** (did not know).',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 2,
      blocks: [
        SubheadingBlock('Sample listening text 1 (a phone call)'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Hello, Ana? Nagkadto ka na bala sa eskwelahan?',
            'Hello, Ana? Have you gone to school yet?',
          ),
          DialogueLine(
            'Friend',
            'Wala pa. Alas-sais pa lang.',
            'Not yet. It\'s only six o\'clock.',
          ),
          DialogueLine('You', 'Ayaw pag-late, ha?', 'Don\'t be late, okay?'),
          DialogueLine(
            'Friend',
            'Sige. Mag-abot ako antes alas-siete.',
            'Okay. I\'ll arrive before seven.',
          ),
        ]),
        ParagraphBlock(
          '**Tasks:** (1) What is the topic? (2) What time is it? (3) What does A ask B not to do? (4) Where is B going?',
        ),
        SubheadingBlock('Sample listening text 2 (asking about the weather)'),
        DialogueBlock([
          DialogueLine(
            'You',
            'Mainit gid subong, no?',
            'It\'s really hot today, isn\'t it?',
          ),
          DialogueLine(
            'Friend',
            'Amo. Basi mag-ulan sa hapon.',
            'Yes. It may rain this afternoon.',
          ),
          DialogueLine('You', 'Dala ka sang payong.', 'Bring an umbrella.'),
          DialogueLine('Friend', 'Salamat.', 'Thanks.'),
        ]),
        ParagraphBlock(
          'The tag **no?** is an informal "isn\'t it?", borrowed from Spanish and widely used.',
        ),
        ParagraphBlock(
          '**Discussion.** In both texts the key details (time, weather, warning) are short. Focus on numbers, question words, and verbs; use context for the rest.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Hiligaynon speakers often use short tags such as no? and ha? at the end of a sentence to check agreement. They are pragmatic markers, not questions in the strict sense.',
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
          'Because many words are shared, Filipino helps you catch the general idea.',
          'Watch for **false friends** (_kita_, _wala_, _kanan/kan-on_).',
          'Do not assume unfamiliar-sounding speech is "wrong"; it may be a regional variant.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Trying to understand every word.',
          'Reading the transcript too early.',
          'Ignoring particles and intonation.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you summarize a short conversation after one listen?',
          'Can you write down three details after two listens?',
          'Can you identify the tone (asking, inviting, complaining)?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson10 = Lesson(
  id: 'intermediate_10',
  number: 10,
  title: 'Two-Way Translation',
  subtitle: 'Translate sentences and short paragraphs from Filipino to…',
  emoji: '🔁',
  level: 'Intermediate',
  objectives: [
    'Translate sentences and short paragraphs from Filipino to Hiligaynon and back.',
    'Preserve meaning, time, tone, and relationships between ideas.',
    'Recognize where the two languages differ in structure.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'A translator is a bridge, not a dictionary. Understand the meaning first, then rebuild it in the target language instead of translating word by word.',
        ),
      ],
    ),
    LessonSection(
      title: 'The four-step method',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. **Understand.** Who did what, to whom, when, and why?',
          '2. **Choose the pattern.** Which sentence structure will Hiligaynon use?',
          '3. **Choose the words.** Use Hiligaynon vocabulary, not Filipino.',
          '4. **Check.** Meaning, time, tone, and naturalness.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Systematic differences',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Area', 'Filipino', 'Hiligaynon'],
          italicColumn: 2,
          rows: [
            ['"Now"', 'ngayon', 'subong'],
            ['"Tomorrow"', 'bukas', 'buas'],
            ['"Not"', 'hindi', 'indi'],
            ['"We (incl.)"', 'tayo', 'kita'],
            ['"You (pl.)"', 'kayo', 'kamo'],
            ['Object marker', 'ng', 'sang'],
            ['Linker', 'na / -ng', 'nga'],
            ['"Because"', 'dahil / kasi', 'kay'],
            ['"Really"', 'talaga', 'gid'],
            ['"Also"', 'rin / din / naman', 'man'],
            ['"Eat"', 'kain', 'kaon'],
            ['"Go"', 'punta', 'kadto'],
            ['"Where"', 'saan / nasaan', 'diin'],
            ['"When"', 'kailan', 'san-o'],
            ['"Why"', 'bakit', 'ngaa'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_10_qc2',
          question: 'What does _kamo_ mean in Filipino?',
          options: ['tayo', 'kayo', 'kailan'],
          answer: 1,
          explain: '_kamo_ = kayo.',
        ),
      ],
    ),
    LessonSection(
      title: 'Structural differences',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**Verb forms:** _kumain_ → _nagkaon_; _kakain_ → _magkaon_; _kinain_ → _ginkaon_.',
          '**Ligature with numbers:** _dalawang bata_ → _duha ka bata_.',
          '**Negation of the past:** _hindi ako kumain_ → _wala ako nagkaon_.',
          '**Possession:** _ang bahay ko_ → _ang balay ko_ / _akon nga balay_.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Traps: false friends and near-matches',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Word', 'Filipino meaning', 'Hiligaynon meaning'],
          italicColumn: 2,
          rows: [
            ['kita', 'I (to) you', 'we (inclusive)'],
            ['kan-on', '(none)', 'cooked rice (Filipino kanan = right side)'],
            ['wala', 'none', 'none; also "left (side)"; also "did not"'],
            ['tuod', 'tree stump', 'true'],
            ['mahal', 'expensive / beloved', 'expensive (beloved is palangga)'],
          ],
        ),
        QuizBlock(
          id: 'intermediate_10_qc4',
          question:
              'What does _none; also "left (side)"; also "did not"_ mean in Filipino?',
          options: ['none', '(none)', 'I (to) you'],
          answer: 0,
          explain: '_none; also "left (side)"; also "did not"_ = none.',
        ),
      ],
    ),
    LessonSection(
      title: 'Translating tone and politeness',
      icon: Icons.waving_hand_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Add _ho_, _palihog_, or _kamo_ to keep politeness; use _man_ and _lang_ to keep softness; use _gid_ to keep intensity.',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 2,
      blocks: [
        TableBlock(
          headers: ['Filipino', 'Hiligaynon', 'Notes'],
          italicColumn: 1,
          rows: [
            [
              'Kumain ka na ba?',
              'Nagkaon ka na bala?',
              'kumain → nagkaon; ba → bala',
            ],
            [
              'Pupunta ako sa palengke bukas.',
              'Magkadto ako sa merkado buas.',
              'palengke → merkado; bukas → buas',
            ],
            [
              'Hindi ko alam kung nasaan siya.',
              'Wala ako kabalo kon diin siya.',
              'hindi ko alam → wala ako kabalo; kung → kon',
            ],
            [
              'Ang laki ng bahay nila.',
              'Daku gid ang balay nila.',
              'laki → daku; added gid for emphasis',
            ],
            [
              'Mahal kita.',
              'Palangga ta ka.',
              'different construction, not word-for-word',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** In row 3, _alam_ and _kabalo_ both mean "know," but negation changes: _wala ako kabalo_. In row 4, "how big" becomes "very big." In row 6, _Mahal ko ikaw_ would be wrong; use _ta ka_.',
        ),
        ParagraphBlock('Translate this paragraph:'),
        ParagraphBlock(
          'Filipino: "Kahapon, pumunta kami ni Nanay sa palengke. Bumili kami ng isda. Umuwi kami bago mag-ulan."',
        ),
        ParagraphBlock(
          'Hiligaynon: "Kahapon, nagkadto kami ni Nanay sa merkado. Nagpalit kami sing isda. Nag-uli kami antes mag-ulan."',
        ),
        ParagraphBlock(
          'Note: _antes_ ("before") is a widely used Spanish loanword in Hiligaynon.',
        ),
        ParagraphBlock(
          '**Backwards check.** Translate your Hiligaynon back to Filipino and compare; differences show where meaning was lost.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Translation between related languages is often harder than between distant ones, because false friends appear where you least expect them.',
        ),
        QuizBlock(
          id: 'intermediate_10_qc6',
          question: 'What does _Palangga ta ka._ mean in Filipino?',
          options: [
            'Mahal kita.',
            'Ang laki ng bahay nila.',
            'Pupunta ako sa palengke bukas.',
          ],
          answer: 0,
          explain: '_Palangga ta ka._ = Mahal kita..',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'This entire lesson is the bridge. The key idea is: **translate the meaning, not the words.**',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Word-for-word translation.',
          'Using Filipino vocabulary that has a Hiligaynon equivalent.',
          'Losing politeness or emphasis.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you translate five Filipino sentences into natural Hiligaynon?',
          'Can you translate five Hiligaynon sentences into natural Filipino?',
          'Can you list ten systematic differences from memory?',
        ]),
      ],
    ),
  ],
);

const Lesson intermediateLesson11 = Lesson(
  id: 'intermediate_11',
  number: 11,
  title: 'Guided Conversation',
  subtitle: 'Hold a conversation of six to eight turns.',
  emoji: '🗣️',
  level: 'Intermediate',
  objectives: [
    'Hold a conversation of six to eight turns.',
    'Ask follow-up questions, react, clarify, and close.',
    'Keep going when you do not know a word.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'A conversation is a team activity: listen, react, add something, and hand the turn back. This lesson gives you reaction words and follow-up questions.',
        ),
      ],
    ),
    LessonSection(
      title: 'The conversation arc',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock(
          'Greet → ask about the day → respond with a detail → ask a follow-up → share an opinion → close.',
        ),
      ],
    ),
    LessonSection(
      title: 'Reaction words',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English'],
          italicColumn: 0,
          rows: [
            ['Amo?', 'Is that so?'],
            ['Abaw!', 'Wow! / Oh my!'],
            ['Ay, sayang.', 'Oh, what a pity.'],
            ['Tuod gid.', 'Really true.'],
            ['Sige.', 'Okay.'],
            ['Ambot.', 'I\'m not sure.'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('Amo?', 'Is that so?'),
          Flashcard('Abaw!', 'Wow! / Oh my!'),
          Flashcard('Ay, sayang.', 'Oh, what a pity.'),
          Flashcard('Tuod gid.', 'Really true.'),
          Flashcard('Sige.', 'Okay.'),
          Flashcard('Ambot.', 'I\'m not sure.'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'intermediate_11_qc2',
          question: 'What does _Sige._ mean in English?',
          options: ['Okay.', 'I\'m not sure.', 'Oh, what a pity.'],
          answer: 0,
          explain: '_Sige._ = Okay..',
        ),
      ],
    ),
    LessonSection(
      title: 'Follow-up questions',
      icon: Icons.help_outline_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '_Ngaa?_ (Why?)',
          '_San-o?_ (When?)',
          '_Kag dayon?_ (And then?)',
          '_Ano pa?_ (What else?)',
          '_Kamusta ang trabaho / eskwelahan?_ (How\'s work / school?)',
          '_Sin-o ang kaupod mo?_ (Who\'s with you?)',
        ]),
      ],
    ),
    LessonSection(
      title: 'Strategies when you are stuck',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Situation', 'Strategy', 'Hiligaynon'],
          italicColumn: 2,
          rows: [
            [
              'Forgot a word',
              'Describe it',
              'Ang butang nga... (The thing that...)',
            ],
            ['Don\'t understand', 'Ask', 'Palihog liwata.'],
            ['Too fast', 'Ask to slow', 'Hinay-hinay lang.'],
            [
              'Need time',
              'Ask for a moment',
              'Hulat lang... (Wait a moment...)',
            ],
            ['Not sure', 'Say so', 'Basi, pero indi ako sigurado.'],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Closing',
      icon: Icons.bolt_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Salamat sa istorya. Ingat ka. Hasta buas!_ (Thanks for the chat. Take care. Until tomorrow!)',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 2,
      blocks: [
        ParagraphBlock('A full eight-turn conversation:'),
        TableBlock(
          headers: ['Turn', 'Hiligaynon', 'English'],
          italicColumn: 1,
          rows: [
            [
              '1 A',
              'Maayong hapon! Kamusta ang adlaw mo?',
              'Good afternoon! How\'s your day?',
            ],
            [
              '2 B',
              'Maayo man. Nagtrabaho ako sang aga. Ikaw man?',
              'Fine. I worked in the morning. And you?',
            ],
            [
              '3 A',
              'Kapoy man, pero okay lang. Diin ka nagatrabaho?',
              'Tired, but okay. Where do you work?',
            ],
            ['4 B', 'Sa bangko sa Iloilo. Ikaw?', 'At a bank in Iloilo. You?'],
            [
              '5 A',
              'Estudyante ako sa Bacolod. Gusto ko ang eskwelahan.',
              'I\'m a student in Bacolod. I like school.',
            ],
            ['6 B', 'Amo? Ngaa gusto mo?', 'Is that so? Why do you like it?'],
            [
              '7 A',
              'Kay mabuot ang mga manunudlo.',
              'Because the teachers are kind.',
            ],
            [
              '8 B',
              'Abaw, maayo ina. Salamat sa istorya. Ingat ka!',
              'Wow, that\'s good. Thanks for the chat. Take care!',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Each turn answers the previous one and adds a detail or question. Turn 6 pairs a reaction (_Amo?_) with a follow-up (_Ngaa?_), and turn 8 closes politely.',
        ),
        ParagraphBlock(
          '**Self-recording exercise.** Record a two-minute conversation with a partner. Listen for pauses over three seconds, turns where you only answered, and missed follow-up questions.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'In Ilonggo conversation, asking about family, food, and health is a natural way to show care. A conversation that starts with Nagkaon ka na bala? often signals warmth, not curiosity.',
        ),
        QuizBlock(
          id: 'intermediate_11_qc6',
          question: 'What does _Sa bangko sa Iloilo. Ikaw?_ mean in English?',
          options: [
            'At a bank in Iloilo. You?',
            'Fine. I worked in the morning. And you?',
            'Good afternoon! How\'s your day?',
          ],
          answer: 0,
          explain: '_Sa bangko sa Iloilo. Ikaw?_ = At a bank in Iloilo. You?.',
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
          'Plan in short chunks rather than long Filipino sentences.',
          'Reaction words (_Abaw!_, _Amo?_) are typical of Hiligaynon and will make you sound natural.',
          'Paraphrase when a word is missing rather than switching to Filipino.',
        ]),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'One-word answers with no follow-up.',
          'Switching to Filipino when stuck.',
          'Not closing the conversation.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you hold a six-turn conversation on a familiar topic?',
          'Can you ask three different follow-up questions?',
          'Can you recover when you forget a word?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson1 = Lesson(
  id: 'advanced_1',
  number: 1,
  title: 'Advanced Grammar & Focus',
  subtitle: 'Explain how the four main focus types work.',
  emoji: '🎯',
  level: 'Advanced',
  objectives: [
    'Explain how the four main focus types work.',
    'Use connectors (kon, kay, bisan, samtang, pero) to build complex sentences.',
    'Choose the focus that fits what you want to emphasize.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Hiligaynon verbs also tell the listener which participant is in the spotlight, the _ang_ phrase. This is the **focus (voice) system**, and mastering it separates fluent from intermediate speakers.',
        ),
      ],
    ),
    LessonSection(
      title: 'Four focus types with one verb',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock('Using the root _sulat_ ("write") and the same event:'),
        TableBlock(
          headers: ['Focus', 'Spotlight on', 'Example', 'Meaning'],
          italicColumn: -1,
          rows: [
            [
              'Actor',
              'the doer',
              'Nagsulat ako sang sulat.',
              'I wrote a letter.',
            ],
            [
              'Object',
              'the thing written',
              'Ginsulat ko ang sulat.',
              'I wrote the letter.',
            ],
            [
              'Locative / goal',
              'the place or recipient',
              'Ginsulatan ko ang papel.',
              'I wrote on the paper.',
            ],
            [
              'Beneficiary',
              'who it is done for',
              'Ginsulatan ko si Nanay sang sulat.',
              'I wrote a letter for/to Mother.',
            ],
          ],
        ),
        ParagraphBlock(
          'Rule of thumb: whatever follows _ang_ or _si_ is the spotlighted participant, and the verb prefix or suffix is chosen to match it (_nag-_ for actor; _gin-_ or _-on_ for object; _-an_ for place or recipient).',
        ),
      ],
    ),
    LessonSection(
      title: 'The pronoun rule',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Actor-focus uses the _ako, ka, siya_ set. Every other focus uses the _ko, mo, niya_ set for the doer: _Nagbasa ako sang libro_ but _Ginbasa ko ang libro_. If you say _Ginbasa ako ang libro_, the sentence is ungrammatical.',
        ),
      ],
    ),
    LessonSection(
      title: 'Choosing the focus',
      icon: Icons.directions_run_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          'Talking about **a specific, known thing**? Use object focus: _Ginkaon ko ang mangga._',
          'Talking about **a general activity**? Use actor focus: _Nagkaon ako sang mangga._',
          'Talking about **where or to whom**? Use the _-an_ form: _Ginhatagan ko si Maria sang libro._',
        ]),
      ],
    ),
    LessonSection(
      title: 'Connectors that build complex sentences',
      icon: Icons.extension_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Connector', 'Meaning', 'Example'],
          italicColumn: -1,
          rows: [
            ['kay', 'because', 'Nalate ako kay nagaulan.'],
            ['kon', 'if / when', 'Kon mag-ulan, indi kami magkadto.'],
            ['bisan', 'although / even if', 'Bisan kapoy ako, nagtrabaho ako.'],
            ['samtang', 'while', 'Samtang nagaluto si Nanay, nagabasa ako.'],
            [
              'pero / apang',
              'but / however',
              'Gusto ko, pero wala ako sing kwarta.',
            ],
            ['amo nga', 'that is why', 'Nagaulan, amo nga nalate ako.'],
            ['antes', 'before', 'Nagligo ako antes magkaon.'],
          ],
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
              'Nagluto si Nanay sang adobo.',
              'Nagluto si Nanay ng adobo.',
              'Mother cooked adobo.',
            ],
            [
              'Ginluto ni Nanay ang adobo.',
              'Niluto ni Nanay ang adobo.',
              'Mother cooked the adobo.',
            ],
            [
              'Ginhatagan ko si Maria sang libro.',
              'Binigyan ko si Maria ng libro.',
              'I gave Maria a book.',
            ],
            [
              'Kon mag-ulan buas, indi kami magkadto sa baybay.',
              'Kung uulan bukas, hindi kami pupunta sa dagat.',
              'If it rains tomorrow, we won\'t go to the beach.',
            ],
            [
              'Bisan kapoy ako, nagtrabaho pa ako.',
              'Kahit pagod ako, nagtrabaho pa rin ako.',
              'Even though I was tired, I still worked.',
            ],
            [
              'Samtang nagaluto si Nanay, nagabasa ako.',
              'Habang nagluluto si Nanay, nagbabasa ako.',
              'While Mother cooks, I read.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Rows 1 and 2 are a minimal pair: same event, different spotlight. Row 3 shows the recipient form _-an_ with _si Maria_ as the spotlight. In rows 4 to 6, the clause after _kon_, _bisan_, or _samtang_ has its own verb and pronoun. Practice by rewriting any sentence in a different focus.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Philippine-type languages are studied worldwide because their focus systems are unusual. Linguists still debate how best to describe them, so do not worry if a rule feels slippery; exposure to many real examples is the best teacher.',
        ),
        QuizBlock(
          id: 'advanced_1_qc5',
          question:
              'What does _Ginhatagan ko si Maria sang libro._ mean in English?',
          options: [
            'While Mother cooks, I read.',
            'I gave Maria a book.',
            'If it rains tomorrow, we won\'t go to the beach.',
          ],
          answer: 1,
          explain:
              '_Ginhatagan ko si Maria sang libro._ = I gave Maria a book..',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Filipino has the same four-way logic (_-um-/mag-_, _-in_, _i-_, _-an_). Hiligaynon uses _nag-/mag-_, _gin-/-on_, _i-_, _-an_. The concept transfers; the affixes do not.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _ako/ka/siya_ in non-actor focus.',
          'Mixing Filipino affixes (_-in-_, _-um-_).',
          'Using _kon_ for "because."',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you rewrite one sentence in actor, object, and locative focus?',
          'Can you explain what the _ang_ phrase does?',
          'Can you join two ideas using _kay, kon, bisan,_ and _samtang_?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson2 = Lesson(
  id: 'advanced_2',
  number: 2,
  title: 'Natural Hiligaynon & Regional Variation',
  subtitle: 'Tell the difference between "correct" and "natural."',
  emoji: '🗺️',
  level: 'Advanced',
  objectives: [
    'Tell the difference between "correct" and "natural."',
    'Recognize regional variants and neighboring languages.',
    'Handle variation respectfully.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'A correct sentence is not always what a native speaker would say. Natural speech depends on habit, context, and local preference, and Hiligaynon varies by place.',
        ),
      ],
    ),
    LessonSection(
      title: 'Literal versus natural',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Literal (from Filipino)', 'Natural Hiligaynon', 'Why'],
          italicColumn: 1,
          rows: [
            [
              'Mahal ko ikaw.',
              'Palangga ta ka.',
              'Different construction for "I love you."',
            ],
            [
              'Nasaan ka pupunta?',
              'Diin ka makadto?',
              'Diin ka makadto is the set phrase.',
            ],
            [
              'Kumain ka na ba?',
              'Nagkaon ka na bala?',
              'Verb, particle, and question marker all change.',
            ],
            [
              'Hindi ko alam.',
              'Ambot. / Wala ko kabalo.',
              'Ambot is the everyday reply.',
            ],
            ['Salamat po.', 'Salamat ho.', 'Respect particle differs.'],
          ],
        ),
        QuizBlock(
          id: 'advanced_2_qc1',
          question: 'What does _Diin ka makadto?_ mean in Filipino?',
          options: ['Salamat po.', 'Nasaan ka pupunta?', 'Kumain ka na ba?'],
          answer: 1,
          explain: '_Diin ka makadto?_ = Nasaan ka pupunta?.',
        ),
      ],
    ),
    LessonSection(
      title: 'Regional landscape',
      icon: Icons.map_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**Iloilo and Guimaras**: often taken as the reference variety for teaching (this module\'s baseline).',
          '**Negros Occidental (Bacolod)**: a large Hiligaynon-speaking region with its own rhythm and vocabulary, influenced by contact with Cebuano and Spanish-era sugar-estate life.',
          '**Capiz**: Capiznon is closely related and mutually understandable to a large degree.',
          '**Antique and parts of Iloilo\'s hills**: **Kinaray-a** is spoken; it is a different language, not a dialect of Hiligaynon.',
          '**Mindanao settlements (South Cotabato, Sultan Kudarat)**: Hiligaynon travelled with settlers and mixes with Cebuano and Filipino.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Comparing neighbors',
      icon: Icons.compare_arrows_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['English', 'Hiligaynon', 'Cebuano', 'Kinaray-a'],
          italicColumn: 1,
          rows: [
            ['Good morning', 'Maayong aga', 'Maayong buntag', 'Mayad nga aga'],
            ['What', 'ano', 'unsa', 'ano'],
            ['Where', 'diin', 'asa', 'diin'],
            ['Why', 'ngaa', 'ngano', 'ngaa'],
            ['Three', 'tatlo', 'tulo', 'tatlo'],
            ['None / no', 'wala', 'wala', 'owa'],
          ],
        ),
        FlashcardsBlock([
          Flashcard('Maayong aga', 'Good morning'),
          Flashcard('ano', 'What'),
          Flashcard('diin', 'Where'),
          Flashcard('ngaa', 'Why'),
          Flashcard('tatlo', 'Three'),
          Flashcard('wala', 'None / no'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'advanced_2_qc3',
          question: 'What does _diin_ mean in English?',
          options: ['Where', 'Three', 'What'],
          answer: 0,
          explain: '_diin_ = Where.',
        ),
      ],
    ),
    LessonSection(
      title: 'Attitude toward variation',
      icon: Icons.map_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          'A different form is **not a mistake**; it is a variant.',
          'Record _where_ you heard it, _who_ said it, and _how formal_ it was.',
          'Use the form your listener uses.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: [
            'Situation',
            'What a learner might say',
            'What a local might say',
          ],
          italicColumn: -1,
          rows: [
            [
              'Asking where someone is going',
              'Saan ka pupunta?',
              'Diin ka makadto?',
            ],
            ['Answering "I don\'t know"', 'Hindi ko alam.', 'Ambot.'],
            [
              'Checking if someone has eaten',
              'Kumain ka na ba?',
              'Nagkaon ka na bala?',
            ],
            ['Telling someone you love them', 'Mahal kita.', 'Palangga ta ka.'],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Each "local" version is the phrase the community actually uses, not just a translation. Keep a variation notebook with form, place or speaker, and formal or casual.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Hiligaynon has around 7 to 9 million native speakers and ranks among the Philippines\' major languages. Because Ilonggos migrated widely, it is also a familiar language in parts of Mindanao.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Filipino speakers can guess many meanings, but natural speech needs local phrases. Rely on set phrases (_Diin ka makadto?_, _Palangga ta ka_) rather than building from Filipino.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Treating regional differences as errors.',
          'Assuming Kinaray-a is "the same as" Hiligaynon.',
          'Translating set phrases word for word.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you give three literal-versus-natural pairs?',
          'Can you name the regions where Hiligaynon and its neighbors are spoken?',
          'Can you compare Hiligaynon, Cebuano, and Kinaray-a for three words?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson3 = Lesson(
  id: 'advanced_3',
  number: 3,
  title: 'Idioms & Expressions',
  subtitle: 'Interpret common expressions beyond their literal words.',
  emoji: '🌺',
  level: 'Advanced',
  objectives: [
    'Interpret common expressions beyond their literal words.',
    'Choose the right expression for the mood and relationship.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Idioms carry emotion and attitude, and their meaning depends on tone and relationship. This lesson gives the meaning, feeling, and a warning where needed.',
        ),
      ],
    ),
    LessonSection(
      title: 'How to learn an idiom',
      icon: Icons.format_quote_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: [
            'Expression',
            'Literal / basic sense',
            'Actual use',
            'Tone',
          ],
          italicColumn: -1,
          rows: [
            [
              'Ambot',
              'I don\'t know',
              '"I don\'t know," "no idea," or a shrug meaning "whatever"',
              'neutral to dismissive',
            ],
            [
              'Abaw!',
              '(exclamation)',
              'surprise, admiration, or mild complaint',
              'casual',
            ],
            [
              'Ginoo ko!',
              'My Lord!',
              'shock, exasperation, or worry',
              'strong, familiar',
            ],
            ['Tuod gid.', 'Really true.', '"Exactly!" or "I agree."', 'warm'],
            [
              'Sige lang.',
              'Just go ahead.',
              '"It\'s okay," "don\'t worry," "go on."',
              'gentle',
            ],
            [
              'Palangga.',
              'dear / beloved',
              'term of affection for family, friends, partners',
              'tender',
            ],
            [
              'Kabay pa.',
              '(set phrase)',
              '"I hope so," "may it be so"',
              'hopeful',
            ],
            [
              'Ayaw kahadlok.',
              'Don\'t fear.',
              '"Don\'t be afraid," reassurance',
              'comforting',
            ],
            [
              'Bahala ka.',
              'It\'s up to you.',
              '"It\'s your call" (can sound annoyed)',
              'depends on tone',
            ],
            [
              'Ay, kabudlay!',
              'Oh, the hardship!',
              '"What a hassle!"',
              'complaining',
            ],
          ],
        ),
        ParagraphBlock(
          'Record five things: **form, literal meaning, actual meaning, tone, and one example**. Then note who you could safely say it to.',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Discussion'],
          italicColumn: 0,
          rows: [
            [
              'Ambot, indi ko kabalo.',
              'Not sure, I really don\'t know.',
              'Softer than a bare Ambot.',
            ],
            [
              'Abaw, ang init gid subong!',
              'Wow, it\'s really hot today!',
              'Casual comment.',
            ],
            [
              'Ginoo ko, nalimtan ko ang bag!',
              'My goodness, I forgot my bag!',
              'Worry; fine with friends and family.',
            ],
            ['Tuod gid ina.', 'That\'s so true.', 'Agreement, warm.'],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** The same word shifts with tone: gentle _Ambot_ is "I\'m not sure," while sharp _Ambot_ can sound rude. In formal settings, use _Indi ako sigurado_ ("I\'m not certain").',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Palangga is a cornerstone word in Hiligaynon affection. It appears in songs, family talk, and love phrases, and is more tender than the neutral gusto ("like").',
        ),
        QuizBlock(
          id: 'advanced_3_qc2',
          question: 'What does _Ambot, indi ko kabalo._ mean in English?',
          options: [
            'That\'s so true.',
            'Not sure, I really don\'t know.',
            'Wow, it\'s really hot today!',
          ],
          answer: 1,
          explain:
              '_Ambot, indi ko kabalo._ = Not sure, I really don\'t know..',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          '_Ewan_ ~ _Ambot_; _Diyos ko_ ~ _Ginoo ko_; _Sana_ ~ _Kabay pa / kunta_; _Huwag kang matakot_ ~ _Ayaw kahadlok_.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using _Ginoo ko_ in formal speeches.',
          'Translating idioms word for word.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you explain the tone of five expressions?',
          'Can you replace _Ambot_ with a polite alternative?',
          'Can you make a card for one new expression using the five-part method?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson4 = Lesson(
  id: 'advanced_4',
  number: 4,
  title: 'Formal vs Informal Register',
  subtitle: 'Adjust language for elders, peers, officials, and audiences.',
  emoji: '🎩',
  level: 'Advanced',
  objectives: [
    'Adjust language for elders, peers, officials, and audiences.',
    'Make polite requests and respectful disagreements.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Register is your style choice for a relationship and setting. Politeness is built from _ho/po_, plural _kamo/ninyo/inyo_, courtesy words, softer requests, and tone.',
        ),
      ],
    ),
    LessonSection(
      title: 'Building blocks',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Situation', 'Friend / peer', 'Elder / official'],
          italicColumn: -1,
          rows: [
            ['Asking a name', 'Ano imo ngalan?', 'Ano ang ngalan ninyo, ho?'],
            [
              'Asking age',
              'Pila ka tuig ka na?',
              'Pila na ang edad ninyo, ho?',
            ],
            [
              'Requesting',
              'Hatagi ako sang tubig.',
              'Palihog, pwede bala mangayo sang tubig, ho?',
            ],
            ['Saying yes', 'Oo.', 'Oo ho.'],
            ['Thanks', 'Salamat.', 'Madamo nga salamat ho.'],
            ['Apology', 'Pasensya.', 'Pasayloa ako, ho.'],
            [
              'Addressing a group',
              'Kamusta kamo?',
              'Maayong aga sa inyo tanan.',
            ],
          ],
        ),
        BulletsBlock([
          '1. **ho / po** after answers and requests.',
          '2. **kamo, ninyo, inyo** for one respected person.',
          '3. **palihog** before a request.',
          '4. **Titles**: _Manang, Manong, Nay, Tay, Ma\'am, Sir_.',
          '5. **Softeners**: _lang_, _man_, _bala_.',
        ]),
      ],
    ),
    LessonSection(
      title: 'A formal opening',
      icon: Icons.waving_hand_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Maayong aga sa inyo tanan. Nagapasalamat ako sa inyo tanan nga nag-abot subong nga adlaw._ ("Good morning to all of you. I thank all of you who have come today.")',
        ),
      ],
    ),
    LessonSection(
      title: 'Polite disagreement',
      icon: Icons.waving_hand_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Nagatahod ako sang imo hunahuna, pero indi ako nagasugot._ ("I respect your thinking, but I don\'t agree.")',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Register', 'Discussion'],
          italicColumn: 0,
          rows: [
            ['Kaon na.', 'Casual', 'Between friends or family.'],
            ['Palihog, kaon na kita, ho.', 'Polite', 'Adds palihog and ho.'],
            [
              'Pwede bala ako mangutana, Ma\'am?',
              'Formal',
              'A question with title and bala.',
            ],
            [
              'Pasayloa ako, ho, nalate ako.',
              'Formal apology',
              'Full apology with ho.',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Write one request in casual, polite, and formal versions; each adds one or two respect elements without changing the core meaning.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Respect for elders is a core Filipino value; younger people traditionally address elders with Nay, Tay, Manang, or Manong, and add ho/po.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          '_Po/opo_ ~ _ho/po_; _kayo_ ~ _kamo_; _pakiusap_ ~ _palihog_. Do not copy Filipino politeness patterns without checking they sound natural locally.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Dropping _ho_ with elders.',
          'Using _ikaw_ to a respected person instead of _kamo_.',
          'Being too blunt when disagreeing.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you write a request in three registers?',
          'Can you deliver a short formal greeting to a group?',
          'Can you disagree respectfully?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson5 = Lesson(
  id: 'advanced_5',
  number: 5,
  title: 'Advanced Topical Conversation & Culture',
  subtitle: 'Discuss education, culture, technology, and community.',
  emoji: '🏝️',
  level: 'Advanced',
  objectives: [
    'Discuss education, culture, technology, and community.',
    'Describe festivals and traditions accurately.',
    'Structure a short talk.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Advanced conversation needs abstract vocabulary and cultural awareness, and separating facts from personal experience.',
        ),
      ],
    ),
    LessonSection(
      title: 'Vocabulary',
      icon: Icons.translate_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'Filipino', 'English'],
          italicColumn: 0,
          rows: [
            ['edukasyon', 'edukasyon', 'education'],
            ['teknolohiya', 'teknolohiya', 'technology'],
            ['kultura', 'kultura', 'culture'],
            ['komunidad', 'komunidad', 'community'],
            ['tradisyon', 'tradisyon', 'tradition'],
            ['epekto', 'epekto', 'effect'],
            ['pag-asenso', 'pag-unlad', 'progress / development'],
            ['problema', 'problema', 'problem'],
            ['solusyon', 'solusyon', 'solution'],
            ['pista', 'pista', 'fiesta'],
          ],
        ),
        QuizBlock(
          id: 'advanced_5_qc1',
          question: 'What does _solusyon_ mean in English?',
          options: ['progress / development', 'solution', 'fiesta'],
          answer: 1,
          explain: '_solusyon_ = solution.',
        ),
      ],
    ),
    LessonSection(
      title: 'Cultural facts you can discuss',
      icon: Icons.auto_awesome_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '**Dinagyang (Iloilo City):** held on the fourth Sunday of January in honor of the Santo Niño, known for tribal-costumed dance contingents and drumming.',
          '**MassKara (Bacolod):** held in October; it began in 1980 during a difficult time for the province and became a festival of smiling masks and colorful street dancing.',
          '**Paraw Regatta:** a February sailing race of traditional outrigger sailboats between Iloilo and Guimaras.',
          '**Sugar heritage:** Negros Occidental developed as a major sugar-producing province, shaping its history, architecture, and society.',
          '**Heritage churches:** Molo Church and Jaro Cathedral in Iloilo City are well-known landmarks.',
          '**Food identity:** batchoy, pancit Molo, chicken inasal, piaya, and guimaras mangoes.',
        ]),
      ],
    ),
    LessonSection(
      title: 'A five-part mini talk',
      icon: Icons.school_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. Introduce the topic.',
          '2. Give an example.',
          '3. Explain why it matters.',
          '4. Mention another perspective.',
          '5. Conclude.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Ang Dinagyang isa ka dako nga pista sa Iloilo. Ginahiwat ini kada Enero. Importante ini kay ginapakita sini ang kultura sang mga Ilonggo. Pero may nagasiling nga dapat man magtipig sang kalinong. Sa akon, maayo ini nga tradisyon._',
        ),
        ParagraphBlock(
          '("Dinagyang is a big festival in Iloilo. It is held every January. It is important because it shows the culture of Ilonggos. But some say we should also keep calm. For me, this is a good tradition.")',
        ),
        ParagraphBlock(
          '**Discussion.** The talk uses _kay_ (reason), _pero_ (contrast), and a personal opinion at the end. Separate fact (date, event) from opinion, and mark opinion with _Sa banta ko_ or _Sa akon_.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Iloilo City is often called the "City of Love" in local tourism branding and is known for its heritage buildings, festivals, and food.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Abstract vocabulary is often shared (_kultura, tradisyon, teknolohiya_), but check pronunciation and how locals prefer to say it.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Generalizing ("All Ilonggos...").',
          'Mixing fact and opinion.',
          'Overusing English for abstract words.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you give a two-minute talk on a festival?',
          'Can you mark opinion versus fact?',
          'Can you name three cultural landmarks or events?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson6 = Lesson(
  id: 'advanced_6',
  number: 6,
  title: 'Storytelling & Narration',
  subtitle: 'Tell a longer story with setting, problem, response, and outcome.',
  emoji: '📜',
  level: 'Advanced',
  objectives: [
    'Tell a longer story with setting, problem, response, and outcome.',
    'Use time words, connectors, and description.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'A story takes the listener from a starting situation to an ending in clear order, with correct aspect prefixes, visible time words, and a closing feeling.',
        ),
      ],
    ),
    LessonSection(
      title: 'A model story',
      icon: Icons.menu_book_rounded,
      minutes: 2,
      blocks: [
        TableBlock(
          headers: ['Stage', 'Purpose', 'Useful phrases'],
          italicColumn: -1,
          rows: [
            [
              'Setting',
              'who, where, when',
              'Sang bata pa ako... (When I was young...) / Sang isa ka adlaw... (One day...)',
            ],
            [
              'Problem',
              'what went wrong or changed',
              'Bigla lang... (Suddenly...) / Nawala ang... (... was lost)',
            ],
            ['Response', 'what happened next', 'Dayon... / Gani...'],
            ['Outcome', 'how it ended', 'Sa ulihi... / Nalipay ako kay...'],
            [
              'Reflection',
              'what it meant',
              'Nahangpan ko nga... (I realized that...)',
            ],
          ],
        ),
        ParagraphBlock(
          '_Sang bata pa ako, nagkadto kami sa Guimaras. Sang una, nalipay gid kami kay matahom ang baybay. Bigla lang, nag-ulan sing kusog. Nagdalagan kami pakadto sa balay sang amon lola. Pagkatapos, nagpainit kami sang sabaw kag nagkuwento. Sa ulihi, nahangpan ko nga ang maayo nga pagkaon kag ang pamilya amo ang labing importante._',
        ),
        ParagraphBlock(
          '("When I was young, we went to Guimaras. At first we were very happy because the beach was beautiful. Suddenly it rained hard. We ran to our grandmother\'s house. After that, we warmed up soup and told stories. In the end, I realized that good food and family are what matter most.")',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Function'],
          italicColumn: 0,
          rows: [
            ['Sang bata pa ako...', 'When I was young...', 'setting'],
            ['Bigla lang nag-ulan.', 'Suddenly it rained.', 'problem'],
            ['Gani nagdalagan kami.', 'So we ran.', 'result'],
            [
              'Sa ulihi, nalipay kami.',
              'In the end, we were happy.',
              'outcome',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Tell the same story twice, casually to a friend and formally for a class; note what changes (length, connectors, politeness) and what stays (the sequence).',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Oral storytelling (sugilanon) is a long tradition across Panay; family stories, legends, and riddles are passed on at gatherings.',
        ),
        FlashcardsBlock([
          Flashcard('Sang bata pa ako...', 'When I was young...'),
          Flashcard('Bigla lang nag-ulan.', 'Suddenly it rained.'),
          Flashcard('Gani nagdalagan kami.', 'So we ran.'),
          Flashcard('Sa ulihi, nalipay kami.', 'In the end, we were happy.'),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'advanced_6_qc2',
          question: 'What does _Sang bata pa ako..._ mean in English?',
          options: ['When I was young...', 'Suddenly it rained.', 'So we ran.'],
          answer: 0,
          explain: '_Sang bata pa ako..._ = When I was young....',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Keep the sequence but choose natural Hiligaynon clause order and verbs; do not translate your Filipino story word by word.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using present forms (_naga-_) for past events without a reason.',
          'No connectors, so the story sounds like a list.',
          'No ending or reflection.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you tell a three-minute story with all five stages?',
          'Can you retell it in two registers?',
          'Can you use at least four connectors?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson7 = Lesson(
  id: 'advanced_7',
  number: 7,
  title: 'Debate & Explanation',
  subtitle:
      'State a claim, give reasons and an example, and answer a counterpoint.',
  emoji: '⚖️',
  level: 'Advanced',
  objectives: [
    'State a claim, give reasons and an example, and answer a counterpoint.',
    'Keep a respectful tone.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'An argument is a claim supported by reasons. A polite debater states the view, acknowledges the other side, and then answers.',
        ),
      ],
    ),
    LessonSection(
      title: 'Model argument',
      icon: Icons.psychology_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Move', 'Hiligaynon frame', 'English'],
          italicColumn: 1,
          rows: [
            ['Claim', 'Sa banta ko...', 'In my opinion...'],
            [
              'Reason',
              '...kay... / Ang rason kay...',
              '...because... / The reason is...',
            ],
            ['Example', 'Halimbawa...', 'For example...'],
            ['Contrast', 'Sa pihak nga bahin...', 'On the other hand...'],
            ['Concession', 'Tuod, pero...', 'True, but...'],
            [
              'Conclusion',
              'Gani... / Sa katapusan...',
              'Therefore... / In the end...',
            ],
          ],
        ),
        ParagraphBlock(
          '_Sa banta ko, dapat mag-eskwela ang mga bata sa ila kaugalingon nga lengguwahe sa una nga mga tuig. Ang rason kay mas madali nila mahangpan ang leksyon. Halimbawa, kon Hiligaynon ang gamiton, mas matinlo ang ila pagsabot. Sa pihak nga bahin, kinahanglan man nila mag-eskwela sang Filipino kag Ingles. Tuod, pero mas maayo nga magsugod sa ila lengguwahe._',
        ),
        ParagraphBlock(
          '("In my opinion, children should study in their own language in the early years. The reason is that they understand lessons more easily. For example, if Hiligaynon is used, their understanding is clearer. On the other hand, they also need to learn Filipino and English. True, but it\'s better to begin with their own language.")',
        ),
        FlashcardsBlock([
          Flashcard('Sa banta ko...', 'In my opinion...'),
          Flashcard('Halimbawa...', 'For example...'),
          Flashcard('Sa pihak nga bahin...', 'On the other hand...'),
          Flashcard('Tuod, pero...', 'True, but...'),
          Flashcard(
            'Gani... / Sa katapusan...',
            'Therefore... / In the end...',
          ),
        ], title: 'Flip the cards'),
        QuizBlock(
          id: 'advanced_7_qc1',
          question: 'What does _Tuod, pero..._ mean in English?',
          options: [
            'True, but...',
            'On the other hand...',
            'Therefore... / In the end...',
          ],
          answer: 0,
          explain: '_Tuod, pero..._ = True, but....',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Function'],
          italicColumn: 0,
          rows: [
            [
              'Ang rason kay mas barato.',
              'The reason is that it\'s cheaper.',
              'reason',
            ],
            ['Halimbawa, ang dyip.', 'For example, the jeepney.', 'example'],
            [
              'Tuod, pero mahal ang bus.',
              'True, but the bus is expensive.',
              'concession',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Build a 90-second talk on a non-sensitive everyday topic: claim, reason, example, counterpoint, response, conclusion.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'This topic is real: Hiligaynon is one of the languages used in the Philippines\' mother-tongue-based early education program, and supporters and critics both make arguments about it.',
        ),
        QuizBlock(
          id: 'advanced_7_qc2',
          question: 'What does _Halimbawa, ang dyip._ mean in English?',
          options: [
            'For example, the jeepney.',
            'The reason is that it\'s cheaper.',
            'True, but the bus is expensive.',
          ],
          answer: 0,
          explain: '_Halimbawa, ang dyip._ = For example, the jeepney..',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          '_Sa palagay ko_ ~ _sa banta ko_; _sa kabilang banda_ ~ _sa pihak nga bahin_; _halimbawa_ is shared.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Sounding aggressive instead of respectful.',
          'No reason or example.',
          'Ignoring the other side.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you give a 90-second argument?',
          'Can you concede a point politely?',
          'Can you conclude clearly?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson8 = Lesson(
  id: 'advanced_8',
  number: 8,
  title: 'Advanced Listening',
  subtitle: 'Follow natural-speed speech from different speakers.',
  emoji: '📻',
  level: 'Advanced',
  objectives: [
    'Follow natural-speed speech from different speakers.',
    'Recover meaning when you miss words.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Natural speech has fast pace, interruptions, and code-switching. You do not need every word, only the meaning units.',
        ),
      ],
    ),
    LessonSection(
      title: 'Key Concepts',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        BulletsBlock([
          '1. **Listen for the topic and the speaker\'s attitude.**',
          '2. **Catch key facts:** who, where, when, how many, how much.',
          '3. **Revisit unclear parts** only after the first two passes.',
          '4. **Use context:** if you catch _ospital_ and _hilanat_, the topic is health.',
          '5. **Expect mixing:** _Nag-text ako kay Ana_ ("I texted Ana") mixes English and Hiligaynon.',
        ]),
        TableBlock(
          headers: ['Feature', 'Example', 'What to do'],
          italicColumn: -1,
          rows: [
            ['Speed', 'Diinkamakadto?', 'Listen for chunks, not words.'],
            ['Reduction', 'bala → ba', 'Recognize short forms.'],
            [
              'Mixing',
              'Okay lang, subong nga adlaw.',
              'Follow the Hiligaynon frame.',
            ],
            ['Accent', 'vowels differ by place', 'Compare speakers.'],
          ],
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          '_Sample text:_ "Hoy, Ben! Nabal-an mo na? Bukas wala na klase kay may bagyo daw." — "Ay, amo? Ginoo ko, salamat sa balita!"',
        ),
        ParagraphBlock(
          '(Hey, Ben! Did you know? There\'s no class tomorrow because there\'s supposedly a typhoon. — Oh really? My goodness, thanks for the news!)',
        ),
        ParagraphBlock(
          'Tasks: What is the news? Who says it? How does the second speaker feel? Which words are hearsay markers (_daw_)?',
        ),
        ParagraphBlock(
          '**Discussion.** The key content (no class, typhoon) is short and comes with _daw_, which shows the speaker is reporting, not certain.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Regional radio and local TV news in Hiligaynon are excellent listening resources; listening to two different speakers on the same topic trains you to handle accent differences.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Filipino gives you many cues, but always check for false friends and particles before deciding what was meant.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Freezing when one word is missed.',
          'Reading the transcript before listening again.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you summarize a two-minute recording?',
          'Can you list the differences between two speakers?',
          'Can you use context to guess a missed word?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson9 = Lesson(
  id: 'advanced_9',
  number: 9,
  title: 'Translation Mastery',
  subtitle: 'Translate texts with correct meaning, tone, and register.',
  emoji: '🌐',
  level: 'Advanced',
  objectives: [
    'Translate texts with correct meaning, tone, and register.',
    'Handle idioms, politeness, and ambiguity.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'At this level you translate communicative effect, not words: who is speaking to whom, how strongly, and in what setting.',
        ),
      ],
    ),
    LessonSection(
      title: 'Workflow',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Challenge', 'Approach', 'Example'],
          italicColumn: -1,
          rows: [
            ['Idiom', 'Translate the effect', 'Ginoo ko! → "Naku!" / "Oh my!"'],
            ['Politeness', 'Keep the level', 'Palihog ho → "Pakiusap po"'],
            ['Emphasis', 'Keep intensity', 'Matahom gid → "Napakaganda"'],
            ['Ambiguity', 'Use context, or ask', 'Kita ang magkadto (we go)'],
            [
              'Set phrase',
              'Use the equivalent phrase',
              'Diin ka makadto? → "Saan ka pupunta?"',
            ],
          ],
        ),
        BulletsBlock([
          '1. Read the whole text first.',
          '2. Mark idioms and particles.',
          '3. Translate meaning by meaning.',
          '4. Read aloud in the target language.',
          '5. Back-translate and compare.',
        ]),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Filipino', 'Hiligaynon', 'Note'],
          italicColumn: 1,
          rows: [
            [
              'Mag-ingat po kayo sa biyahe.',
              'Ingat kamo sa biyahe, ho.',
              'respect kept with kamo and ho',
            ],
            [
              'Sana gumaling ka na.',
              'Kabay pa nga maayo na ikaw.',
              'sana → kabay pa',
            ],
            [
              'Ang ganda talaga ng dagat!',
              'Matahom gid ang baybay!',
              'talaga → gid',
            ],
            ['Ewan ko ba!', 'Ambot lang gid!', 'tone and particles kept'],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** Translate a short paragraph yourself, then have someone check meaning, register, and naturalness. More than one translation can be correct.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Professional translators often work in teams: one translates, another edits. Try the same with a study partner.',
        ),
        QuizBlock(
          id: 'advanced_9_qc2',
          question: 'What does _Ambot lang gid!_ mean in Filipino?',
          options: [
            'Ewan ko ba!',
            'Mag-ingat po kayo sa biyahe.',
            'Ang ganda talaga ng dagat!',
          ],
          answer: 0,
          explain: '_Ambot lang gid!_ = Ewan ko ba!.',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Use the systematic-differences table from Intermediate Lesson 10 as a checklist, then apply nuance.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Over-literal translation.',
          'Losing politeness or emphasis.',
          'Assuming only one correct answer.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you translate a paragraph in both directions?',
          'Can you explain three choices you made?',
          'Can you keep politeness and emphasis?',
        ]),
      ],
    ),
  ],
);

const Lesson advancedLesson10 = Lesson(
  id: 'advanced_10',
  number: 10,
  title: 'Real-World Communication',
  subtitle:
      'Use Hiligaynon in messages, calls, interviews, and community settings.',
  emoji: '🌏',
  level: 'Advanced',
  objectives: [
    'Use Hiligaynon in messages, calls, interviews, and community settings.',
    'Handle written and spoken formats.',
  ],
  sections: [
    LessonSection(
      title: 'Introduction',
      icon: Icons.auto_stories_rounded,
      minutes: 1,
      blocks: [
        ParagraphBlock(
          'Real communication happens in messages, calls, meetings, and events, each with its own conventions of opening, tone, and closing.',
        ),
      ],
    ),
    LessonSection(
      title: 'A model message',
      icon: Icons.lightbulb_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Format', 'Opening', 'Closing'],
          italicColumn: -1,
          rows: [
            ['Text to a friend', 'Hoy, kamusta?', 'Ingat!'],
            ['Text to an elder', 'Maayong aga ho, Manang.', 'Salamat ho.'],
            [
              'Phone call',
              'Hello, si Ana ini. (This is Ana.)',
              'Sige, salamat.',
            ],
            [
              'Interview',
              'Maayong aga ho. Salamat sa oportunidad.',
              'Salamat gid sa inyo panahon.',
            ],
            [
              'Community meeting',
              'Maayong hapon sa inyo tanan.',
              'Madamo nga salamat.',
            ],
          ],
        ),
        ParagraphBlock(
          '_Maayong aga ho, Ma\'am. Si Ana ini. Indi ako makaabot sa klase subong kay ginahilanat ako. Pasayloa ako, ho. Ipasa ko ang report buas. Salamat gid._',
        ),
        ParagraphBlock(
          '("Good morning, ma\'am. This is Ana. I can\'t come to class today because I have a fever. Please forgive me. I will submit the report tomorrow. Thank you very much.")',
        ),
      ],
    ),
    LessonSection(
      title: 'Examples & Dialogue',
      icon: Icons.forum_rounded,
      minutes: 1,
      blocks: [
        TableBlock(
          headers: ['Hiligaynon', 'English', 'Use'],
          italicColumn: 0,
          rows: [
            ['Ari na ako sa gwa.', 'I\'m outside already.', 'text to a friend'],
            [
              'Mahimo bala nga mag-usap kita buas?',
              'Could we talk tomorrow?',
              'polite request',
            ],
            [
              'Nagapasalamat ako sa oportunidad.',
              'I\'m grateful for the opportunity.',
              'interview',
            ],
            [
              'Palihog, hulata ako sa lobby.',
              'Please wait for me in the lobby.',
              'practical',
            ],
          ],
        ),
        ParagraphBlock(
          '**Discussion.** The message follows a pattern: greeting, who, reason, apology, promise, thanks. For a friend, drop _ho_ and _Ma\'am_.',
        ),
        CalloutBlock(
          title: 'Did you know?',
          emoji: '💡',
          color: teal300,
          text:
              'Text messaging in the Philippines commonly mixes languages and shortens words; when writing to elders or officials, choose full, polite forms.',
        ),
        QuizBlock(
          id: 'advanced_10_qc2',
          question:
              'What does _Palihog, hulata ako sa lobby._ mean in English?',
          options: [
            'Please wait for me in the lobby.',
            'Could we talk tomorrow?',
            'I\'m grateful for the opportunity.',
          ],
          answer: 0,
          explain:
              '_Palihog, hulata ako sa lobby._ = Please wait for me in the lobby..',
        ),
      ],
    ),
    LessonSection(
      title: 'Filipino Bridge & Mistakes',
      icon: Icons.swap_horiz_rounded,
      minutes: 1,
      blocks: [
        SubheadingBlock('Filipino ⇄ Hiligaynon bridge'),
        ParagraphBlock(
          'Keep the same manners you use in Filipino, but replace vocabulary and markers with Hiligaynon ones.',
        ),
        SubheadingBlock('Common mistakes'),
        BulletsBlock([
          'Using slang with elders or officials.',
          'Forgetting the closing thanks.',
          'Being too short and blunt in messages.',
        ]),
        SubheadingBlock('Self-check'),
        BulletsBlock([
          'Can you write a polite message to an elder?',
          'Can you handle a short phone call?',
          'Can you introduce yourself in a formal setting?',
        ]),
      ],
    ),
  ],
);

/// Beginner lessons 3 to 12 (lessons 1 and 2 live in library_screen.dart).
const List<Lesson> generatedBeginnerLessons = [
  beginnerLesson3,
  beginnerLesson4,
  beginnerLesson5,
  beginnerLesson6,
  beginnerLesson7,
  beginnerLesson8,
  beginnerLesson9,
  beginnerLesson10,
  beginnerLesson11,
  beginnerLesson12,
];

const List<Lesson> generatedIntermediateLessons = [
  intermediateLesson1,
  intermediateLesson2,
  intermediateLesson3,
  intermediateLesson4,
  intermediateLesson5,
  intermediateLesson6,
  intermediateLesson7,
  intermediateLesson8,
  intermediateLesson9,
  intermediateLesson10,
  intermediateLesson11,
];

const List<Lesson> generatedAdvancedLessons = [
  advancedLesson1,
  advancedLesson2,
  advancedLesson3,
  advancedLesson4,
  advancedLesson5,
  advancedLesson6,
  advancedLesson7,
  advancedLesson8,
  advancedLesson9,
  advancedLesson10,
];
