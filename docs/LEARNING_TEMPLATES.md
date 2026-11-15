# Hibalo Learning Module – Template Guide

Reference for the Learning module in Flutter. The content is in `assets/lessons/` (schema v8): `learning_settings.json` (settings, templates, level list) plus `beginner_lessons.json`, `intermediate_lessons.json` and `advanced_lessons.json`. If this file and the JSON disagree, the JSON wins. Filipino lesson text lives in `*.fil.json` overlays next to them (see `LEARNING_BEHAVIOR.md` §1.14).

**Status:** AI-drafted by the team with Claude. NOT checked by a native speaker. Key words were spot-checked against public references (see 'references'). Items marked check: 'unverified' could not be confirmed. No native-speaker check is planned.

Every reading part (`P08`) and dialogue part (`P07`) is required content: each lesson has at least one reading.

## How it fits together

```
Learn (S01) → Lesson Detail (S02) → parts[] in order (P01–P14) → Lesson complete (S03)
  → quiz.questions[] (Q01–Q13, each followed by a feedback sheet F01–F04) → Quiz result (S04) → Quiz review (S05)
Any X button → Leave pop-up (S06)
```

- Every part has `"template": "P0x"` and every question has `"template": "Q0x"`. Look the ID up below to find the Figma frame and widget.
- One widget per template. A lesson never needs its own screen: it is only data.
- The segmented progress bar has one segment per part (`partsCount`).
- Text between `*asterisks*` is a Hiligaynon/Filipino example: render it italic, violet.
- Lesson 1 (`kind: "letters"`) has no quiz; finishing it unlocks Lesson 2.

## Rules from `settings`

| Rule | Value |
|---|---|
| Pass mark | 80% of scored questions |
| XP | 10 per correct question, 20 per finished lesson, 5 per right quick check |
| Timer | 30s on multiple_choice, listening, fill_blank, build_sentence, real_situation, match_pairs; time out counts as wrong |
| Result tiers | Perpekto! (≥100%) · Maayo gid! (≥80%) · Keep practicing (≥0%; "Magsanay pa" in Filipino) |
| Not scored | `scored: false` (speaking, open_answer) – shown as "Practice" in review |
| Unlock | `unlock.needs`: `complete` or `passQuiz` of `unlock.after`; levels unlock after the previous level |

## Screens

| ID | Name | Figma frame | Flutter widget | JSON fields | Variants |
|---|---|---|---|---|---|
| **S01** | Learn (lesson list) | Learn | `LearnScreen` | `levels[].lessons[]: title, partsCount, estMinutes, icon, unlock` | Row: Completed<br>Row: Current<br>Row: Quiz pending<br>Row: Locked<br>Level tab: Locked |
| **S02** | Lesson Detail | Lesson Detail | `LessonDetailScreen` | `title`<br>`coverImage (335 × 197, cover)`<br>`objectives`<br>`partsCount`<br>`estMinutes` | Not started: Start lesson<br>In progress: Continue lesson + progress card<br>Completed: chip "Completed · Quiz X/Y", Review lesson + Retake the quiz, no progress card<br>Letters version |
| **S03** | Lesson complete | Lesson complete | `LessonCompleteScreen` | `settings.xp.lessonComplete`<br>`count of items (New words)` | Letters version: Lesson complete · Letters |
| **S04** | Quiz result | Quiz result · Perpekto / Maayo gid / Keep practicing | `QuizResultScreen` | `settings.resultTiers`<br>`settings.xp.perCorrect`<br>`unlock of the next lesson` | Perpekto<br>Maayo gid<br>Keep practicing |
| **S05** | Quiz review | Quiz review / Quiz review · Passed | `QuizReviewScreen` | `quiz.questions in order`<br>`scored` | Failed: Try again<br>Passed: Continue |
| **S06** | Leave pop-up | Leave lesson / Leave quiz | `LeaveDialog` | – | Lesson<br>Quiz |

## Lesson parts

| ID | Name | Figma frame | Flutter widget | JSON fields | Variants |
|---|---|---|---|---|---|
| **P01** | Key idea (`key_idea`) | Part · Key idea | `KeyIdeaPart` | `title`<br>`icon (Material Symbols Rounded name)`<br>`text`<br>`terms[]: hil, note, fil (optional)` | – |
| **P02** | Table (`table`) | Part · Table | `TablePart` | `title`<br>`icon`<br>`text`<br>`columns[]`<br>`rows[][]`<br>`hilColumns[] (indexes of Hiligaynon columns: italic violet)` | 2 to 4 columns |
| **P03** | Pattern (`pattern`) | Part · Pattern | `PatternPart` | `title`<br>`icon`<br>`text`<br>`slots[]: label, hil, highlight (one slot: the link word)`<br>`fil`<br>`examples[]: hil, fil` | 3 or 4 slots; the highlighted slot is violet with a glow, the others alternate citrus and lagoon |
| **P04** | Words (learn cards) (`words`) | Part · Words = Learn card | `WordsPart` | `title`<br>`itemIds[] -> items[]: hil, fil, alt, audio, image, example` | Default<br>No image: image is null → firefly_reading (Example box still shows if example exists)<br>No example: example is null → hide the Example box<br>Number: alt → "Also said: …" |
| **P05** | Letters & sounds (`letters`) | Lesson Content (Letters & sounds) | `LettersPart` | `letters[]: letter, name, soundHint, audio, example` | Chip: Current<br>Chip: Seen<br>Chip: Not seen |
| **P06** | Quick check (`quick_check`) | Part · Quick check | `QuickCheckPart` | `prompt`<br>`options`<br>`answer`<br>`explain` | Uses Feedback sheet F01/F02, no timer, +settings.xp.quickCheck |
| **P07** | Dialogue (`dialogue`) | Part · Dialogue | `DialoguePart` | `title`<br>`icon`<br>`setting`<br>`lines[]: speaker, hil, fil`<br>`tip`<br>`avatar from settings.avatars` | Line: Filipino hidden<br>Line: Filipino shown |
| **P08** | Reading (`reading`) | Part · Reading | `ReadingPart` | `title`<br>`icon`<br>`lines[]: hil, fil`<br>`tip` | Line: Filipino hidden<br>Line: Filipino shown |
| **P09** | Filipino bridge & mistakes (`bridge_mistakes`) | Part · Filipino bridge & mistakes | `BridgeMistakesPart` | `title`<br>`icon`<br>`bridge[]`<br>`mistakes[]: wrong, right, why` | – |
| **P10** | Culture note (`culture_note`) | Culture note | `CultureNotePart` | `title`<br>`text`<br>`image` | – |
| **P11** | Role-play (`role_play`) – Intermediate, Advanced | P11 · Part · Role-play · Choose / Right choice / Not quite / Done | `RolePlayPart` | `title`<br>`icon`<br>`setting`<br>`turns[]: speaker, hil, fil, cue, fast, quote, choices[]: hil, fil, note, correct, hint`<br>`tip` | Choose (Next waits)<br>Right choice (the learner's reply, Ana's side)<br>Not quite: hint, try another reply<br>Done |
| **P12** | Verb forms (`verb_forms`) – Intermediate | P12 · Part · Verb forms · kaon / inom | `VerbFormsPart` | `title`<br>`icon`<br>`text`<br>`columns[] (3)`<br>`roots[]: root, fil, forms[3], doerForms[3] (optional), example{hil,fil}`<br>`note` | One root at a time (root chips)<br>doerForms: "Who does it" row above "What it happens to" |
| **P13** | Idiom cards (`idiom_cards`) – Advanced | P13 · Part · Idiom card · Default / Careful (+ long card) | `IdiomCardsPart` | `cards[]: hil, literal, means, tone, careful, sayTo, warning, example{hil[], fil[]}, audio` (no part title shown) | Default<br>Careful: tone chip in Warning colour + warning line<br>Counter "n / N", Back/Next like P04 |
| **P14** | Formal vs casual (`register_pairs`) – Advanced | P14 · Part · Formal vs casual (+ paging, wrong-on-purpose, long text) | `RegisterPairsPart` | `title`<br>`icon`<br>`leftLabel`<br>`rightLabel`<br>`leftWrongOnPurpose`<br>`situations[]: title, left{hil, fil, note}, right{hil, fil}, changes[]` | Header = situation title, part title under it<br>Counter "n / N"<br>left.note: grey card with ✗ and the note instead of Filipino |

## Quiz questions

| ID | Name | Figma frame | Flutter widget | JSON fields | Variants |
|---|---|---|---|---|---|
| **Q01** | Multiple choice (`multiple_choice`) | Quiz · Multiple choice | `MultipleChoiceQuestion` | `prompt`<br>`options`<br>`answer`<br>`answerAudio` | timed |
| **Q02** | Listening (`listening`) | Quiz · Listening | `ListeningQuestion` | `prompt`<br>`audio`<br>`optionKind`<br>`options`<br>`answer`<br>`answerAudio` | timed |
| **Q03** | Fill in the blank (`fill_blank`) | Quiz · Fill in the blank | `FillBlankQuestion` | `sentence`<br>`meaning`<br>`options`<br>`answer`<br>`answerAudio` | timed |
| **Q04** | Type the answer (`type_answer`) | Quiz · Type the answer | `TypeAnswerQuestion` | `direction`<br>`text`<br>`accepted`<br>`answerAudio` | no timer |
| **Q05** | Build the sentence (`build_sentence`) | Quiz · Build the sentence | `BuildSentenceQuestion` | `prompt`<br>`tiles`<br>`answer`<br>`answerAudio` | timed |
| **Q06** | Real situation (`real_situation`) | Quiz · Real situation | `RealSituationQuestion` | `situation`<br>`image`<br>`options`<br>`answer`<br>`answerAudio` | timed<br>No image -> firefly_reading |
| **Q07** | Match pairs (`match_pairs`) | Quiz · Match pairs | `MatchPairsQuestion` | `prompt`<br>`pairs` | timed |
| **Q08** | Dictation (`dictation`) | Quiz · Dictation | `DictationQuestion` | `prompt`<br>`audio`<br>`accepted`<br>`wordBank`<br>`answerAudio (same clip as audio)` | no timer |
| **Q09** | Speaking (`speaking`) | Quiz · Speaking (+ Q09 / Checking, Result / Very close · Almost · Try again, No clip, Couldn't hear) | `SpeakingQuestion` | `prompt`<br>`text`<br>`meaning`<br>`audio`<br>`settings.pronunciationFeedback` | no timer<br>not scored<br>pronunciation feedback when a clip exists (see LEARNING_BEHAVIOR §4) |
| **Q10** | Open answer (`open_answer`) | Quiz · Open answer | `OpenAnswerQuestion` | `prompt`<br>`hint`<br>`maxChars`<br>`modelAnswer`<br>`audio`, `transcript` (optional) | no timer<br>not scored |
| **Q11** | Read & answer (`read_answer`) – Intermediate | Q11 · Quiz · Read & answer (+ Listening variants) | `ReadAnswerQuestion` | `mode: read / listen`<br>`passagePart`<br>`question`<br>`options`<br>`answer` | no timer<br>read: the passage ("Speaker: line" for dialogues)<br>listen: Play conversation, Show transcript after answering |
| **Q12** | Spot the mistake (`spot_mistake`) – Advanced | Q12 · Quiz · Spot the mistake · Default / Word selected / Correct / Wrong (+ wrap) | `SpotMistakeQuestion` | `prompt`<br>`sentence`<br>`tiles[]` (the sentence split on spaces)<br>`meaning`<br>`wrongIndex`<br>`fix` | no timer<br>right = tapping `tiles[wrongIndex]`<br>tiles wrap |
| **Q13** | Passage set (`passage_set`) – Advanced | Q13 · Quiz · Passage set · Reading / Listening (+ dialogue passage) | `ReadAnswerQuestion` (`PassageSetData`) | `mode: read / listen`<br>`passagePart`<br>`setIndex`, `setSize`<br>`question`<br>`options`<br>`answer` | no timer<br>3 scored questions in a row, "Question n of 3"<br>passage folds to "Show story" from question 2 |

## Feedback sheets

| ID | Name | Figma frame | Flutter widget | JSON fields | Variants |
|---|---|---|---|---|---|
| **F01** | Correct | Feedback · Correct | `FeedbackSheet(type: correct)` | `+XP` | – |
| **F02** | Wrong | Feedback · Wrong | `FeedbackSheet(type: wrong)` | `correct answer`<br>`answerAudio` | – |
| **F03** | Time's up | Feedback · Time's up | `FeedbackSheet(type: timeout)` | `correct answer`<br>`answerAudio` | counts as wrong |
| **F04** | Sample answer | Feedback · Sample answer | `FeedbackSheet(type: info)` | `modelAnswer` | open_answer only |

## Which lesson uses which template

Beginner only below; Intermediate and Advanced lessons are listed in their JSON files.


| Lesson | Status | Min | P01 | P02 | P03 | P04 | P05 | P06 | P07 | P08 | P09 | P10 | Quiz |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 Letters & Sounds | ready | 8 | 4 | · | · | · | 1 | 1 | · | 1 | 1 | · | – |
| 2 Greetings & Courtesy | ready | 10 | 3 | · | · | 3 | · | 2 | 1 | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q09 |
| 3 Pronouns & Identity | ready | 9 | 2 | 1 | · | 3 | · | 1 | · | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q09 |
| 4 Introducing Yourself | ready | 10 | 4 | · | · | 4 | · | 1 | 1 | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q08 Q10 |
| 5 Numbers 1 to 10 | ready | 9 | 2 | · | 1 | 2 | · | 1 | · | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q08 |
| 6 Time, Days & Months | ready | 10 | 2 | 2 | 1 | 3 | · | 2 | · | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q07 Q08 Q09 |
| 7 Family & People | ready | 10 | 2 | 1 | 1 | 2 | · | 1 | · | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q09 |
| 8 Places & Directions | ready | 10 | 2 | 1 | 1 | 3 | · | 1 | 1 | 1 | 1 | 1 | Q01 Q02 Q03 Q05 Q06 Q07 Q08 Q09 |
| 9 Food, Market & Money | ready | 10 | 3 | 1 | 1 | 4 | · | 1 | 1 | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q09 Q10 |
| 10 Basic Verbs | ready | 10 | 2 | 1 | 1 | 2 | · | 1 | · | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q07 Q08 Q09 |
| 11 Asking Questions | ready | 9 | 1 | 1 | 1 | 3 | · | 1 | 1 | 1 | 1 | 1 | Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q09 |
| 12 Building Sentences | ready | 9 | · | 2 | 2 | 3 | · | 1 | · | 1 | 1 | · | Q01 Q02 Q03 Q04 Q05 Q07 Q08 Q09 |
| 13 Daily Conversations | ready | 10 | 3 | · | · | 2 | · | 1 | 3 | 1 | 1 | 1 | Q01 Q02 Q05 Q06 Q07 Q08 Q09 Q10 |

## Lesson outlines

### Lesson 1 – Letters & Sounds (b01, 8 min)

1. `P01` Meet Hiligaynon
2. `P01` Letters You Already Know
3. `P05` Letters & sounds
4. `P01` “NG” Is One Letter
5. `P01` The Short Stop (-)
6. `P06` Quick check: Which word has a short stop in the middle?
7. `P08` Read Your First Words
8. `P09` Filipino ⇄ Hiligaynon

### Lesson 2 – Greetings & Courtesy (b02, 10 min)

1. `P01` Greetings by Time of Day
2. `P04` Greetings
3. `P06` Quick check: It's 8 in the evening and your neighbor walks by. What do you say?
4. `P01` Asking “How Are You?”
5. `P04` How are you?
6. `P01` Polite Words
7. `P04` Polite words
8. `P06` Quick check: Someone says “Salamat!” to you. What do you reply?
9. `P07` Greeting an Older Neighbor
10. `P08` A Thank-You Message
11. `P09` Filipino ⇄ Hiligaynon
12. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q05`, `Q07`, `Q04`, `Q06`, `Q01`, `Q09`

### Lesson 3 – Pronouns & Identity (b03, 9 min)

1. `P01` Words for People
2. `P04` I, you, he/she
3. `P01` Two Words for “We”
4. `P04` We, you, they
5. `P06` Quick check: Which word means “tayo”?
6. `P02` Saying “My”
7. `P04` My house
8. `P08` Ana's Class
9. `P09` Filipino ⇄ Hiligaynon
10. `P10` Did you know?

Quiz: `Q03`, `Q01`, `Q06`, `Q05`, `Q04`, `Q07`, `Q02`, `Q01`, `Q09`

### Lesson 4 – Introducing Yourself (b04, 10 min)

1. `P01` Your Name
2. `P04` Your name
3. `P01` Where You Are From: Taga-
4. `P04` Where you are from
5. `P06` Quick check: How do you say you're from Sto. Tomas?
6. `P01` Age and Work
7. `P04` Age and work
8. `P01` Keep the Talk Going
9. `P04` Asking back
10. `P07` Meeting a New Classmate
11. `P08` Ben Introduces Himself
12. `P09` Filipino ⇄ Hiligaynon
13. `P10` Did you know?

Quiz: `Q07`, `Q01`, `Q05`, `Q04`, `Q03`, `Q02`, `Q06`, `Q08`, `Q01`, `Q10`

### Lesson 5 – Numbers 1 to 10 (b05, 9 min)

1. `P01` Counting 1 to 10
2. `P04` 1 to 5
3. `P04` 6 to 10
4. `P06` Quick check: What comes after lima?
5. `P03` Counting Things: Number + ka
6. `P01` Two Number Systems
7. `P08` At the Sari-sari Store
8. `P09` Filipino ⇄ Hiligaynon
9. `P10` Did you know?

Quiz: `Q05`, `Q04`, `Q03`, `Q02`, `Q07`, `Q01`, `Q06`, `Q08`, `Q01`

### Lesson 6 – Time, Days & Months (b06, 10 min)

1. `P01` Day and Sun, Month and Moon
2. `P04` Day, week, month
3. `P02` Days of the Week
4. `P04` Days
5. `P06` Quick check: What is “Linggo” (Sunday) in Hiligaynon?
6. `P02` Months of the Year
7. `P01` Today, Tomorrow, Yesterday
8. `P04` When
9. `P03` Telling the Time
10. `P06` Quick check: How do you say 7:00 in the morning?
11. `P08` Ana's Week
12. `P09` Filipino ⇄ Hiligaynon
13. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q04`, `Q05`, `Q07`, `Q08`, `Q01`, `Q09`

### Lesson 7 – Family & People (b07, 10 min)

1. `P01` Your Close Family
2. `P04` Close family
3. `P01` Your Extended Family
4. `P04` Extended family
5. `P02` Calling People Respectfully
6. `P06` Quick check: Which word means “pinsan”?
7. `P03` Whose Is It?
8. `P08` This Is My Family
9. `P09` Filipino ⇄ Hiligaynon
10. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q04`, `Q05`, `Q06`, `Q07`, `Q01`, `Q09`

### Lesson 8 – Places & Directions (b08, 10 min)

1. `P01` Places in Town
2. `P04` Places
3. `P02` This, That, Here, There
4. `P04` Here and there
5. `P03` Saying Where: Ara sa
6. `P01` Directions
7. `P04` Left and right
8. `P06` Quick check: Which word means “kanan”?
9. `P07` Asking the Way
10. `P08` My Town
11. `P09` Filipino ⇄ Hiligaynon
12. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q05`, `Q06`, `Q07`, `Q08`, `Q01`, `Q09`

### Lesson 9 – Food, Market & Money (b09, 10 min)

1. `P01` Meals of the Day
2. `P04` Meals
3. `P01` Kan-on or Bugas?
4. `P04` Rice and food
5. `P02` How Does It Taste?
6. `P04` Tasty!
7. `P03` Asking for Something
8. `P06` Quick check: Which word means “masarap”?
9. `P01` Asking the Price
10. `P04` Prices
11. `P07` At the Palengke
12. `P08` Lunch at Home
13. `P09` Filipino ⇄ Hiligaynon
14. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q04`, `Q05`, `Q06`, `Q07`, `Q01`, `Q09`, `Q10`

### Lesson 10 – Basic Verbs (b10, 10 min)

1. `P01` The Root Stays, the Start Changes
2. `P02` Now, Done, Later
3. `P04` Action words 1
4. `P04` Action words 2
5. `P03` Who Did What
6. `P06` Quick check: Which word means “kumain” (done)?
7. `P01` Telling Someone What to Do
8. `P08` Ana's Day
9. `P09` Filipino ⇄ Hiligaynon
10. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q04`, `Q05`, `Q07`, `Q08`, `Q01`, `Q09`

### Lesson 11 – Asking Questions (b11, 9 min)

1. `P02` Question Words
2. `P04` Question words 1
3. `P04` Question words 2
4. `P06` Quick check: Which word means “bakit”?
5. `P01` Yes or No?
6. `P04` Answers
7. `P03` Building a Question
8. `P07` Getting to Know a Neighbor
9. `P08` Questions Ana Asks
10. `P09` Filipino ⇄ Hiligaynon
11. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q03`, `Q04`, `Q05`, `Q06`, `Q07`, `Q01`, `Q09`

### Lesson 12 – Building Sentences (b12, 9 min)

1. `P03` The Describing Word Comes First
2. `P04` Describing words
3. `P02` Small Marker Words
4. `P03` Joining with nga
5. `P06` Quick check: Fill in: Daku ___ balay.
6. `P02` Saying No: indi, wala, ayaw
7. `P04` Saying no
8. `P04` Small words
9. `P08` Not Today
10. `P09` Filipino ⇄ Hiligaynon

Quiz: `Q01`, `Q02`, `Q03`, `Q04`, `Q05`, `Q07`, `Q08`, `Q01`, `Q09`

### Lesson 13 – Daily Conversations (b13, 10 min)

1. `P01` The Shape of a Conversation
2. `P01` When You Don't Understand
3. `P04` Helpful phrases
4. `P06` Quick check: How do you ask someone to speak slowly?
5. `P01` Saying Goodbye
6. `P04` Goodbyes
7. `P07` Meeting a Neighbor
8. `P07` Buying a Drink
9. `P07` Asking for Help
10. `P08` Ana's Day in Sta. Maria
11. `P09` Filipino ⇄ Hiligaynon
12. `P10` Did you know?

Quiz: `Q01`, `Q02`, `Q05`, `Q06`, `Q07`, `Q08`, `Q01`, `Q09`, `Q10`
