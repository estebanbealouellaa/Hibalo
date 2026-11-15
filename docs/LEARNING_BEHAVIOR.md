# Hibalo Learning Module – Screen Behaviour Guide

How every screen in the Figma **Version 6** page behaves, so it can be built in Flutter without guessing.

Read it together with:
- `LEARNING_TEMPLATES.md` – IDs, Figma frame names, widget names, JSON fields.
- `assets/lessons/` (schema v8, Nov 11): `learning_settings.json` (settings, templates, level list) + one file per level (`beginner_lessons.json`, `intermediate_lessons.json`, `advanced_lessons.json` from Nov 12) – the content and app settings. If this guide and the JSON disagree on **content or settings**, the JSON wins. If they disagree on **behaviour**, this guide wins.

Items marked **(Proposal)** are shown in Figma with a purple "Proposal, not in source" tag. Build them; they are design decisions, not confirmed requirements.

**Content status:** all Hiligaynon text was drafted with AI help and spot-checked against published references. It has **not** been checked by a native speaker, and no native-speaker check is planned. Lesson 12's banner and icon show "Ako ay masaya." and are kept as they are by decision.

---

## 1. Global rules

### 1.1 Flow
```
S01 Learn → S02 Lesson Detail → parts[] in order (P01–P12) → S03 Lesson complete
  → quiz.questions[] in order (Q01–Q13, each followed by F01–F04) → S04 Quiz result → S05 Quiz review
Any X button → S06 Leave pop-up
```
- A lesson never has its own screen. Each part and question is rendered by the widget for its `template` ID.
- Lesson 1 (`kind: "letters"`) has **no quiz**. Finishing its last part unlocks Lesson 2.

### 1.2 Back rule (lesson parts)
- **Back goes to the previous step.** A step is a card, a letter or a part, whichever is smaller.
- Back is **disabled only on the very first step of the lesson** (part 1, first screen). Disabled = 38% opacity, not tappable.
- Inside a multi-step part (P04 cards, P05 letters), Back first moves to the previous card or letter. On the first card or letter, Back goes to the **previous part**, opened at its **last** step.
- Quiz screens (Q01–Q10) have **no Back**. The only way out is the X button.
- Android system back = the on-screen Back. On a quiz screen it opens S06 Leave quiz.

### 1.3 X button
- Lesson parts: X opens **S06 Leave lesson**.
- Quiz screens: X opens **S06 Leave quiz**.

### 1.4 Audio rule
- There is **one native-speaker clip per word or phrase** (`items[].audio`) and **one per letter** (`letters[].audio`: the example word only, not the letter name; Nov 10 native recordings). Quiz `audio` and `answerAudio` always point to one of these clips.
- Example sentences, dialogue lines, reading lines, term cards, table rows and pattern examples are **text only**. Never show a speaker icon for them.
- Slow audio plays the same clip at 0.75× (`_meta.audioPolicy`).
- Audio buttons are shown **only when their clip is in the app** (Lance, Nov 11; replaces "always shown"). A clip that isn't in the AssetManifest is treated like `answerAudio: null`: its button is hidden. All 133 Beginner clips exist, so nothing changes there; every Intermediate clip is missing for now. When recordings are added (and their `assets/audio/…/` folders registered in `pubspec.yaml`), the buttons appear with no code change. Questions that need their clip (Q02, Q08, Q09, Q11 listen) show the Hiligaynon text with "Audio coming soon" instead (Stage 4). This covers the P04 word card audio and slow audio buttons, the P05 letter speaker, Q02 Listening, Q08 Dictation, Q09 "Native speaker", and the F02/F03 sheets whenever `answerAudio` is set in the JSON.
- The Translate feature speaks with the offline MMS-TTS voice. Lesson audio never does; it is always the recorded clips.

### 1.5 Text markup and app language
- Text between `*asterisks*` in the JSON is a Hiligaynon or Filipino example. Render it *italic, violet* (`V6/Color/Primary`). In the teal tip card use `V6/Color/Accent/Lagoon Text`.
- **App language** (`settings.uiLanguages`): the user picks English, Filipino or Hiligaynon in the language pop-up and in Me › Language. Only the app's own words follow it: menus, buttons, labels, chips, messages and the fixed screen titles in this guide ("Lesson complete!", "Not quite", "Review answers"…). Keep these in a translation file, not in the widgets. The choice is saved per account (Nov 7): signed-out screens are always English, signing in restores that account's choice (English if none), logging out returns to English. The pop-up shows only right after Sign Up.
- **Lesson text follows the app language too** (§1.14): English shows the English lesson text; Filipino and Hiligaynon show the Filipino lesson text. Hiligaynon always stays Hiligaynon and the meanings are always Filipino.

### 1.6 Segmented progress (all lesson parts)
- Component: `Lesson progress · Segmented`. X on the left, segments in the middle, XP chip on the right.
- **One segment per part** (`partsCount`). Beginner lessons have 8 to 14 parts, Intermediate up to 15; the loader allows up to **20**. Draw as many segments as `partsCount`, equal width, 4 px gap.
- Segment states: **Done** (violet) before the current part, **Current** (dark violet), **Next** (light violet).
- The bar moves only when the **part** changes, not per card or letter.
- XP chip = XP this lesson has paid so far, across all runs (for example "5 XP" after one right quick check). A review shows what was already earned.
- Under the bar, **every** part shows the caption `Lesson N · Part X of Y`, including parts with no title (quick checks).

### 1.7 Bottom buttons (all lesson parts)
- **Back + Next** on every part (P01–P12). Next is disabled on a quick check until answered and on a role-play (P11) until its chat is done. Back is the 52×52 square on the left; Next is the wide primary button.
- On the **last part** of the lesson, the primary button reads (`settings.lessonButtons`):
  - **"Finish & practice"** when the lesson has a quiz → S03.
  - **"Finish lesson"** when it has no quiz (Lesson 1) → S03 · Letters.

### 1.8 Quiz rules (from `settings`)
| Rule | Value |
|---|---|
| Pass mark | 80% of **scored** questions |
| XP | 10 per correct question · 20 per finished lesson · 5 per right quick check |
| Timer | 30 s on multiple_choice, listening, fill_blank, build_sentence, real_situation, match_pairs. Time out = wrong. |
| Not scored | speaking, open_answer (`scored: false`). Shown as "Practice" in review. |
| Result tiers | Perpekto! (100%) · Maayo gid! (≥80%) · Keep practicing (<80%) |
| Shuffle | Options (Q01, Q02, Q03, Q06, P06), build tiles (Q05) and the right column of match pairs (Q07) are **shuffled at runtime**. Most correct answers are `answer: 0` in the JSON, so never show options in JSON order. Track where the correct option lands. |

**XP is paid once.** A question, a quick check or a lesson pays XP only the first time it is answered right or finished. Repeating a lesson or retrying a quiz pays nothing again for those.

### 1.9 Unlocking
- `unlock.needs: "complete"` → the lesson unlocks when the lesson in `unlock.after` is finished (Lesson 1 → Lesson 2).
- `unlock.needs: "passQuiz"` → the lesson unlocks when that lesson's quiz is passed (≥80%).
- Levels: Intermediate unlocks when every Beginner quiz is passed; i01 is open at once, i02–i12 need the previous quiz passed. Advanced works the same way after every Intermediate quiz is passed (a01 open at once, a02–a10 need the previous quiz passed). A level with no lessons stays locked even after the level before it is finished; tapping its tab then says "Lessons coming soon".

### 1.10 Saving progress
- **Finished parts are saved. Only the part you are in is lost on Leave.** Home and S02 show the last finished part.
- Progress is saved on the phone first and synced to Firebase when online:
  - `users/{uid}/lessonProgress/{lessonId}`: `partsDone`, `completed`, `bestScore`, `passed`, `completedAt`.
  - `users/{uid}/quizAttempts/{attemptId}`: `lessonId`, `score`, `xpEarned`, `date`.
- Write once per finished part, lesson or quiz, never after every tap. Add XP with `FieldValue.increment()` (no transactions; they fail offline).
- A quiz attempt is saved only when it ends. Leaving a quiz drops the attempt.
- **When the last question ends** the attempt is saved: best score, passed (≥80% of scored questions, which unlocks the next lesson), XP once per question (only scored questions right for the first time), and the streak day.

### 1.11 Streak
- A day counts toward the streak when the user finishes at least one lesson part or quiz that day.
- Use the **phone's date**, because the app works offline. Missing a whole day resets the streak to 0.

### 1.12 Touch and contrast
- Every tappable thing is at least **48×48**. Make the tap area bigger than the visible icon when needed.
- Text contrast is at least 4.5:1 (3:1 for 18 px and up). Disabled items are exempt.

### 1.13 Pictures (`settings.images`)
| Picture | Size in the app | If missing |
|---|---|---|
| Lesson icon (`icon`) | 52×52 | firefly_reading |
| Lesson banner (`coverImage`) | **335×197**, cover-cropped | firefly_reading on a light violet fill |
| Word picture (`items[].image`) | 295×140 | **firefly_reading** |
| Culture picture (`parts[].image`) | 295×140 | firefly_reading |
| Real-situation picture (`image`) | 64×64 | firefly_reading |
- The fallback picture is always `firefly_reading`.
- Every Beginner, Intermediate and Advanced lesson has its icon, banner and culture picture (Nov 16); some words have `image: null` on purpose. The fallback keeps the app working if a picture is ever missing.

### 1.14 Lesson text language (Filipino lesson text)
- **Which text:** app language English → the English in the lesson files. Filipino **or Hiligaynon** → the Filipino lesson text. There is no Hiligaynon-language explanation text; the course compares Filipino with Hiligaynon, so a Hiligaynon-UI learner gets the Filipino explanations.
- **Where it lives:** one overlay per lesson file, next to it (`beginner_lessons.fil.json`, `intermediate_lessons.fil.json`, `advanced_lessons.fil.json`, `learning_settings.fil.json`): `{"strings": {"<key>": {"en": "<English source>", "fil": "<Filipino>"}}}`. A key is the nearest object `id` plus the path inside it (`b02.title`, `b02_q9.options[0]`, `b07_t1.rows[2][1]`, `i01.unit.title`). Code: `lib/learning/data/lesson_overlay.dart`.
- **What can change:** display text only (titles, objectives, prompts, questions, notes, tips, explanations, hints, settings, situations, labels, table headers and English cells, English options…). Never ids, answers, accepted answers, tiles, pairs, Hiligaynon, the existing Filipino glosses, `sentence` (Q03/Q12 check it), audio or pictures. Options keep their order, so answers (option positions) stay right.
- **Fallback:** a missing or empty entry, or one whose `en` no longer matches the English (stale), shows the English. If the translated files don't load at all, the whole module uses the English.
- **Switching language** swaps the text at once; progress is keyed by lesson ids, so nothing is lost.
- **Speaker names** in chats and passages can have a display name (`speakers.<Name>` in `learning_settings.fil.json`: You → Ikaw, Driver → Drayber…). The JSON name still decides the avatar and the learner's side.
- **Level names** in Filipino: Baguhan / Katamtaman / Abante; "Keep practicing" → "Magsanay pa". Learn search matches the shown (Filipino) title.
- **Markup:** `*…*` parts stay exactly as in the English, except a short reviewed list of rows where English inside `*…*` was translated (marked `"markupChanged": true`).
- **Tool:** `tools/lesson_strings.py` exports the English to CSV per level (`export`), imports filled CSVs with these checks (`import [--dry-run]`), checks the overlays (`check`) and lists exported texts with no Filipino yet (`missing`).

---

## 2. Screens (S)

### S01 · Learn (lesson list)
**Shows:** title "Learn", subtitle, a search field, level tabs, a hint line, and the lesson list.

- **Search:** filters the **current level tab** by lesson title as you type. Empty result → "No lessons found". **(Proposal)** for the empty text.
- **Level tabs:** Beginner / Intermediate / Advanced.
  - Locked tabs show a small lock badge on the top-right corner.
  - Tapping a locked tab does not switch the tab. It shows a short snackbar: "Finish Beginner to unlock". **(Proposal)**
  - No hint line under the tabs (removed Nov 7, Lance); locked tabs keep their lock badge and the snackbar on tap. Leaving the Learn tab resets S01 (search cleared, Beginner tab).
- **Units (Intermediate, Nov 11):** a header "Unit N · title" (Label/Large Bold, Primary; fil/hil "Yunit N · title", the title stays as in the JSON) above the first lesson of each unit, 12 px like the rows. Search keeps the header of each unit that still has a shown lesson. Beginner has no units.
- **Lesson row:** number box, icon (`icon`, 52×52; null → the Figma "Image Placeholder": grey tile, dashed border, X), title, one meta line, trailing icon. Locked number box colour = V6/Color/Lesson/Locked Badge #79718B on every level (Nov 11). The four states:

| State | Number box | Meta line | Trailing | Tap |
|---|---|---|---|---|
| Completed | green, white number, small check badge | `N parts • N min` | chevron | S02 (review the lesson) |
| Current | citrus, dark number, violet row outline | `N parts • N min` | chevron | S02 |
| Quiz pending (lesson finished, quiz not passed) | citrus, violet outline | "Take the quiz to unlock Lesson N+1" | quiz icon | S03 Lesson complete (to start the quiz) |
| Locked | grey, row greyed | "Pass Lesson N quiz to unlock" (Lesson 2: "Finish Lesson 1 to unlock") | lock | snackbar with the same message |

- Rows always keep their number (1, 2, 3…).

### S02 · Lesson Detail
**Shows:** top app bar ("Lesson N", Back → S01), banner (`coverImage`, **335×197**, cover-cropped, 16 px corners), title, chip `N parts • N min`, "In this lesson:" list (`objectives`, each with a green check), primary button, and a "Lesson progress" card with `X / N parts`.

- The body **scrolls**, so a long title or a fourth objective still fits on small phones.
- Three states (Figma: S02 · Lesson Detail, · In progress, · Completed):

| State | Under the title | Primary | Text button | Progress card |
|---|---|---|---|---|
| Not started | `N parts • N min` | **Start lesson** → part 1 | – | `0 / N parts` |
| In progress | `N parts • N min` | **Continue lesson** → first unfinished part | – | `X / N parts` |
| Completed | `N parts • N min` + chip **"Completed · Quiz X/Y"** (best quiz score) | **Review lesson** → part 1 | **Retake the quiz** → first question | hidden |

- "Review lesson" replays the parts without paying XP again. A finished lesson whose quiz isn't passed yet is "Quiz pending" on S01 and opens S03, not this screen.
- **Letters version (Lesson 1):** same layout with the alphabet banner. Its list shows the JSON objectives ("Know the 19 letters used in Hiligaynon"…), and the chip shows parts ("8 parts • 8 min").

### S03 · Lesson complete
**Shown after:** the primary button on the last part.

- firefly_celebrate, "Lesson complete!", a line naming the lesson, and two stat tiles: **+20 XP** and **N New words** (count of `items`).
- Primary **"Take the lesson quiz"** → the first quiz question.
- Text button **"Back to lessons"** → S01. The row then shows **Quiz pending**.
- Lesson XP is paid once, the first time the lesson is finished.
- **Letters version:** no quiz. Tiles **+20 XP** and **19 Letters**, plus a "Lesson 2 unlocked" chip. Primary **"Continue to Lesson 2"** → S02 for Lesson 2. "Back to lessons" → S01.

### S04 · Quiz result
**Shown after:** the last question's feedback sheet (or the last question itself if it is Q09).

- Score = correct scored questions / total scored questions.
- Shows the tier mascot and title, "You got X out of Y correct.", and two tiles: **XP earned** (`+N XP`, 10 × newly correct) and **Accuracy** (percent).

| Tier | Chip | Primary | Text button |
|---|---|---|---|
| Perpekto! (100%) | "Lesson N+1 unlocked" | Continue → S01 | Review answers → S05 · Passed |
| Maayo gid! (≥80%) | "Lesson N+1 unlocked" | Continue → S01 | Review answers → S05 · Passed |
| Keep practicing (<80%) | "Pass this quiz to unlock Lesson N+1" | Try again → first question | Review answers → S05 |

- Passing unlocks the next lesson immediately; its row becomes Current.
- **Last Beginner lesson (Lesson 13):** the chip reads **"Beginner complete!"** instead of "Lesson 14 unlocked". **(Proposal)**
- **Try again** restarts the quiz from question 1 with a fresh score and a new shuffle.

### S05 · Quiz review
**Shows:** "Review answers" top bar (Back → S04), "You got X out of Y correct.", and every question **in quiz order** with its real number.

- The list scrolls, with a soft fade at the bottom.
- Row types:
  - **Correct:** green check, the question, "Your answer: …" in green.
  - **Wrong:** red ✕, the question, "Your answer: …" in red, and "Correct answer: …". A timed-out question shows "Your answer: (time's up)".
  - **Practice** (speaking, open_answer): mic or note icon, the question, a "Practice" tag, and "Saved for practice only. No score."
- **Failed version:** primary "Try again" → first question. Text button "Back to lessons" → S01.
- **Passed version:** primary "Continue" → S01. Text button "Back to lessons" → S01. No Try again.

### S06 · Leave pop-up
**Shown when:** X is tapped (or system back on a quiz screen).

- Scrim, then a dialog with firefly_wrong, the title, the text, primary **"Keep going"** and text button **"Leave"**.
- **Lesson version:** title "Leave this lesson?", text **"You'll restart this part next time."**
- **Quiz version:** title "Leave the quiz?", text **"Your answers won't be saved."**
- **Keep going** closes the dialog and keeps the exact state (card, letter, answer, timer).
- **The quiz timer pauses while the dialog is open.**
- **Leave** → S01. Lesson: finished parts stay saved; the current part is dropped. Quiz: the attempt is dropped, with no score and no XP.

---

## 3. Lesson parts (P)
Every part uses the segmented bar (§1.6) and Back + Next (§1.7). Content sits in a scrollable body. Long lists scroll **inside their card** with a bottom fade, so the hint, tip and buttons stay visible.

### P01 · Key idea (`key_idea`)
- **Header:** icon tile (`icon`, a Material Symbols Rounded name, Filled) + `title`. Then `text` with markup.
- **Term cards** (`terms[]`, optional), one card each, in a scrolling list with a fade:
  - Top line: `hil` (bold italic violet) + a "Hiligaynon" chip.
  - Rows: **NOTE** = `note`; **FILIPINO** = `fil`. Hide a row if its field is missing.
  - `example` (Intermediate): under a divider in the same card, "Example", the Hiligaynon (italic violet) and the Filipino under it (hidden when `fil` is null).
- `text` null (some Intermediate parts) hides the text. `tip` (two Intermediate parts) shows as the teal tip card after the terms.
- No audio.

### P02 · Table (`table`)
- Header (icon + `title`), `text` with markup, then a table card.
- `columns[]` (2 to 4) form a light-violet header row. An empty column name (`""`) is an empty header cell. `rows[][]` follow, with a divider between rows.
- Cells in the columns listed in **`hilColumns`** are italic violet. Other cells are plain; a column named "Filipino" is grey.
- Columns share the width equally and text wraps. Never scroll sideways.
- No audio.

### P03 · Pattern (`pattern`)
- Header (icon + `title`), then `text` with markup.
- **Pattern card:**
  - One block per slot (`slots[]: label, hil`, 3 or 4 slots), with the small `label` above it (an empty label shows nothing) and "+" between blocks.
  - The slot with **`highlight: true`** (the link word: *ka, sang, sa, ang, ni, nga*) is violet with a glow outline. The other slots alternate citrus and lagoon.
  - `sentence` (Intermediate): the whole sentence with markup, centred under the blocks.
  - Under that: `= fil`.
- **More examples** (`examples[]: hil, fil`): text-only rows, full width, Hiligaynon italic violet with Filipino under it.
- No audio.

### P04 · Words / Learn card (`words`)
**One part = several cards** (`itemIds[] → items[]`).

- Card counter **"i / n"** on the card's top-right. The segmented bar does not move between cards.
- **Card contents:**
  - "New word" chip.
  - Picture (`image`, 295×140). **If `image` is null or the file is missing, show firefly_reading.**
  - "Hiligaynon" label, the word `hil`, the meaning `fil`.
  - If `alt` exists, a small line "Also said: …" (another Hiligaynon way to say it, never the Filipino meaning).
  - Audio button and slow audio button, both playing `audio` (slow at 0.75×). Hidden while the clip isn't recorded (§1.4).
- **Example box** (green, `example.hil` + `example.fil`): text only. **Shown whenever `example` exists, hidden when it is null.**
- The picture rule and the example rule are **independent**. 35 words have no picture but do have an example, and they show both firefly_reading and the Example box. (Figma variants: Default, No image, Number.)
- **Next:** next card. On the last card → next part.
- **Back:** previous card. On card 1 → previous part.

### P05 · Letters & sounds (`letters`)
**One part = 19 letters.**

- Header "Letters & sounds" with "X / 19 seen", plus the instruction.
- **Letter carousel:** only the current card is shown, full width; no peek of the next card. Swipe left/right = Next/Back.
  - Letter card: big letter tile, "CALLED", `name`, `soundHint` (text, no icon).
  - Example box: the example word and its Filipino meaning, plus **the only speaker button**. It plays the example word only ("aga"), not the letter name.
- **Progress bar** `X / 19` under the carousel.
- **Letter grid:** all 19 chips, 7 per row. States: Current (violet), Seen (light violet), Not seen (outline). Tapping a chip jumps to that letter and marks it Seen.
- **Back:** previous letter. On letter 1 → previous part. Enabled.
- **Next:** next letter. On letter 19 → next part. The button stays "Next".

### P06 · Quick check (`quick_check`)
- "Quick check · practice" chip, the question (`prompt`), the line "No timer, no score. Just practice.", and option cards (`options`, shuffled).
- **Tapping an option checks it at once.** There is no Check button and no timer. One try only.
  - **Right:** the option turns green and **F01** opens: "Correct!", "+5 XP" (first time only) and the `explain` line.
  - **Wrong:** the option turns red, the right one turns green, and **F02** opens with the correct answer and the `explain` line. No XP.
- **Continue** on the sheet → next part. Back still works before answering.
- Not counted in the quiz score.

### P07 · Dialogue (`dialogue`)
- Header (icon + `title`), then the `setting` line.
- Toolbar: a **"Show all Filipino"** switch. There is no Play all.
- Hint: "Read each line aloud, then tap it to check the Filipino."
- **Chat bubbles** (`lines[]: speaker, hil, fil`):
  - **Ana** is on the right, in violet with white text. **Every other speaker** is on the left, in light violet.
  - The speaker's **name** shows in small text above each bubble.
  - Each bubble has a round avatar (36×36) from `settings.avatars`:
    - speaker "Ana" → `avatar-ana`
    - speaker starting with "Manang" → `avatar-manang`
    - anyone else (Ben, Driver, Seller, Man) → `avatar-neighbor`
  - **Tap a bubble** to show or hide its `fil` under the Hiligaynon. The hint inside changes between "Tap to see Filipino" and "Tap to hide Filipino".
  - **The switch** shows or hides Filipino on every bubble. Tapping a single bubble afterwards still toggles that one.
- **Ana and "You"** (i08) are the learner's side: right, violet, Ana's avatar (`settings.avatars` has "You": avatar-ana).
- **Audio (Intermediate, Nov 11):** a dialogue whose lines have `audio` gets a "Play conversation" button (plays every line clip in order) and a slow button (same clips at 0.75×).
  - `listening: true` (Figma "P07 · Listening mode" / "After playing"): grey placeholder bubbles (names and avatars stay), hint "Listen first, then check the text.", a "Show text" link; after the conversation has played once (or Show text) the lines show, the button reads "Play again", the link "Hide text", the hint "Tap a line to see the Filipino." No Show all switch in listening mode.
  - While any line clip isn't in the app: no buttons, the text shows, and a small "Audio coming soon" line.
  - Beginner dialogues have no clips: text only, as before.
- **Tip card** (teal, lightbulb): `tip` with markup, at the end of the chat.
- Lesson 13 has three dialogue parts in a row; each is its own part.

### P08 · Reading (`reading`)
- Header (icon + `title`), the "Show all Filipino" switch, and the sentence card (`lines[]: hil, fil`).
- **Each sentence is its own full-width row**, at least 48 px tall. Tap a row to show or hide its Filipino underneath; a shown row gets a light tint.
- The list scrolls inside its card with a fade when long. The hint and tip stay visible.
- Hint: "Read each sentence aloud, then tap it to check the Filipino."
- Tip card as in P07. Text only, no audio.
- Every lesson has at least one reading.

### P09 · Filipino bridge & mistakes (`bridge_mistakes`)
- Section **"Filipino ⇄ Hiligaynon"** (swap_horiz): a card with a pink left bar and one bullet per `bridge[]` item, with markup.
- Section **"Common mistakes"**: one row per `mistakes[]` item:
  - ✕ `wrong` in red, struck through.
  - ✓ `right` in green, bold.
  - `why` in grey under them.
- Scrolls with a fade. No audio.

### P10 · Culture note (`culture_note`)
- "Did you know?" chip, picture (`image`, 295×140; falls back to firefly_reading), "Culture note" label (`title`), and `text` with markup.
- Usually the last part, so the primary button follows §1.7. If it is not the last part, the button reads "Next".

### P11 · Role-play (`role_play`) — Intermediate, Figma "P11 · Part · Role-play · Choose / Right choice / Not quite / Done"
- Header (icon + `title`), `setting`, then "Choose your reply." (hidden once the chat is done).
- The chat shows the other speaker's turns (`turns[]`: speaker, hil, fil) as bubbles with their Filipino under the Hiligaynon (no Filipino line when `fil` is null). `fast: true` adds the citrus "Talking fast" chip after the name; `cue` shows above that turn's choices as a lagoon Info strip (italic). Figma's "Quoted line" variant isn't built (no JSON field).
- **Choose:** the current turn's `choices` as reply cards (Hiligaynon + small Filipino), shuffled.
  - **Wrong:** the card turns red with ✕ and "Not quite: {hint}. Try another reply." shows under the cards (the hint stays in English). No penalty; try again.
  - **Right:** Ana's reply bubble is added and the next turn appears; the chosen card shows alone in green for 0.9 s, then the next turn's choices (Figma "Right choice").
  - A turn may offer a single reply (the correct one) to tap.
- **Done:** after the last turn's right reply, or when the closing line (a turn with no choices) has appeared: the whole chat (only the right replies), the `tip` card, and Next enabled. Before that Next is disabled.
- Going Back and returning keeps the chat. Text only, no audio, no XP.

### P12 · Verb forms (`verb_forms`) — Intermediate, Figma "P12 · Part · Verb forms · kaon / inom"
- Header (icon + `title`), `text` with markup, then "Tap a root word to see how its forms change."
- **Root chips** (`roots[]`: root + small `fil`); the selected one is Primary Container with a violet border. The first root is selected at the start.
- **Table:** a "When" column with one row per `columns[]` label (Done / Ongoing / every day / Not yet), then:
  - one "Form" column with `forms`, or, when the root has `doerForms`, "Who does it" (`doerForms`) and "What it happens to" (`forms`).
  - The part that changes is violet: the start when the form ends with the root (nag-, naga-, mag-, gin-, gina-), otherwise the final "-on" (kaunon, lutuon).
- **Example card:** "Example", `example.hil` (italic violet), `example.fil`.
- `note` with markup in the teal tip card at the end. No audio.

---

### P13 · Idiom cards (`idiom_cards`) — Advanced, Figma "P13 · Part · Idiom card · Default / Careful / Long card"
- No title. One card at a time, "n / N" at the top right of the card; Back/Next move between cards like P04 (the segmented bar doesn't move).
- Card: the idiom (Hiligaynon ExtraBold Italic, violet) with an audio button (hidden until the clip is recorded); Word for word (`literal`), What it really means (`means`, semibold), Tone (chip: amber Warning when `careful`, lagoon otherwise), Who you can say it to (`sayTo`), and the `warning` line in an amber banner when there is one.
- Under the card, the teal Example box: the Hiligaynon lines (semibold), then the Filipino lines (muted).

### P14 · Formal vs casual (`register_pairs`) — Advanced, Figma "P14 · Part · Formal vs casual" (+ Wrong on purpose, Long text)
- One situation per step, "n / N" at the right of the "Lesson N · Part x of y" line; Back/Next between situations.
- Header: the part icon + the situation `title`. Under it the PART `title` (what kind of pair it is; Lance, Nov 12).
- Two cards: a violet label chip (`leftLabel` / `rightLabel`), the Hiligaynon (italic violet) and the Filipino.
- `leftWrongOnPurpose`: the left card is grey with a red ✗ and its label, the line in Neutral Strong, and `left.note` (with markup) in small text instead of the Filipino.
- "What changed" + lagoon chips (`changes`). No audio buttons (no clips planned).

### Advanced extras in older templates
- P11 role-play: `turns[].quote` in italics under the speaker's bubble (44 in, Figma "Quoted line"); `choices[].note` as small grey text above that reply.
- P08 reading: optional `text` intro line under the header.
- P03 pattern: up to 5 slots (the blocks shrink to fit).

## 4. Quiz questions (Q)
**Shared quiz shell:**
- **Quiz top bar:** X (→ S06 Leave quiz), a smooth progress bar, the step `n / N`, and a **timer chip** on timed types.
- **Question meta row:** a question-type chip and an XP chip "+10 XP" (hidden on unscored types).
- **Primary button** at the bottom (Check / Submit / Continue):
  - **Check** is disabled until an answer is given.
  - After Check: **F01** if right, **F02** if wrong. **Continue** on the sheet → next question. The last question → S04.
- **Timer** (30 s, timed types): counts down. At 0 the input locks and **F03 Time's up** opens; it counts as wrong. The timer pauses while S06 or any sheet is open.
- No Back. Answers can't be changed after Check.
- **Typed answers** (Q04, Q08) are compared with every entry in `accepted[]`, ignoring capital letters, spaces at the ends and `. , ! ?` (`_meta.fieldGuide.accepted`).

| ID | Type | Behaviour |
|---|---|---|
| Q01 | Multiple choice | `prompt` + 3–4 option cards (shuffled). Tap selects one (violet outline); Check reveals it (green / red). |
| Q02 | Listening | Big play button plays `audio` (can replay; slow button plays at 0.75×). Options are text (`optionKind: "text"`), shuffled. Tap to select, then Check. |
| Q03 | Fill in the blank | `sentence` with "___" and its `meaning` (Filipino) under it. `options` as **option cards** (shuffled, as in Figma). The chosen word also fills the blank. Check. |
| Q04 | Type the answer | Label from `direction` ("Filipino" source → "Type this in Hiligaynon"), the `text`, and a text field. No timer. |
| Q05 | Build the sentence | The Filipino `prompt`, then word tiles (`tiles`, shuffled; one extra tile is a distractor). Tap a tile to move it into the answer line; tap it there to send it back. Check compares with `answer` in order. |
| Q06 | Real situation | `situation` text + `image` (64×64; firefly_reading if null). `options` (shuffled); tap, then Check. |
| Q07 | Match pairs | Hiligaynon on the left, Filipino on the right (right column shuffled). Tap one on each side: a right pair turns green and locks; a wrong pair flashes red and resets. **Check** is enabled when every pair is matched. **The question counts as right only if there were no wrong taps.** F02 lists the correct pairs. |
| Q08 | Dictation | Play `audio` (one word or phrase), then type what you hear. Optional `wordBank` chips insert words. No timer. F02 plays the same clip (`answerAudio` = `audio`). |
| Q09 | Speaking | Not scored, no XP. Shows `text` + `meaning`. "Native speaker" plays `audio`; the mic records; "You" plays the recording back. **Continue** is enabled after one recording and goes straight on, with no sheet. If microphone permission is refused or unavailable, show "Mic not available. You can skip this one." and enable Continue. **Pronunciation feedback** (when `settings.pronunciationFeedback.enabled` and the phrase has a clip): see below. |
| Q10 | Open answer | Not scored. `prompt`, `hint` and a text field with an `N / maxChars` counter. **Submit** (enabled when the field isn't empty) → **F04** with `modelAnswer`. Any answer is accepted. |
| Q11 | Read & answer | Intermediate. Scored, **no timer**. `mode: read`: chip "Reading"; the passage (`passagePart`, a reading or dialogue in the same lesson; Hiligaynon only, dialogue lines as "Speaker: line") in a white card at most 200 high (scrolls with a fade), then the question, hint and shuffled options; Check. `mode: listen`: chip "Listening"; 88 play + 48 slow buttons play the passage's line clips in order, "Listen to the conversation"; after Check a "Show transcript" link shows the passage. Clips missing: the passage shows as in read mode with "Audio coming soon". S05 shows Q11 like Q01. |
| Q12 | Spot the mistake | Advanced. Scored, **no timer**. Chip "Spot the mistake" (citrus); title `prompt`, hint "One word in this sentence is wrong."; the `tiles` wrap (punctuation stays on its tile); "Meaning in Filipino" card with `meaning`. Tap a tile (Selected), then Check. Right = tapping `tiles[wrongIndex]`: that tile shows `fix` in green. Wrong: the real mistake turns red and struck through with a green `fix` chip under it, the tapped tile goes grey; F02 shows `fix` (may be two words). S05: "Tap the wrong word: {sentence}", your tapped word, "Correct: {wrong} → {fix}". |
| Q13 | Passage set | Advanced. Three questions in a row on one reading/dialogue (`setIndex` 1–3), each scored on its own, **no timer**; the quiz position stays (11 / 15 …). Works like Q11 plus a small "Question n of 3" label. From question 2 a read passage folds into a "Show story" bar (opens to the passage, "Hide story"). Listen mode keeps its play buttons on all three; without clips it shows the conversation as text with "Audio coming soon" (folded from question 2 too). S05: "Story question n of 3: …". |

**Missing clips in the quiz (Nov 11, while the Intermediate clips aren't recorded):** the question still works, never skipped.
- Q02: `audioText` (the clip's words) in a Hiligaynon prompt card in place of the play buttons, with "Audio coming soon".
- Q08: the sentence to write (`accepted[0]`) the same way.
- Q09: the **No clip** state (below).
- Q10 with `transcript`: the transcript in the prompt card (body text when long) above the answer box.
- Q11 listen: the conversation as text (see Q11).
- Beginner has every clip, so nothing changes there.

**Q09 pronunciation feedback** (practice only: not scored, no XP; it measures how *similar* the sound is, not whether the word is "correct"):
- After Stop: **Checking…** (spinner button, Continue disabled). The recording is compared with the native clip in the background: MFCC features + DTW, with silence trimmed on both sides by their own loudness. The native clips are decoded on the phone (Android MediaCodec), fully offline.
- Score = the **relative** score: distance to this phrase's clip ÷ the average distance to the other Beginner Q09 clips (lower = closer). **Very close** ≤ 0.82, **Almost** ≤ 0.95, otherwise **Try again** (`settings.pronunciationFeedback`: `score`, `veryClose`, `almost`; set from team test recordings).
- Result card (Figma Q09 / Result / Very close · Almost · Try again) + Play mine | Play native + **Record again** (a new recording replaces the old one).
- **Couldn't hear:** shorter than `minSpeechMs` (250) or quieter than `minLevelDb` (−40 dBFS) → "We couldn't hear you" + Record again; Continue stays enabled.
- **No clip** (Intermediate Q09 until recorded): Native speaker shown disabled + "Audio coming soon", the mic, "Recorded · tap to record again", Play mine, "Comparison coming soon"; no check.
- Flag off, or a clip that can't be decoded: Q09 works as before, with no feedback.

**Voice recordings (Q09):** kept in memory on the phone for playback and the review screen only, and deleted when the quiz ends. A recording stops on its own after **15 seconds**. They are **never saved to storage or uploaded to Firebase**.

---

## 5. Feedback sheets (F)
Bottom sheets over a dimmed screen. Each has the firefly, a title, a detail line and a full-width **Continue** button. Tapping the scrim does not close the sheet.

Mascots (as in Figma): F01 **firefly_celebrate**, F02 and F03 **firefly_wrong**, F04 **firefly_reading**.

| ID | When | Content |
|---|---|---|
| F01 Correct | Right answer (also P06) | Green. "Correct!", "+10 XP" ("+5 XP" in P06; hidden if already paid), optional `explain`. |
| F02 Wrong | Wrong answer (also P06) | Red. "Not quite", "Correct answer:" + the answer, and an **audio button only if `answerAudio` is set**. For Q07 it lists the correct pairs. |
| F03 Time's up | Timer reached 0 | Coral (dark plum button text). "Time's up!", "Correct answer:" + the answer, same audio rule as F02. Counts as wrong. |
| F04 Sample answer | After Q10 Submit | Lavender. "Sample answer:" + `modelAnswer`; for a Q10 about a clip (i10), "Transcript" + `transcript` under it. No XP, no score. |

Long answers wrap to two lines. The audio icon, when shown, sits at the end of the answer line.

---

## 6. Home · Continue card
- Shows the current lesson ("Lesson 2: Greetings & Courtesy"), its level chip, a progress bar and **"Part X of Y"** (the next unfinished part).
- **Continue lesson** → that lesson at the first unfinished part. If no lesson has been started → the first unlocked lesson's S02.
- The stat chips show the streak (§1.11), the number of lessons completed, and total XP.

---

## 7. Decisions (were open questions)
1. **Saving progress:** finished parts are saved; only the current part is lost on Leave (§1.10). Leave lesson text: "You'll restart this part next time."
2. **Search scope:** current level tab only.
3. **Pattern highlight:** `highlight: true` on the link-word slot in the JSON.
4. **Match pairs scoring:** right only with no wrong taps.
5. **XP on retry:** never paid twice (§1.8).
6. **Letter 19:** Next goes to the next part and stays "Next". The old Figma note saying "Finish" is outdated.

8. **Lesson XP chip:** XP this lesson has paid so far, across all runs; a review shows what was already earned (§1.6).
9. **Q09 recordings** stop on their own after 15 seconds; kept in memory only, never saved or uploaded (§4).
10. **Quiz result** is saved when the last question ends (best score, passed, unlock, XP once per question, streak day). Leave drops the attempt (§1.10).

### States described here but without their own Figma frame
Build them from the text above:
- Banner fallback on S02: firefly_reading centred on a light violet fill, same 335×197 slot.
- Q09 "Mic not available. You can skip this one." with Continue enabled.
- S04 chip "Beginner complete!" after the Lesson 13 quiz.
