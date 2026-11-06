import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';

/// Figma "Icon Button" (448:1488) styles.
enum V6IconButtonStyle {
  /// On light surfaces.
  standard,

  /// Primary Container circle.
  tonal,

  /// White icon on purple surfaces.
  onPrimary,

  /// Violet circle, white icon.
  filled,
}

/// Figma "Icon Button": 48 × 48 touch target, 24 px rounded icon.
class V6IconButton extends StatelessWidget {
  const V6IconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.style = V6IconButtonStyle.standard,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final V6IconButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (style) {
      V6IconButtonStyle.standard => (Colors.transparent, V6Colors.textPrimary),
      V6IconButtonStyle.tonal => (V6Colors.primaryContainer, V6Colors.primary),
      V6IconButtonStyle.onPrimary => (Colors.transparent, V6Colors.onPrimary),
      V6IconButtonStyle.filled => (V6Colors.primary, V6Colors.onPrimary),
    };
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(backgroundColor: background, foregroundColor: foreground),
        icon: Icon(icon, size: 24),
      ),
    );
  }
}

/// Figma "Top App Bar" (448:1552): 64 high, transparent, 48 back button and optional trailing action.
class V6TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const V6TopAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.backTooltip,
    this.trailing,
  });

  final String title;

  /// Null hides the back button.
  final VoidCallback? onBack;
  /// Defaults to "Back" in the app language.
  final String? backTooltip;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            V6IconButton(icon: Icons.arrow_back_rounded, tooltip: backTooltip ?? AppLocalizations.of(context).back, onPressed: onBack),
            const SizedBox(width: 4),
          ] else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: V6Text.appBarTitle.copyWith(color: V6Colors.textPrimary),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
