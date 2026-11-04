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

/// P05 · Letters & sounds: a carousel of letter cards (the next one peeks
/// in), a progress bar and a grid of all letters. The player owns the
/// current [index] (Back/Next move it); swiping and tapping a chip call
/// [onIndexChanged]. Every letter shown counts as seen.
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

  /// Indexes of the letters seen so far.
  final Set<int> seen;
  final ValueChanged<int> onIndexChanged;

  @override
  State<LettersPart> createState() => _LettersPartState();
}

class _LettersPartState extends State<LettersPart> {
  late final PageController _pages =
      PageController(initialPage: widget.index, viewportFraction: 0.86);

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

    return PartLayout(
      children: [
        Row(
          children: [
            const IconTile(icon: Icons.abc_rounded, size: 32),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.data.title, style: V6Text.titleLargeBold)),
            Text(
              t.lettersSeen(widget.seen.length, total),
              style: V6Text.labelLargeBold.copyWith(color: V6Colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(t.lettersHint, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 186,
          child: PageView.builder(
            controller: _pages,
            padEnds: false,
            itemCount: total,
            onPageChanged: (i) {
              // Only a swipe by the learner changes the letter here.
              if (!_sliding && i != widget.index) widget.onIndexChanged(i);
            },
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 6),
              child: _LetterCard(letter: letters[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(V6Spacing.radiusFull),
                child: LinearProgressIndicator(
                  value: (widget.index + 1) / total,
                  minHeight: 8,
                  color: V6Colors.primary,
                  backgroundColor: V6Colors.primaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(t.letterPosition(widget.index + 1, total), style: V6Text.labelLargeBold),
          ],
        ),
        const SizedBox(height: 14),
        _grid(letters),
      ],
    );
  }

  /// All letters, 7 per row (§3 P05).
  Widget _grid(List<Letter> letters) {
    return LayoutBuilder(builder: (context, box) {
      const gap = 6.0;
      final size = ((box.maxWidth - gap * 6) / 7).floorToDouble();
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: V6Colors.borderDivider),
        boxShadow: [
          BoxShadow(color: V6Colors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: V6Colors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      letterLabel(letter),
                      style: V6Text.displayLetterCard.copyWith(color: V6Colors.onPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.calledLabel, style: V6Text.labelMediumBold.copyWith(color: V6Colors.textMuted)),
                    Text(
                      '“${letter.name}”',
                      style: V6Text.hilResultExtraBoldItalic.copyWith(color: V6Colors.primary),
                    ),
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: V6Colors.glowContainerSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: V6Colors.glow),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(letter.example.hil, style: V6Text.hilWordBoldItalic),
                      Text(letter.example.fil, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
                    ],
                  ),
                ),
                // The only speaker button: the letter, then the example word.
                if (letter.audio != null)
                  AudioButton(
                    clip: letter.audio!,
                    label: t.playAudio,
                    size: 40,
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
    return Semantics(
      button: true,
      selected: current,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: size,
            // At least 48 tall to tap (§1.12).
            height: size < 48 ? 48 : size,
            child: Center(
              child: Text(label, style: V6Text.labelLetter.copyWith(color: foreground)),
            ),
          ),
        ),
      ),
    );
  }
}
