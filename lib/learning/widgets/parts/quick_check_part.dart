import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P06 · Quick check: one question, options in a shuffled [order]. Tapping
/// an option answers at once (no Check button, no timer, one try). The
/// player shows the feedback sheet and pays the XP; this widget only draws.
class QuickCheckPart extends StatelessWidget {
  const QuickCheckPart({
    super.key,
    required this.data,
    required this.order,
    required this.chosen,
    required this.onChoose,
  });

  final QuickCheckPartData data;

  /// Option indexes (into data.options) in the order shown.
  final List<int> order;

  /// The chosen option index, or null before answering.
  final int? chosen;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PartLayout(
      children: [
        // Figma P06: 14 between blocks, 12 between options.
        Align(
          alignment: Alignment.centerLeft,
          child: SmallChip(t.quickCheckChip),
        ),
        const SizedBox(height: 14),
        Text(data.prompt, style: V6Text.headlineMedium),
        const SizedBox(height: 14),
        Text(t.quickCheckNote, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        const SizedBox(height: 14),
        for (var n = 0; n < order.length; n++) ...[
          if (n > 0) const SizedBox(height: 12),
          OptionCard(
            text: data.options[order[n]],
            state: _stateOf(order[n]),
            onTap: chosen == null ? () => onChoose(order[n]) : null,
          ),
        ],
      ],
    );
  }

  OptionState _stateOf(int i) {
    if (chosen == null) return OptionState.idle;
    if (i == data.answer) return OptionState.right;
    if (i == chosen) return OptionState.wrong;
    return OptionState.idle;
  }
}

enum OptionState { idle, selected, right, wrong }

/// One answer card (P06 now; the quiz options in step 4 reuse it).
class OptionCard extends StatelessWidget {
  const OptionCard({super.key, required this.text, required this.state, this.onTap});

  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, icon, iconColor) = switch (state) {
      OptionState.idle => (V6Colors.surface, V6Colors.borderDivider, Icons.radio_button_unchecked_rounded, V6Colors.textMuted),
      OptionState.selected => (V6Colors.surfaceTint, V6Colors.primary, Icons.radio_button_checked_rounded, V6Colors.primary),
      OptionState.right => (V6Colors.successContainer, V6Colors.success, Icons.check_circle_rounded, V6Colors.success),
      OptionState.wrong => (V6Colors.errorContainer, V6Colors.error, Icons.cancel_rounded, V6Colors.error),
    };
    return Semantics(
      button: onTap != null,
      selected: state != OptionState.idle,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: state == OptionState.idle ? 1 : 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          // Figma "Option Card": 56 high, padding 16/14, radius 14, 24 marker.
          // Default text is regular; a marked card is semibold.
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: state == OptionState.idle ? V6Text.bodyLarge : V6Text.bodyLargeSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
