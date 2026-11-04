import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P08 · Reading: one full-width row per sentence. Tap a row to show or hide
/// its Filipino (a shown row gets a light tint); the switch does all rows.
/// The sentences scroll, while the hint and tip stay visible. No audio.
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
    return PartLayout(
      footer: [
        HintText(t.readingHint),
        if (widget.data.tip != null) TipCard(widget.data.tip!),
      ],
      children: [
        PartHeader(icon: widget.data.icon, title: widget.data.title),
        const SizedBox(height: 8),
        ShowAllSwitch(label: t.showAllFilipino, value: _showAll, onChanged: _setAll),
        const SizedBox(height: 4),
        PartCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _Row(
                  hil: lines[i].hil,
                  fil: lines[i].fil,
                  shown: _shown.contains(i),
                  first: i == 0,
                  last: i == lines.length - 1,
                  onTap: () => setState(
                    () => _shown.contains(i) ? _shown.remove(i) : _shown.add(i),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.hil,
    required this.fil,
    required this.shown,
    required this.first,
    required this.last,
    required this.onTap,
  });

  final String hil;
  final String fil;
  final bool shown;
  final bool first;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: Radius.circular(first ? 16 : 0),
      bottom: Radius.circular(last ? 16 : 0),
    );
    return Semantics(
      button: true,
      child: Material(
        color: shown ? V6Colors.surfaceTint : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hil, style: V6Text.bodyLargeSemiBold),
                if (shown)
                  Text(fil, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
