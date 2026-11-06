import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P08 Reading: tap a row (or the switch) to show its Filipino; the sentences scroll, the hint and tip stay. No audio.
class ReadingPart extends StatefulWidget {
  const ReadingPart({super.key, required this.data});

  final ReadingPartData data;

  @override
  State<ReadingPart> createState() => _ReadingPartState();
}

class _ReadingPartState extends State<ReadingPart> {
  final Set<int> _shown = {};
  bool _showAll = false;

  void _setAll(bool on) {
    setState(() {
      _showAll = on;
      _shown.clear();
      if (on) _shown.addAll(List.generate(widget.data.lines.length, (i) => i));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lines = widget.data.lines;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Figma P08: the card grows with its sentences up to the space left, then scrolls with the fade.
          PartHeader(icon: widget.data.icon, title: widget.data.title),
          const SizedBox(height: 10),
          ShowAllSwitch(label: t.showAllFilipino, value: _showAll, onChanged: _setAll),
          const SizedBox(height: 10),
          Flexible(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: V6Colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: V6Colors.borderDivider),
              ),
              child: FadingScroll(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < lines.length; i++)
                      _Row(
                        hil: lines[i].hil,
                        fil: lines[i].fil,
                        shown: _shown.contains(i),
                        divider: i < lines.length - 1,
                        onTap: () => setState(
                          () => _shown.contains(i) ? _shown.remove(i) : _shown.add(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          HintText(t.readingHint),
          if (widget.data.tip != null) TipCard(widget.data.tip!),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.hil,
    required this.fil,
    required this.shown,
    required this.divider,
    required this.onTap,
  });

  final String hil;
  final String fil;
  final bool shown;

  /// A line under this sentence (not under the last one).
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Figma "Sentence": at least 48 high, padding 16/13; a shown row is tinted.
    return Semantics(
      button: true,
      child: Material(
        color: shown ? V6Colors.surfaceTint : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            alignment: Alignment.centerLeft,
            decoration: divider
                ? const BoxDecoration(
                    border: Border(bottom: BorderSide(color: V6Colors.borderDivider)),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hil, style: V6Text.bodyLargeSemiBold),
                if (shown) ...[
                  const SizedBox(height: 2),
                  Text(fil, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
