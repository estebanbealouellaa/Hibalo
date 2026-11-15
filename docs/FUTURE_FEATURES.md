# Future features (after release 1.2: Intermediate + Advanced)

Start these only after the Intermediate and Advanced lessons are released (pictures and audio done).

## 1. Pronunciation similarity feedback (offline) — DONE (Nov 16, release 1.2)

**Status:** built and switched on. How it behaves: `LEARNING_BEHAVIOR.md` §4 (Q09). Code: `lib/learning/services/pronunciation/` (MFCC, DTW, similarity, clip decoder), `ClipDecoder.kt`, `SpeakingQuestion`. Thresholds (relative score): Very close ≤ 0.82, Almost ≤ 0.95, from 2 speakers / 42 test recordings; re-tune with 3–5 voices on the debug Pronunciation tuning screen (Learn bug menu) if needed. The plan below is kept for reference.

Added: Nov 13, 2026 (Lance)

**What:** In the speaking question (Q09), after the learner records a word or short phrase, compare their recording with the native speaker's clip and show simple feedback such as "Very close / Almost / Try again".

**How (fully offline, no AI model, no app-size increase):**
- Turn both recordings into sound features (MFCC).
- Line them up with Dynamic Time Warping (DTW), so slow or fast speech still matches.
- Turn the distance into a similarity score, with thresholds tuned on the native clips plus a few test recordings.

**Rules:**
- Practice feedback only: not scored, no XP effect (Q09 stays unscored).
- Only where a native clip exists (all of Beginner now; Intermediate and Advanced once recorded).
- Single words and short phrases only.
- Works offline, on the phone.

**Limits to state honestly:** it measures how *similar* the sound is, not whether the word is "correct". Different voices, background noise and very slow speech can lower the score.

**For the paper:** call it "pronunciation similarity feedback", not "pronunciation accuracy".

**Not chosen (for now):** full speech recognition. Meta MMS can recognise Hiligaynon, but the model is several GB (too big for a phone). A smaller fine-tuned model would be its own research project. Android's offline recogniser has no Hiligaynon.

**Next step when we start:** I write a short plan for Claude Code (feature flag, test recordings, threshold tuning, Figma frame for the feedback state).
