import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';

/// Figma "Button" (448:1465) styles.
enum V6ButtonStyle {
  /// Violet, white text.
  primary,

  /// Primary Container, plum text.
  secondary,

  /// No fill, violet text, 48 high.
  text,

  /// Coral, plum text (never white on coral).
  coral,

  /// Citrus, plum text.
  citrus,

  /// Primary Strong (plum), white text.
  strong,

  /// No fill, Error text, 48 high.
  dangerText,
}

/// Figma "Button": [onPressed] null = Disabled; [loading] = spinner + label, not tappable; [expand] = full width.
class V6Button extends StatelessWidget {
  const V6Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = V6ButtonStyle.primary,
    this.loading = false,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final V6ButtonStyle style;
  final bool loading;
  final bool expand;

  /// Optional trailing icon (20 px).
  final IconData? icon;

  bool get _isText => style == V6ButtonStyle.text || style == V6ButtonStyle.dangerText;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (background, foreground) = switch (style) {
      V6ButtonStyle.primary => (V6Colors.primary, V6Colors.onPrimary),
      V6ButtonStyle.secondary => (V6Colors.primaryContainer, V6Colors.onPrimaryContainer),
      V6ButtonStyle.text => (Colors.transparent, V6Colors.primary),
      V6ButtonStyle.coral => (V6Colors.coral, V6Colors.primaryStrong),
      V6ButtonStyle.citrus => (V6Colors.citrus, V6Colors.onCitrus),
      V6ButtonStyle.strong => (V6Colors.primaryStrong, V6Colors.onPrimary),
      V6ButtonStyle.dangerText => (Colors.transparent, V6Colors.error),
    };
    // Loading keeps the enabled look (Figma "State=Loading").
    final disabled = onPressed == null && !loading;
    final bg = disabled && !_isText ? V6Colors.stateDisabled : background;
    final fg = disabled ? V6Colors.textDisabled : foreground;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: V6Text.button.copyWith(color: fg),
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, size: 20, color: fg),
        ],
      ],
    );

    final button = Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            height: _isText ? 48 : 52,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _isText ? 12 : 24),
              // Hugs the label unless the button is stretched ([expand]).
              child: Center(widthFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Figma "Text Link" (448:1614): Label/Large in Link colour, 48 high.
class V6TextLink extends StatelessWidget {
  const V6TextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              widthFactor: 1,
              child: Text(label, style: V6Text.labelLarge.copyWith(color: V6Colors.link)),
            ),
          ),
        ),
      ),
    );
  }
}
