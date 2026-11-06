import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/catalog.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// The short form of a letter for tiles and chips: "A a" → "Aa",
/// "NG ng" → "NG".
String letterLabel(Letter letter) {
  final forms = letter.letter.split(' ');
  if (forms.first.length > 1) return forms.first;
  return forms.join();
}

/// P05 Letters & sounds: the player owns [index] (Back/Next); swipes and chip taps call [onIndexChanged].
class LettersPart extends StatefulWidget {
  const LettersPart({
    super.key,
    required this.data,
    required this.index,
    required this.seen,
    required this.onIndexChanged,
  });

  final LettersPartData data;
  final int index;

  final Set<int> seen;
  final ValueChanged<int> onIndexChanged;

  @override
  State<LettersPart> createState() => _LettersPartState();
}

class _LettersPartState extends State<LettersPart> {
  late final PageController _pages =
      PageController(initialPage: widget.index);

  /// True while the carousel slides on its own (Back/Next or a chip). The
  /// slide passes other letters on the way; those must not count as seen.
  bool _sliding = false;

  @override
  void didUpdateWidget(LettersPart old) {
    super.didUpdateWidget(old);
    // Back/Next or a chip changed the letter: slide the carousel to it.
    if (_pages.hasClients && (_pages.page?.round() ?? widget.index) != widget.index) {
      _sliding = true;
      _pages
          .animateToPage(
            widget.index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          )
          .whenComplete(() => _sliding = false);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final letters = widget.data.letters;
    final total = letters.length;

    // Figma "P05 · Lesson Content": 12 between blocks.
    return PartLayout(
      children: [
        Row(
          children: [
            const Icon(Icons.abc_rounded, size: 24, color: V6Colors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.data.title, style: V6Text.titleLargeExtraBold)),
            Text(
              t.lettersSeen(widget.seen.length, total),
              style: V6Text.labelLargeBold.copyWith(color: V6Colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(t.lettersHint, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
        const SizedBox(height: 12),
        // Edge-to-edge carousel with the margin inside each page, so the next card never peeks in; no clip, so the shadow shows.
        SizedBox(
          height: 232,
          child: LayoutBuilder(
            builder: (context, box) => OverflowBox(
              minWidth: box.maxWidth + 40,
              maxWidth: box.maxWidth + 40,
              child: PageView.builder(
                // Only the current card shows, full width (no peek).
                controller: _pages,
                clipBehavior: Clip.none,
                itemCount: total,
                onPageChanged: (i) {
                  // Only a swipe by the learner changes the letter here.
                  if (!_sliding && i != widget.index) widget.onIndexChanged(i);
                },
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _LetterCard(letter: letters[i]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (widget.index + 1) / total,
                  minHeight: 8,
                  color: V6Colors.primary,
                  backgroundColor: V6Colors.primaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              t.letterPosition(widget.index + 1, total),
              style: V6Text.labelLargeBold.copyWith(color: V6Colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _grid(letters),
      ],
    );
  }

  /// All letters, 7 per row (§3 P05).
  Widget _grid(List<Letter> letters) {
    return LayoutBuilder(builder: (context, box) {
      const gap = 6.0;
      final size = (box.maxWidth - gap * 6) / 7;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < letters.length; i++)
            _LetterChip(
              label: letterLabel(letters[i]),
              size: size,
              current: i == widget.index,
              seen: widget.seen.contains(i),
              onTap: () => widget.onIndexChanged(i),
            ),
        ],
      );
    });
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.letter});

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Figma "Letter card": 232 high, padding 18, radius 24, soft shadow.
    return Container(
      height: 232,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: V6Colors.borderDivider),
        boxShadow: const [
          BoxShadow(color: Color(0x14321B58), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: V6Colors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      letterLabel(letter),
                      style: V6Text.displayLetterCard.copyWith(color: V6Colors.onPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.calledLabel,
                      style: V6Text.labelMediumBold.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.96,
                        color: V6Colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '“${letter.name}”',
                      style: V6Text.headlineMediumExtraBoldItalic.copyWith(color: V6Colors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      letter.soundHint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: V6Colors.glowContainerSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: V6Colors.glow),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        letter.example.hil,
                        style: V6Text.hilResultExtraBoldItalic.copyWith(color: V6Colors.primaryStrong),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        letter.example.fil,
                        style: V6Text.bodyMediumSemiBold.copyWith(color: V6Colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // The only speaker button: the letter, then the example word.
                // Always shown; plays nothing until the clip is recorded.
                AudioButton(
                  clip: letter.audio,
                  label: t.playAudio,
                  size: 48,
                  iconSize: 24,
                  background: V6Colors.glow,
                  foreground: V6Colors.primaryStrong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.label,
    required this.size,
    required this.current,
    required this.seen,
    required this.onTap,
  });

  final String label;
  final double size;
  final bool current;
  final bool seen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = current
        ? (V6Colors.primary, V6Colors.onPrimary, V6Colors.primary)
        : seen
            ? (V6Colors.primaryContainer, V6Colors.primary, V6Colors.primaryContainer)
            : (V6Colors.surface, V6Colors.primary, V6Colors.borderDivider);
    // Figma "Letter Chip": 48 high, radius 12. Seen = light violet + check.
    return Semantics(
      button: true,
      selected: current,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: current ? BorderSide.none : BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(label, style: V6Text.labelLetter.copyWith(color: foreground)),
                if (seen && !current)
                  const Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(Icons.check_rounded, size: 11, color: V6Colors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
