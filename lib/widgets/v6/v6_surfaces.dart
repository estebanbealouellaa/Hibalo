import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';
import 'v6_button.dart';

/// Shared V6 surfaces: mascot circle, dialog, bottom sheet, message card,
/// list card and row (Figma frames in 01–06; the dialog matches the
/// Learning "Leave" dialog: 311 wide, radius 24, padding 24 / 24 / 20).

/// "Mascot circle": a firefly over a tinted circle.
class V6MascotCircle extends StatelessWidget {
  const V6MascotCircle({
    super.key,
    required this.mascot,
    this.circleColor = V6Colors.glow,
    this.size = 113,
    this.circleSize = 88,
  });

  /// File name in assets/images/mascots, without ".webp".
  final String mascot;
  final Color circleColor;
  final double size;
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    final height = size * 128 / 113;
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/mascots/$mascot.webp',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A V6 dialog: optional mascot circle, title (Title/Large · Bold, centred),
/// message, a full-width primary action and any number of text actions.
/// Completes with the label that was tapped, or null when dismissed.
Future<String?> showV6ChoiceDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? mascot,
  Color mascotCircle = V6Colors.glow,
  Color titleColor = V6Colors.textPrimary,
  required String primaryLabel,
  V6ButtonStyle primaryStyle = V6ButtonStyle.primary,
  List<String> textActions = const [],
  bool barrierDismissible = true,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: V6Colors.primaryStrong.withValues(alpha: 0.45),
    builder: (dialogContext) => Dialog(
      backgroundColor: V6Colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mascot != null) ...[
              Center(child: V6MascotCircle(mascot: mascot, circleColor: mascotCircle)),
              const SizedBox(height: 12),
            ],
            Text(title, textAlign: TextAlign.center, style: V6Text.titleLargeBold.copyWith(color: titleColor)),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            V6Button(
              label: primaryLabel,
              style: primaryStyle,
              expand: true,
              onPressed: () => Navigator.of(dialogContext).pop(primaryLabel),
            ),
            for (final label in textActions) ...[
              const SizedBox(height: 12),
              Center(
                child: V6Button(
                  label: label,
                  style: V6ButtonStyle.text,
                  onPressed: () => Navigator.of(dialogContext).pop(label),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// [showV6ChoiceDialog] with one optional text action: true for the
/// primary action, false otherwise.
Future<bool> showV6Dialog(
  BuildContext context, {
  required String title,
  String? message,
  String? mascot,
  Color mascotCircle = V6Colors.glow,
  required String primaryLabel,
  V6ButtonStyle primaryStyle = V6ButtonStyle.primary,
  String? secondaryLabel,
}) async {
  final picked = await showV6ChoiceDialog(
    context,
    title: title,
    message: message,
    mascot: mascot,
    mascotCircle: mascotCircle,
    primaryLabel: primaryLabel,
    primaryStyle: primaryStyle,
    textActions: [?secondaryLabel],
  );
  return picked == primaryLabel;
}

/// A V6 bottom sheet: Surface, radius 24 on top, a 36 × 4 handle, a title
/// (Title/Large · Bold) and a description, then [children].
Future<T?> showV6BottomSheet<T>(
  BuildContext context, {
  required String title,
  String? description,
  required List<Widget> Function(BuildContext sheetContext) children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: V6Colors.surface,
    barrierColor: V6Colors.primaryStrong.withValues(alpha: 0.45),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: V6Colors.borderDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: V6Text.titleLargeBold),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(description, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
            ],
            const SizedBox(height: 16),
            ...children(sheetContext),
          ],
        ),
      ),
    ),
  );
}

/// "Message card": a 44 icon tile, a title and a message, then actions.
/// Surface, Border/Divider, radius 16, padding 16.
class V6MessageCard extends StatelessWidget {
  const V6MessageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
    this.background = V6Colors.surface,
    this.iconColor = V6Colors.primary,
  });

  final Color background;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: background == V6Colors.surface ? Border.all(color: V6Colors.borderDivider) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: background == V6Colors.surface ? V6Colors.primaryContainer : V6Colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: V6Text.titleMedium),
                    const SizedBox(height: 4),
                    Text(message, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: actions),
          ],
        ],
      ),
    );
  }
}

/// A white card holding rows, separated by dividers (Me, Settings, lists).
class V6ListCard extends StatelessWidget {
  const V6ListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, row) in children.indexed) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: V6Colors.borderDivider),
            row,
          ],
        ],
      ),
    );
  }
}

/// One row of a [V6ListCard]: a 40 icon tile, title, optional subtitle and a
/// trailing widget (chevron by default).
class V6ListRow extends StatelessWidget {
  const V6ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? V6Colors.error : V6Colors.primary;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: danger ? V6Colors.errorContainer : V6Colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: V6Text.titleMedium.copyWith(color: danger ? V6Colors.error : V6Colors.textPrimary),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right_rounded, color: V6Colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
