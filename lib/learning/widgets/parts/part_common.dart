import 'package:flutter/material.dart';

import '../../services/lesson_audio.dart';
import '../../theme/part_icons.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../markup_text.dart';

/// The body of a lesson part: [children] scroll with a soft fade at the
/// bottom, and [footer] (hint, tip) stays visible under them (§3).
class PartLayout extends StatelessWidget {
  const PartLayout({super.key, required this.children, this.footer = const []});

  final List<Widget> children;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FadingScroll(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
        if (footer.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: footer,
            ),
          ),
      ],
    );
  }
}

class FadingScroll extends StatefulWidget {
  const FadingScroll({super.key, required this.child});

  final Widget child;

  @override
  State<FadingScroll> createState() => _FadingScrollState();
}

class _FadingScrollState extends State<FadingScroll> {
  bool _more = false;

  /// Only this scroll view's own notifications (depth 0) count: a carousel
  /// inside (P05) scrolls sideways and must not switch the fade.
  bool _onMetrics(int depth, ScrollMetrics metrics) {
    if (depth != 0) return false;
    final more = metrics.extentAfter > 1;
    if (more != _more) setState(() => _more = more);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // The ShaderMask is always there (only its gradient changes), so the
    // part below keeps its state when the fade turns on or off.
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _onMetrics(n.depth, n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => _onMetrics(n.depth, n.metrics),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black,
              _more ? Colors.transparent : Colors.black,
            ],
            stops: const [0, 0.88, 1],
          ).createShader(rect),
          child: SingleChildScrollView(child: widget.child),
        ),
      ),
    );
  }
}

/// Icon tile + title at the top of most parts.
class PartHeader extends StatelessWidget {
  const PartHeader({super.key, required this.icon, required this.title, this.trailing});

  final String icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(icon: partIcon(icon)),
        const SizedBox(width: 12), // Figma header gap
        Expanded(child: Text(title, style: V6Text.titleLargeBold)),
        ?trailing,
      ],
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, this.size = 48});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: V6Colors.primaryContainer,
        borderRadius: BorderRadius.circular(size * 14 / 48), // 14 on the 48 tile
      ),
      child: Icon(icon, color: V6Colors.primary, size: size / 2),
    );
  }
}

class PartText extends StatelessWidget {
  const PartText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => MarkupText(text, style: V6Text.bodyLarge);
}

/// Small grey instruction line ("Read each line aloud…").
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key, this.top = 10});

  final String text;

  /// Space above (the gap between blocks in the part).
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(text, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
    );
  }
}

/// The teal tip card with a lightbulb (P07, P08).
class TipCard extends StatelessWidget {
  const TipCard(this.text, {super.key, this.top = 10});

  final String text;

  /// Space above (the gap between blocks in the part).
  final double top;

  @override
  Widget build(BuildContext context) {
    // Figma "Tip": padding 14, radius 18, 22 px bulb, 12 gap.
    return Container(
      margin: EdgeInsets.only(top: top),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: V6Colors.lagoonContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: V6Colors.lagoonText, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: MarkupText(
              text,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.textPrimary),
              exampleColor: V6Colors.lagoonText,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small rounded label, e.g. "Hiligaynon", "New word".
class SmallChip extends StatelessWidget {
  const SmallChip(
    this.text, {
    super.key,
    this.background = V6Colors.citrus,
    this.foreground = V6Colors.onCitrus,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // Figma "Chip": 28 high, 12 side padding, Label/Medium.
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(color: background, shape: const StadiumBorder()),
      child: Center(
        widthFactor: 1,
        child: Text(text, style: V6Text.labelMedium.copyWith(color: foreground)),
      ),
    );
  }
}

/// "Show all Filipino" with its switch (P07, P08).
class ShowAllSwitch extends StatelessWidget {
  const ShowAllSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // Figma "Toggle · Show all Filipino": 48 high, 4 side padding, a
    // 40 x 24 switch. The whole row toggles, so the tap area stays 48 high.
    return MergeSemantics(
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(V6Spacing.radiusMedium),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: V6Text.labelLargeSemiBold),
                  const SizedBox(width: 8),
                  // Material's track is 52 x 32, so it is scaled by 40 / 52 to get Figma's 40 x 24.
                  SizedBox(
                    width: 40,
                    height: 24,
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: Transform.scale(
                        scale: 40 / 52,
                        child: Switch(
                          value: value,
                          onChanged: onChanged,
                          // The row is the tap area, so no 48 px padding here.
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          activeThumbColor: V6Colors.onPrimary,
                          activeTrackColor: V6Colors.primary,
                          inactiveThumbColor: V6Colors.onPrimary,
                          inactiveTrackColor: V6Colors.borderInput,
                          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round audio button. Always shown: if the clip isn't in the app yet,
/// tapping it plays nothing (§1.4).
class AudioButton extends StatelessWidget {
  const AudioButton({
    super.key,
    required this.clip,
    required this.label,
    this.slow = false,
    this.size = 64,
    this.iconSize,
    this.background = V6Colors.primary,
    this.foreground = V6Colors.onPrimary,
  });

  /// The clip's asset path (may not exist yet), or null.
  final String? clip;
  final String label;
  final bool slow;
  final double size;

  /// Glyph size; Figma uses 28 on the 64 button and 24 on 48.
  final double? iconSize;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // At least 48 × 48 to tap, even when the circle is smaller (§1.12).
    final tap = size < 48 ? 48.0 : size;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: tap,
        height: tap,
        child: Center(
          child: Material(
            color: background,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => LessonAudio.instance.play(clip, slow: slow),
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(
                  slow ? Icons.hourglass_top_rounded : Icons.volume_up_rounded,
                  color: foreground,
                  size: iconSize ?? (size >= 64 ? 28 : 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PartCard extends StatelessWidget {
  const PartCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 16});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: child,
    );
  }
}
