import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/questions.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../parts/part_common.dart' show FadingScroll;
import 'choice_questions.dart';
import 'question_contract.dart';
import 'quiz_common.dart';

/// Q11 Read & answer (Figma "Q11 · Quiz · Read & answer" + Option selected / Listening / Listening · Answered).
/// Read mode: the passage (Hiligaynon only) in a card above the question. Listen mode: play buttons that play
/// the passage's line clips in order; "Show transcript" after answering. While the clips aren't recorded,
/// listen mode shows the passage like read mode, with "Audio coming soon". No timer.
/// Q13 (a [PassageSetData]) adds "Question n of N" and, from question 2, folds a read passage into a
/// "Show story" bar (Figma "Q13 · Quiz · Passage set"). The play buttons of listen mode always stay.
class ReadAnswerQuestion extends StatefulWidget {
  const ReadAnswerQuestion({
    super.key,
    required this.data,
    required this.order,
    required this.phase,
    required this.onChanged,
    this.speakerName,
  });

  /// The name shown for a passage speaker (Filipino lesson text); the JSON name when null.
  final String Function(String speaker)? speakerName;

  final ReadAnswerData data;
  final List<int> order;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<ReadAnswerQuestion> createState() => _ReadAnswerQuestionState();
}

class _ReadAnswerQuestionState extends State<ReadAnswerQuestion> with ChoiceState<ReadAnswerQuestion> {
  bool _transcript = false;

  /// Q13 from question 2: the folded story is open.
  bool _storyOpen = false;

  @override
  ChoiceQuestion get choice => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  bool get _isDialogue => widget.data.passage.any((l) => l.speaker != null);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    final listen = data.mode == ReadAnswerMode.listen;
    final clips = data.clips;
    final audioMissing = listen && clips.isEmpty;
    final answered = widget.phase != QuestionPhase.answering;

    final String hint;
    if (listen && !audioMissing) {
      hint = t.q11ListenHint;
    } else {
      hint = _isDialogue ? t.q11ReadConversationHint : t.q11ReadHint;
    }

    final set = data is PassageSetData ? data : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (set != null) ...[
          Text(t.questionOfSet(set.setIndex, set.setSize),
              style: V6Text.labelMedium.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 12),
        ],
        if (listen && !audioMissing) ...[
          BigAudioButtons.conversation(clips: clips),
          const SizedBox(height: 8),
          Text(
            t.q11ListenLabel,
            textAlign: TextAlign.center,
            style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
          ),
          if (answered) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _transcript = !_transcript),
                child: Text(
                  _transcript ? t.hideTranscript : t.showTranscript,
                  style: V6Text.labelLargeBold.copyWith(color: V6Colors.primary),
                ),
              ),
            ),
            if (_transcript) _PassageCard(label: t.q11ReadConversation, lines: data.passage, speakerName: widget.speakerName),
          ],
        ] else if (set != null && set.setIndex > 1) ...[
          _StoryBar(
            label: _storyOpen ? t.hideStory : t.showStory,
            open: _storyOpen,
            onTap: () => setState(() => _storyOpen = !_storyOpen),
          ),
          if (_storyOpen) ...[
            const SizedBox(height: 8),
            _PassageCard(
              label: _isDialogue ? t.q11ReadConversation : t.q11ReadStory,
              lines: data.passage,
              speakerName: widget.speakerName,
            ),
          ],
          if (audioMissing) ...[
            const SizedBox(height: 6),
            Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
          ],
        ] else ...[
          _PassageCard(
            label: _isDialogue ? t.q11ReadConversation : t.q11ReadStory,
            lines: data.passage,
            speakerName: widget.speakerName,
          ),
          if (audioMissing) ...[
            const SizedBox(height: 6),
            Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
          ],
        ],
        const SizedBox(height: 12),
        QuizTitle(data.question, hint: hint),
        const SizedBox(height: 12),
        ChoiceOptionList(
          question: data,
          order: widget.order,
          chosen: chosen,
          phase: widget.phase,
          onChoose: choose,
        ),
      ],
    );
  }
}

/// Figma "Passage card": white, radius 20, padding 16/14, a small label, the lines in Body/Large;
/// at most 200 high, scrolling with a fade when longer. Dialogue lines read "Speaker: line".
class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.label, required this.lines, this.speakerName});

  final String label;
  final List<PassageLine> lines;
  final String Function(String speaker)? speakerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: FadingScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: V6Text.labelMedium.copyWith(color: V6Colors.textSecondary)),
              const SizedBox(height: 8),
              for (final line in lines)
                Text.rich(
                  TextSpan(children: [
                    if (line.speaker != null)
                      TextSpan(text: '${speakerName?.call(line.speaker!) ?? line.speaker}: ', style: V6Text.bodyLargeSemiBold),
                    TextSpan(text: line.hil),
                  ]),
                  style: V6Text.bodyLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Show story bar": white, radius 16, 48 high, Body/Large · SemiBold in Primary, expand arrow.
class _StoryBar extends StatelessWidget {
  const _StoryBar({required this.label, required this.open, required this.onTap});

  final String label;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: V6Colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: V6Colors.borderDivider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text(label, style: V6Text.bodyLargeSemiBold.copyWith(color: V6Colors.primary))),
                const SizedBox(width: 12),
                Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: V6Colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
