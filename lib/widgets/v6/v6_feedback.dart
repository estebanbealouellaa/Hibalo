import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';

/// Figma "Feedback Banner" (448:1497) types. Error = auth failure,
/// Warning = no internet (Sign In / Sign Up).
enum V6BannerType { error, warning, success, info }

/// Figma "Feedback Banner": 20 px icon + one short sentence (Body/Medium,
/// Text/Secondary), padding 12, radius 12. Optional 48-high action.
class V6Banner extends StatelessWidget {
  const V6Banner({
    super.key,
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final V6BannerType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (background, accent) = switch (type) {
      V6BannerType.error => (V6Colors.errorContainer, V6Colors.error),
      V6BannerType.warning => (V6Colors.warningContainer, V6Colors.warning),
      V6BannerType.success => (V6Colors.successContainer, V6Colors.success),
      V6BannerType.info => (V6Colors.primaryContainer, V6Colors.primary),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(
              type == V6BannerType.success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              size: 20,
              color: accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  if (actionLabel != null)
                    InkWell(
                      onTap: onAction,
                      child: SizedBox(
                        height: 48,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(actionLabel!, style: V6Text.labelLarge.copyWith(color: accent)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma "Snackbar" (696:7498): a plum pill with a citrus check and
/// Label/Large · SemiBold white text, shown ~3 s.
void showV6Snackbar(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: V6Colors.primaryStrong,
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(icon, size: 20, color: V6Colors.citrus),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: V6Text.labelLargeSemiBold.copyWith(color: V6Colors.onPrimary)),
            ),
          ],
        ),
      ),
    );
}

/// Figma "Chip" (448:1708) tones.
enum V6ChipTone { brand, success, neutral, citrus, coral, lagoon, surface }

/// Figma "Chip": non-interactive, 28 high, padding 12 / 4, Label/Medium.
class V6Chip extends StatelessWidget {
  const V6Chip({super.key, required this.label, this.tone = V6ChipTone.citrus, this.icon});

  final String label;
  final V6ChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      V6ChipTone.brand => (V6Colors.primaryContainer, V6Colors.onPrimaryContainer),
      V6ChipTone.success => (V6Colors.successContainer, V6Colors.success),
      V6ChipTone.neutral => (V6Colors.neutralBackground, V6Colors.textNeutralStrong),
      V6ChipTone.citrus => (V6Colors.citrus, V6Colors.onCitrus),
      V6ChipTone.coral => (V6Colors.coralContainer, V6Colors.coralText),
      V6ChipTone.lagoon => (V6Colors.lagoonContainer, V6Colors.lagoonText),
      V6ChipTone.surface => (V6Colors.surface, V6Colors.textPrimary),
    };
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(color: background, shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: foreground), const SizedBox(width: 4)],
          Text(label, style: V6Text.labelMedium.copyWith(color: foreground)),
        ],
      ),
    );
  }
}
