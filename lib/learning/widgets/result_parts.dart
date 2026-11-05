import 'package:flutter/material.dart';

import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';

/// Building blocks shared by S03 Lesson complete and S04 Quiz result
/// (Figma "07 · Learn" / "09 · Quiz").

/// "Firefly with glow": a 200 box, a 168 circle and the 170 × 190 firefly.
class FireflyGlow extends StatelessWidget {
  const FireflyGlow({super.key, required this.mascot, required this.glow});

  /// A file name in assets/images/mascots, without ".webp".
  final String mascot;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            top: 24,
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(color: glow, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 15,
            top: 13,
            width: 170,
            height: 190,
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

/// "Stat" tile: a big value over a small label, padding 14, radius 16.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String value;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, maxLines: 1, style: V6Text.headlineMediumExtraBold.copyWith(color: foreground)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Two stat tiles side by side.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.left, required this.right, this.gap = 12});

  final Widget left;
  final Widget right;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          SizedBox(width: gap),
          Expanded(child: right),
        ],
      ),
    );
  }
}

/// "Unlock" chip: citrus with a check when a lesson opened, grey with a lock
/// when the quiz still has to be passed. Padding 14 / 10.
class UnlockChip extends StatelessWidget {
  const UnlockChip({super.key, required this.text, required this.unlocked});

  final String text;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final foreground = unlocked ? V6Colors.primaryStrong : V6Colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: unlocked ? V6Colors.citrus : V6Colors.neutralBackground,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(unlocked ? Icons.check_circle_rounded : Icons.lock_rounded, size: 20, color: foreground),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: V6Text.labelLargeBold.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// The full-width 52 primary button.
class ResultPrimaryButton extends StatelessWidget {
  const ResultPrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: V6Colors.primary,
          foregroundColor: V6Colors.onPrimary,
          textStyle: V6Text.button,
          shape: const StadiumBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}

/// The 48 text button in Primary under it.
class ResultTextButton extends StatelessWidget {
  const ResultTextButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: V6Colors.primary,
          textStyle: V6Text.button,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: const StadiumBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}

/// The S03 / S04 body: padding 24 / 20 / 16, 16 between blocks, the
/// buttons at the bottom. Scrolls on small phones or with large text.
class ResultBody extends StatelessWidget {
  const ResultBody({super.key, required this.top, required this.buttons});

  final List<Widget> top;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
          child: IntrinsicHeight(
            child: Column(
              children: [
                for (final (i, w) in top.indexed) ...[if (i > 0) const SizedBox(height: 16), w],
                const Spacer(),
                const SizedBox(height: 16),
                for (final (i, w) in buttons.indexed) ...[if (i > 0) const SizedBox(height: 16), w],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
