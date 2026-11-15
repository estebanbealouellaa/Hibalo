# Hibalo – Translation Model, Round 2: Summary and Hand-off

*Last updated: 1 November 2026 (with the phrase list, number words, punctuation rule and quote fix). Written for Lance and for whoever codes the Flutter translation module next (another Claude session or a teammate).*

**Read this first**
- **Part A (sections 1–8)** is what was done in Round 2 and the results.
- **Part B (sections 9–16)** is the spec for the **app's translation module**. If you are coding the module, start at section 9.
- Project rule: ask Lance before creating, changing or deleting any file in Drive or the repo.

---

# PART A — What was done in Round 2

## 1. Project context (short)

- **Hibalo**: Flutter + Firebase mobile app for **Hiligaynon ↔ Filipino** translation and learning (PUP capstone). Users are Hiligaynon speakers and non-speakers in Sta. Maria, Sto. Tomas City, Batangas.
- **Translation runs on the phone, offline.** It is a small **MarianMT** model (the "student") exported to **ONNX int8**.
- The student is trained by **distillation**: a big model (the "teacher", **MADLAD-400-3B + LoRA**) translates about 435k single-language lines, and the student learns from those translations plus human data.
- **Spoken Hiligaynon output** (separate from translation): offline **MMS-TTS (VITS) v4** voice, speaker HIL_0619 from the PLD dataset (UP-DSP), seed 7, about 59 MB ONNX. Lesson, alphabet and pronunciation audio are native-speaker recordings.
- **Two paper versions:** an **NLP version** (names AI/NLP; for international submission) and a **discrete version** (plain language, no technology names; for the school). Always confirm which one before editing.

## 2. Pipeline and notebooks

All notebooks run on **Kaggle**. The final round-2 versions are in `hibalo_round2_notebooks.zip` (to be placed in Drive `Hibalo/notebooks/round2/`).

| Step | Notebook | Hardware | What it does | Status |
|---|---|---|---|---|
| 0 | `hibalo-r2-0-data-prep-v4` | Colab/CPU | Builds the teacher mix, everyday dev/test, student extra pairs and spelling-variant rows → `processed/round2_v2/` (Kaggle dataset `hibalo-r2-data`) | ✅ |
| A3 | `hibalo-r2-A3-teacher-run3` | GPU | Teacher LoRA run 3 (continues run 2, LR 1e-4) | ✅ |
| B3 | `hibalo-r2-B3-teacher-ct2-run3` | GPU | Merge + CTranslate2 int8 + scores, run 3 vs run 2 | ✅ run 3 won |
| A4 | `hibalo-r2-A4-teacher-run4` | GPU | Teacher LoRA run 4, with all synthetic sets (everyday, hard, verbs) | ✅ |
| B4 | `hibalo-r2-B4-teacher-ct2-run4` | GPU | CT2 + scores, run 4 vs run 3 | ✅ **run 4 used** |
| C1 / C2 | `hibalo-r2-C1-distill-part1`, `…-C2-distill-part2` | GPU T4×2 | Run-4 teacher translates 435,693 mono lines (two halves), saves a **confidence score** per line | ✅ |
| D1 / D2 | `hibalo-r2-D1-student-8x4`, `…-D2-student-8x8` | GPU T4×2 | Cleans the teacher lines, trains student v2 at two sizes | ✅ **8×8 chosen** |
| E | `hibalo-r2-E-export` | CPU | ONNX int8 export of both students, quality and speed checks, Dart-reference decoding loop | ✅ |

## 3. Data work

### 3.1 One spelling for Hiligaynon
- Lance chose: **siya / niya** (not sia / nia), **kwarta** (not kuwarta), and so on. All datasets were re-cleaned to one spelling.
- Maps:
  - `hil_spelling_map_v1.tsv`: 1,408 entries, used for the cleanup.
  - `hil_spelling_map_v2.tsv`: **807 strong entries** plus manual fixes (bwisit, magabagyo, makasweldo, meryenda). Weak mappings were removed (standard form seen fewer than 10 times, or close in count to the variant). **Use v2 in the app.**
- **Old-spelling rows** (`r2_hil_variants.tsv`, 3,000 rows): the same sentence with the old spelling on the Hiligaynon side, trained **Hiligaynon → Filipino only**. Users who type "sia" or "kuwarta" still get a correct translation, but the model never writes the old spelling.
- Cleaned dataset versions: `teammate_pairs_clean_v3`, `motus_v3`, `kaufmann_v13`, `bible_v5_train/dev/test`, `mono_hil_madlad_v5`, `mono_hil_extra_v3`, `mono_hil_hiligayner_v3`, `mono_fil_madlad_v4` (Filipino; no spelling change), `r2_everyday_test_v2`.

### 3.2 AI-written (synthetic) sentence pairs

All three sets were audited by ChatGPT, then re-audited row by row by Claude. Fixes are in `synthetic_round2_audit_log.tsv` (111 rows).

| File | Rows | What |
|---|---|---|
| `synthetic_ai_v2.tsv` | 1,037 | Everyday sentences, including curse words and slang at several levels |
| `synthetic_hard_ai_v1.tsv` | 642 | Longer, harder sentences with more context |
| `synthetic_verbs_ai_v1.tsv` | 1,740 | Dictionary verbs with different prefixes, 2 tabs (907 + 833), about 3 sentences per real verb form |

- **Examples of fixes:**
  - lubong vs lulubngan (grave)
  - panuktok, not tutok (knock)
  - madali = quick, mahapos = easy
  - Tagalog words replaced: kadugo, pumayag, itapon, nabuhos, kapit, kandungan, pultahan, magulo
- **Share:** about 12% of the teacher's training mix, and each synthetic row is used once. In the student data they are weighted ×2.
- **The papers must say that AI-written synthetic data was used**, and that it was audited without a native-speaker check.

### 3.3 Leak protection
- Everyday test (150 sentences), everyday dev (50), Bible v5 test (427) and Bible v5 dev (255) are **never trained on**.
- The check uses exact matches, shared 6-word runs, and lines that contain a test sentence. It ran in Notebook 0, in C1/C2 (425 Hiligaynon and 26 Filipino mono lines removed), and again in D.

### 3.4 Quote bug (`\"`): fixed
- About 12% of lines in the cleaned **Bible v5** files, a few teammate and Kaufmann rows, and the old-spelling rows contained `\"` or `""` (a leftover from how the files were saved) instead of `"`.
- Notebooks D and E already undid this when reading, so the student never learned backslashes. Teacher runs 3 and 4 trained on it, with only a small effect.
- **Fixed copies were made on 1 Nov 2026.** The old files were not changed or deleted. They were moved to Drive `Hibalo/data/archive/Used in Round 2 Student - before quote fix/` (7 files), and the fixed copies go in `Hibalo/data/processed/`.

| Old file | Fixed copy | Cells fixed |
|---|---|---|
| bible_v5_train / dev / test | `bible_v6_train/dev/test.tsv` | 5,489 / 73 / 131 |
| teammate_pairs_clean_v3 | `teammate_pairs_clean_v4.tsv` | 32 |
| kaufmann_v13_training_clean | `kaufmann_v14_training_clean.tsv` | 35 |
| hil_spelling_variants_v1 | `hil_spelling_variants_v2.tsv` | 330 |
| r2_everyday_test_v2 | `r2_everyday_test_v3.tsv` | 4 |

- Every change is listed in `quote_fix_log.tsv`. After the fix, no backslashes are left, and the rows and columns are unchanged.
- **The round-2 results above used the old files.** Use the fixed copies from Round 3 on, and update the notebooks' file names when you do. The mono `.txt` files were not affected.

## 4. Teacher results (MADLAD-400-3B + LoRA r16/α32)

chrF++ (word_order=2), beam 4. Pairs are **Hil→Fil / Fil→Hil**.

| Test | Run 3 | **Run 4 (used)** |
|---|---|---|
| Everyday (150) | 71.3 / 61.4 | **71.9 / 62.8** |
| Tatoeba (26) | 64.2 / 58.4 | **70.0 / 61.6** |
| Bible v5 test (427) | 63.3 / 65.6 | **63.8 / 65.6** |

Run 4 adapter: Drive `Hibalo/models/round2/final_adapter/` (confirmed from A4).

## 5. Distillation (C1/C2) and cleaning (in D)

**C1/C2:**
- 435,693 lines translated (360,317 Hiligaynon + 75,827 Filipino after dedupe).
- **413,118 flagged `ok`** (part 1: 93.0%, part 2: 96.6%). Took 2.8 h + 2.4 h.
- The confidence score is the average log-probability per token (closer to 0 = surer). Median: Hil-source −0.246, Fil-source −0.363.

**Cleaning in D (per direction):**

| Rule | Dropped |
|---|---|
| Repeated word with "at/kag/o" in between ("mahirap at mahirap") | 2,831 |
| Least-sure 10% (cut −0.442 Hil, −0.612 Fil) | 40,601 |
| Dictionary check inside the least-sure 25% (≥ half of the checked dictionary words have no match in the output) | 34,642 |
| "₱500,000" → "P500,000" lines **kept again** | +281 |
| **Kept** | **335,325 of 413,399 (81%)** |

Hand-checked samples: about 9 of 10 repeat drops, about 7 of 10 low-score drops and about 6 of 10 dictionary drops were real errors. The dictionary check alone is weak (it flags 15–35% of correct Bible lines), which is why it only applies to low-confidence lines.

## 6. Student v2 training data (D)

921,010 training examples, both directions.

| Source | Examples |
|---|---|
| Teacher (real Hiligaynon source) | 547,734 |
| Teacher (real Filipino source) | 118,916 |
| Bible v5 ×2 | 90,704 |
| Kaufmann sentences ×2 / phrases ×2 / words ×1 | 63,316 / 2,752 / 25,966 |
| Motus sentences ×4 / words ×2 | 10,424 / 11,184 |
| Teammate sentences ×6 / phrases ×6 / words ×3 | 3,540 / 6,336 / 8,232 |
| Synthetic everyday / hard / verbs ×2 | 4,136 / 2,568 / 6,960 |
| Short commands, extra ×2 ("Kuhaa ang libro." → "Kunin mo ang libro.") | 12,324 |
| Old-spelling rows ×2 (Hil→Fil only) | 6,000 |

**Model and training settings:**
- MarianMT from scratch: d_model 512, 8 encoder layers, FFN 2048, 8 heads, shared 16k SentencePiece vocab with `>>hil<<`, `>>fil<<`, `<n1>`…`<n9>`.
- fp16, LR 5e-4, inverse-sqrt schedule, 4k warmup, label smoothing 0.1, batch 64 per GPU.
- Dev set checked every 4k steps; training stops after 5 checks without improvement or at 9.3 h; the best checkpoint is kept.

## 7. Student v2 results

chrF++, beam 4, PyTorch. Pairs are **Hil→Fil / Fil→Hil**.

| Test | Student v1 | v2 **8×4** | v2 **8×8 (chosen)** | Teacher run 4 |
|---|---|---|---|---|
| Everyday (150) | – | 73.8 / 64.9 | **75.3 / 64.9** | 71.9 / 62.8 |
| Tatoeba (26) | 66.7 / 60.2 | 67.2 / 64.1 | **71.4** / 62.4 | 70.0 / 61.6 |
| Bible v5 test (427) | – | 66.3 / 68.8 | **67.3 / 70.4** | 63.8 / 65.6 |
| Average of 6 | – | 67.5 | **68.6** | 66.0 |
| Parameters | 50M | 50.5M | 67.3M | 3B |
| Training | – | 5.6 h, best at step 40k (early stop) | 9.3 h (time limit), best at step 60k | – |

- **The student beats the teacher on 5 of 6 tests.** Likely reasons: the cleaning, the extra weight on human data, and the full Bible ×2 (the teacher saw only 11k Bible pairs).
- **Sentence by sentence on the everyday test:**
  - 8×4 vs teacher: hil→fil 44 better / 33 worse; fil→hil 56 / 35.
  - 8×8 vs 8×4: hil→fil 29 better / 21 worse; fil→hil 37 / 28.
  - Exact matches, hil→fil: 8×8 64, 8×4 56, teacher 52.

## 8. Phone export (E): ONNX int8 with decoder cache

| | 8×4 | **8×8 (use this)** |
|---|---|---|
| Total folder size | 61.8 MB | **79.2 MB** (encoder 33.95 + merged decoder 43.31) |
| Everyday chrF++, int8 beam 4 | 74.0 / 64.7 | **75.1 / 64.9** |
| Everyday chrF++, int8 **greedy** | 72.2 / 62.4 | **74.1 / 63.1** |
| Bible-150 chrF++, int8 beam 4 | 71.0 / 73.9 | 71.5 / 74.9 |
| Kaggle CPU, 1 thread, greedy, everyday sentence | 0.080 s | **0.101 s** |
| Kaggle CPU, 1 thread, beam 4, everyday sentence | 0.170 s | 0.206 s |
| Kaggle CPU, 1 thread, greedy, long sentence | 0.305 s | 0.386 s |
| Kaggle CPU, 1 thread, beam 4, long sentence | 0.573 s | 0.714 s |
| Manual decoding loop = optimum greedy | 30/30 | **30/30** |

- int8 lost almost nothing compared with fp32 (within 0.7 points).
- **8×8 greedy ≈ 8×4 beam 4 in quality, and faster.**
- On Kaggle, 4 threads were *slower* than 1 because the CPU is shared. On phones, test 1 vs 2 threads.
- Expect a phone to be 2–4× slower than Kaggle. The target is under 3 s per sentence.

---

# PART B — Spec for the app's translation module

## 9. Files to ship

Drive: `Hibalo/models/round2/hibalo_student_v2_8x8_onnx/`. Backup for very slow phones: `hibalo_student_v2_8x4_onnx/` (same code, `DEC_LAYERS=4`).

| File | Needed in app? | Purpose |
|---|---|---|
| `encoder_model.onnx` | **yes** | Encoder (int8) |
| `decoder_model_merged.onnx` | **yes** | Decoder with cache built in (int8) |
| `spm.model` | **yes** | SentencePiece unigram tokenizer. **New in v2: do not reuse v1's `spm.model`.** |
| `config.json` | read once | `d_model=512`, `decoder_layers=8`, `decoder_attention_heads=8` |
| `onnx_io.json` | dev reference | Exact input/output names and shapes |
| `text_rules.py`, `number_tags.py` | dev reference | Python reference for the cleanup and number rules; port them to Dart |
| `generation_config.json`, `vocab.json`, `source.spm`, `target.spm`, `tokenizer_config.json`, `special_tokens_map.json`, `export_report.json` | no | Python/HF only (`source.spm` and `target.spm` are copies of `spm.model`) |

Also ship (from `hibalo_app_text_rules_v1.zip`):
- `hil_spelling_map_v2.tsv`: 807 rows, columns `variant`, `standard`
- `hibalo_phrase_list_v1.tsv`: short-phrase list (section 12)
- Python references to port to Dart, each with built-in tests (`python3 file.py`):
  - `phrase_lookup.py`
  - `postprocess.py`
  - `hil_numbers.py` (for the TTS only)

**Licenses and credits to show in the app or paper:**
- MMS-TTS is CC BY-NC 4.0 (non-commercial).
- Credit the PLD dataset to UP-DSP.
- The translation model was trained by the team from scratch. Data sources: teammate pairs, Kaufmann dictionary, Motus, Bible, MADLAD-400 text, and AI-written synthetic pairs.

## 10. Translation pipeline (what the Dart code must do)

```
user text
 → (A) short-phrase lookup (phrase_lookup.py, section 12): if found, skip to (J) with the stored translation
 → (B) normalize (text_rules)
 → (C) if the source is Hiligaynon: spelling map v2, word by word
 → (D) number protect (number_tags) → tagged text + list of numbers
 → (E) SentencePiece encode → ids
 → (F) source ids = [TAG] + ids (max 126) + [1]
 → (G) encoder → decoder loop (greedy, or beam 4 for short input)
 → (H) SentencePiece decode (drop ids 0, 1, 2)
 → (I) number restore
 → (J) match_style(input, output): copy the end ? ! . and the first capital (postprocess.py)
 → output text
 → (K) for the voice only, when the output is Hiligaynon: numbers_to_words() (hil_numbers.py) → TTS
```

**(J) match_style, tested.** It changed 14 of 150 everyday outputs (for example "tagpila ini?" → "Tagpila ini?") and did not change any chrF++ score.
- If the input ends with `? ! .` and the output has no end mark, the input's mark is added.
- A question stays a question: `.` is changed to `?`.
- If the input starts with a capital, the output's first letter is capitalized.
- If the input starts lowercase, nothing is changed.

### (B) normalize: port exactly

```python
def normalize(t):
    t = unicodedata.normalize('NFD', str(t))
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')   # remove accent marks
    t = t.replace('’', "'").replace('‘', "'").replace('“', '"').replace('”', '"')
    return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', t)).strip()
```

Dart: use NFD decomposition (for example, the `unorm_dart` package), remove combining marks (U+0300–U+036F is enough for this data), map curly quotes to straight ones, collapse whitespace, trim.

### (C) Spelling map (Hiligaynon input only)
- Replace whole words only (match on lowercase, keep the first letter's case). For example, `Sia` → `Siya`.
- This is extra safety. The model already handles common variants, because of the old-spelling rows.

### (D)/(I) Numbers: port exactly

```python
NUM_RE = re.compile(r'(?<![\w.,:])\d+(?:[.,:]\d+)*(?![\w]|[.,:]\d)')
TAG_RE = re.compile(r'<n([1-9])>')
# protect: left to right, each NEW number gets the next tag <n1>..<n9>; the same number reuses its tag;
#          after 9 numbers, leave the rest as they are. Returns (tagged_text, numbers).
# restore: replace <nK> with numbers[K-1]; drop unknown tags; collapse double spaces; trim.
```

Dart's `RegExp` supports lookbehind. `\w` in Dart is ASCII-only, while Python's is Unicode. That is fine here, because the text has already been normalized.

### (E)/(F) Tokens
- Special ids:
  - `<pad>` = **0** (also the decoder start token)
  - `</s>` = **1**
  - `<unk>` = **2**
  - `>>hil<<` = **3** (translate *into* Hiligaynon)
  - `>>fil<<` = **4** (translate *into* Filipino)
  - `<n1>`…`<n9>` = **5…13**
- Hiligaynon → Filipino: source = `[4] + spm_ids + [1]`. Filipino → Hiligaynon: source = `[3] + spm_ids + [1]`.
- Truncate the spm ids to 126 so the total stays at 128 or fewer.
- SentencePiece settings: unigram, `nmt_nfkc` normalization, add dummy prefix "▁". `<n1>`…`<n9>` and the two tags are *user-defined symbols*, so they must come out as single ids when the tagged text is encoded. Check this in a unit test.
- Dart has no official SentencePiece. The options are FFI to the C++ library, or a pure-Dart unigram (Viterbi) tokenizer that reads `spm.model`. **If the v1 module already does this, keep the code and only swap the model file.**

### (G) ONNX inputs and outputs (8×8)

**Encoder**
- inputs: `input_ids` int64 [1, S], `attention_mask` int64 [1, S] (all ones)
- output: `last_hidden_state` float [1, S, 512]

**Decoder (merged)**
- inputs:
  - `encoder_attention_mask` int64 [1, S]
  - `input_ids` int64 [1, 1]
  - `encoder_hidden_states` float [1, S, 512]
  - `past_key_values.{L}.decoder.key|value` and `past_key_values.{L}.encoder.key|value` for L = 0…7 (**32 tensors**), each float [1, 8, T, 64]
  - `use_cache_branch` bool [1]
- outputs:
  - `logits` float [1, 1, 16000]
  - `present.{L}.decoder.key|value` and `present.{L}.encoder.key|value` (same 32 names)

(The 8×4 model has L = 0…3, so 16 past tensors. Read `decoder_layers` from `config.json` instead of hard-coding it.)

**Greedy loop.** This matches optimum on 30/30 sentences:

```
hidden = encoder(ids, mask)
past = { every past_key_values.* : zeros [1, 8, 1, 64] }
tok = 0 ; out = [] ; first = true
for step in 0..159:
    feed = input_ids=[[tok]], encoder_attention_mask=mask, encoder_hidden_states=hidden,
           use_cache_branch=[!first], + past
    o = decoder(feed)
    logits = o.logits[0, -1]
    logits[0] = logits[2] = logits[3] = logits[4] = -inf      # never output pad/unk/tags
    tok = argmax(logits)
    if step == 159: tok = 1                                    # the 160th token is always </s>
    if tok == 1: break
    out.append(tok)
    for each past name n:
        p = n.replace("past_key_values", "present")
        if first or n contains ".decoder.":  past[n] = o[p]     # encoder past is set ONCE (step 1)
    first = false
text = restore(sp.decode(out), numbers)
```

**Beam 4 (optional, better quality).** Keep 4 hypotheses, each with its own decoder past. At each step:
- Run the decoder on each hypothesis's last token. It can be batched as [4, 1] with the encoder outputs repeated 4 times.
- Add the log-softmax scores and keep the top 4 continuations.
- A hypothesis is finished when it outputs `</s>`.
- Pick the result with length penalty 1.0: total log-prob ÷ length.

Implement greedy first; it already reaches about 74 / 63 on the everyday test.

**Suggested policy:**
- **Beam 4 when the input has 15 words or fewer, greedy for longer input.**
- 1 or 2 intra-op threads; measure on the slowest test phone.
- Load the sessions once and keep them in memory (about 80 MB of model plus about 59 MB of TTS).

## 11. Test cases (expected ONNX int8 greedy output of the 8×8 model)

| Direction | Input | Expected |
|---|---|---|
| Hil→Fil | Patya ang suga. | Patayin mo ang ilaw. |
| Hil→Fil | Kuhaa ang libro. | Kunin mo ang libro. |
| Hil→Fil | Diin ang banyo? | Nasaan ang banyo? |
| Hil→Fil | Masakit ang akon ulo. | Masakit ang ulo ko. |
| Hil→Fil | Pila ini? | Magkano ito? |
| Fil→Hil | Patayin mo ang ilaw. | Palonga ang suga. |
| Fil→Hil | Saan ka pupunta? | Diin ka makadto? |
| Fil→Hil | May 3 na bata sa bahay. | May 3 ka kabataan sa balay. |
| Fil→Hil | Masakit ang tainga ko. | Masakit ang akon dalunggan. |

If the Dart output differs from these, check the following in this order:
1. normalize
2. the tag id (3 or 4)
3. the `</s>` at the end of the source
4. that the encoder past is updated only on step 1
5. the token blocking (ids 0, 2, 3, 4)

Full reference outputs: `results/student_v2_8x8_onnx_outputs.csv` (greedy, everyday and Bible-150).

## 12. Known weaknesses: what the app should cover

1. **Very short inputs break.** "Patayin ang ilaw" (without "mo") → "lipong"; "Naano imo tiil?" → "Ano ang mga paa mo?"; "Lakat lang kamo?" → "Umalis lang kayo?".
   → **Fixed with the short-phrase list `hibalo_phrase_list_v1.tsv`.** It has 8,806 rows, built only from human data, with no new Hiligaynon written.

   | direction | phrase rows | dictionary_word rows |
   |---|---|---|
   | hil2fil | 3,294 (teammate + Motus sentences, up to 6 words) | 2,249 (Motus words with a single entry) |
   | fil2hil | 3,263 | – (one Filipino word often has many Hiligaynon words) |

   Columns: `direction, key, input_example, output, row_type, kind, source, source_id, alternatives, in_eval_set, needs_check`.

   - **Lookup:** build the key as in `phrase_lookup.py` and match it exactly. "Patayin ang ilaw." → "patya ang suga" → match_style → "Patya ang suga".
   - **Conflicts:** teammate rows win over Motus, and the most common translation wins. The others are in `alternatives`. **331 rows have `needs_check`** (equally common translations, or recovered rows). A teammate or native speaker should look at those first.
   - **`in_eval_set = 1` (337 rows):** these are everyday test/dev sentences. They are kept so the app gets them right, but **switch them off** (`use_eval_rows=False`) if the app itself is ever scored on the everyday test. The model scores in this document were measured on the model alone, without the list.
   - **`kind = dictionary_word`:** Motus single-word meanings. Show them labelled "dictionary meaning", or switch them off (`use_dictionary_words=False`) if they feel too old-fashioned.
2. It sometimes **adds words** ("Gutom na ako." → "Gutom na gutom na ako.") or picks a less common word ("bata" → "kabataan").
3. **Teacher errors** were partly inherited, mostly rare and old words (for example "pigado", "silhig", "ramos").
4. **Numbers:**
   - Digits are copied safely through `<nK>`, and spelled-out numbers translate fine ("Tatlo ka gatos" → "Tatlong daan").
   - **For the voice**, the TTS needs words, not digits. **`hil_numbers.py`** converts the digits in Hiligaynon text, with 35 built-in tests, and it ran on 3,000 news lines without errors.

   | Written | Spoken |
   |---|---|
   | 3 | tatlo |
   | 11 | napulo kag isa |
   | 30–90 | katluan, kap-atan, kalim-an, kan-uman, kapituan, kawaluan, kasiyaman |
   | 150 | isa ka gatos kag kalim-an |
   | 2026 | duha ka libo kag duha ka pulo kag anom |
   | P150 | isa ka gatos kag kalim-an ka pesos |
   | ika-3 | ikatlo |
   | alas 4 | alas kwatro (Spanish hours) |
   | 90% | kasiyaman porsiyento |
   | 12-17 | napulo kag duha tubtob napulo kag pito |
   | 09171234567 | read digit by digit |

   **Native speaker check needed:**
   - "anom" or "anum"
   - "duha ka pulo" or "kaluhaan" for 20 ("kaluhaan" never appears in our text)
   - how "kag" is used in long numbers ("pito ka gatos kag kawaluan kag duha")

   These are constants at the top of the file, so they're easy to change.
5. Capitals and punctuation: the output sometimes drops the "?" or the first capital letter. **Fixed with `postprocess.match_style`** (step J).

## 13. Open items (as of 1 Nov 2026)

- [x] Short-phrase list: `hibalo_phrase_list_v1.tsv`. Still to do: a native check of the 331 `needs_check` rows.
- [x] Hiligaynon number words for the TTS: `hil_numbers.py`. Still to do: a native check of anom/anum, 20, and long numbers.
- [x] Copy `?` and the capital letter from the input: `postprocess.py`.
- [x] Quote-bug fixed copies of the data files (section 3.4).
- [ ] Port `phrase_lookup.py`, `postprocess.py` and `hil_numbers.py` to Dart, keeping their built-in tests as unit tests.
- [ ] Upload the contents of `hibalo_data_quotefix_v1.zip` to Drive `Hibalo/data/processed/` (the old versions are already archived).
- [ ] Create Kaggle dataset `hibalo-bible-v6` (section 15).
- [ ] TTS: phone speed tuning (XNNPACK, thread count).
- [ ] Merge the `lance-ui-updates` pull request.
- [ ] Update **both** paper versions:
  - round-2 method and results (sections 3–8)
  - AI-written synthetic data disclosure
  - the 8×8 student (79 MB)
  - replace SpeechT5 with MMS v4, with the model size, UP-DSP credit and MMS license
- [ ] Facebook page with daily Hiligaynon posts and Filipino translations: **permission requested from the admin** (do not scrape). If granted, use it in Round 3: spelling cleanup, then the leak check, then fine-tune student v2 from `student_v2_8x8/`.
- [ ] Lesson learning module (native-speaker recordings).

## 14. Where things are

**Drive `Hibalo/models/round2/`** (checked 1 Nov 2026; all files present):
- `hibalo_student_v2_8x8_onnx/` (14 files): **app model**
- `hibalo_student_v2_8x4_onnx/` (14 files): backup
- `student_v2_8x8/` (11 files): PyTorch fp32, 268 MB; used to fine-tune or export again
- `final_adapter/`: run-4 teacher LoRA (189 MB). The teacher CT2 can be rebuilt from it in about 30 min (notebook B4).
- `results/`:
  - `scores_8x4.json`, `scores_8x8.json`
  - `student_v2_8x4_outputs.csv`, `student_v2_8x8_outputs.csv`, `student_v2_8x8_onnx_outputs.csv`
  - `export_report_both.json`
  - `clean_report_8x4.json`, `dropped_sample_8x4.tsv`
  - `distill_r2_part1_stats.json`, `distill_r2_part2_stats.json`
  - `r4_teacher_scores.json`, `r4_teacher_compare.csv`

**New on 1 Nov 2026** (zips sent in chat; put them in Drive):
- `hibalo_app_text_rules_v1.zip` → `Hibalo/models/round2/app_text_rules/`
  - `hibalo_phrase_list_v1.tsv`, `hil_spelling_map_v2.tsv`
  - `phrase_lookup.py`, `postprocess.py`, `hil_numbers.py`
- `hibalo_data_quotefix_v1.zip` → `Hibalo/data/processed/`. The old versions are now in `archive/Used in Round 2 Student - before quote fix/`.
  - `bible_v6_*`, `teammate_pairs_clean_v4`, `kaufmann_v14_training_clean`, `hil_spelling_variants_v2`, `r2_everyday_test_v3`, `quote_fix_log.tsv`

**Elsewhere in Drive:**
- `Hibalo/notebooks/round2/`: round-2 notebooks, from `hibalo_round2_notebooks.zip`.
- `Hibalo/data/processed/`, the current data:
  - mono `.txt` files (4)
  - `motus_v3`
  - synthetic ×3
  - spelling map v1
  - the quote-fixed files
  - `round2_v2/` (Notebook 0 output, still read by the round-2 notebooks)
- `Hibalo/data/archive/`:
  - `Used in Round 2 Teacher/`
  - `Used in Round 2 Student - before quote fix/`
  - older versions

## 15. Kaggle (account `lancemontifar`)

| Dataset / output | Contents | Keep? |
|---|---|---|
| `hibalo-bible-v5` | `bible_v5_train/dev/test.tsv` | **Keep**: round 2 used it (needed to repeat round 2) |
| **`hibalo-bible-v6`** (new, to create) | `bible_v6_train/dev/test.tsv` (quote-fixed) | Use from round 3 on. It's a **new dataset**, not a new version of v5, because the round-2 notebooks look for `bible_v5_*` file names. |
| `hibalo-r2-data` | Notebook 0 v4 output (teacher mix, everyday test/dev, student extra, variants) | Keep. Round 3 gets a new `hibalo-r3-data`. |
| `hibalo-mono` | `mono_hil_madlad_v5`, `mono_hil_extra_v3`, `mono_hil_hiligayner_v3`, `mono_fil_madlad_v4` | Keep (not affected by the quote fix) |
| `hibalo-test` | Tatoeba, 26 pairs | Keep |
| Notebook outputs A4, B4, C1, C2, D1, D2, E | adapter, teacher CT2, distill lines with scores, students, ONNX | **Do not delete these versions.** D2 (`student_v2_8x8`) is the starting point for a fine-tune, and C1/C2 save about 5 GPU hours. |

## 16. Plan for the next fine-tune (Round 3)

Do this when new data arrives, for example the Facebook page if the admin agrees.

1. **New data:** clean it to one spelling (`hil_spelling_map_v1/v2`, siya/niya), remove duplicates, and run the leak check against the everyday test/dev (`r2_everyday_test_v3`, `r2_everyday_dev`) and Bible v6 test/dev.
2. **Notebook 0 for round 3** (Colab), using the **fixed** inputs:
   - `teammate_pairs_clean_v4`
   - `kaufmann_v14_training_clean`
   - `hil_spelling_variants_v2`
   - `r2_everyday_test_v3`
   - `bible_v6_*`
   - `motus_v3`
   - the 3 synthetic files
   - the new data

   Upload its output as Kaggle dataset **`hibalo-r3-data`**.
3. **Fine-tune student v2**, starting from D2's `student_v2_8x8`. Keep the same tokenizer `spm.model`, so the app's tokenizer doesn't change.
   - Mix the new data with a replay of the round-2 data (teacher lines from C1/C2, Bible v6, human rows), so the model doesn't forget.
   - Use a lower LR (for example 1e-4) and a few GPU hours. There's no need to retrain the teacher or redo distillation, unless there's a lot of new data.
4. **Score it on the same tests** (everyday 150, Tatoeba 26, Bible test 427), and compare against student v2 8×8 (75.3 / 64.9 everyday). Keep the new model only if the everyday score is not lower.
5. **Export** with Notebook E, and update the app files. If `in_eval_set` rows are added to the phrase list, keep them flagged.
