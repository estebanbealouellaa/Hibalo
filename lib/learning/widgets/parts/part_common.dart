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

/// A scroll view that fades its bottom edge while there is more to see.
class FadingScroll extends StatefulWidget {
  const FadingScroll({super.key, required this.child});

  final Widget child;

  @override
  State<FadingScroll> createState() => _FadingScrollState();
}

class _FadingScrollState extends State<FadingScroll> {
  bool _more = false;

  bool _onMetrics(ScrollMetrics m) {
    final more = m.extentAfter > 1;
    if (more != _more) setState(() => _more = more);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scroll = NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _onMetrics(n.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) => _onMetrics(n.metrics),
        child: SingleChildScrollView(child: widget.child),
      ),
    );
    if (!_more) return scroll;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.black, Colors.transparent],
        stops: [0, 0.88, 1],
      ).createShader(rect),
      child: scroll,
    );
  }
}

/// Icon tile + title at the top of most parts.
class PartHeader extends StatelessWidget {
  const PartHeader({super.key, required this.icon, required this.title, this.trailing});

  /// A Material Symbols name from the JSON.
  final String icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(icon: partIcon(icon)),
        const SizedBox(width: 12),
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
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(icon, color: V6Colors.primary, size: size / 2),
    );
  }
}

/// Body text of a part, with *markup*.
class PartText extends StatelessWidget {
  const PartText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => MarkupText(text, style: V6Text.bodyLarge);
}

/// Small grey instruction line ("Read each line aloud…").
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
    );
  }
}

/// The teal tip card with a lightbulb (P07, P08).
class TipCard extends StatelessWidget {
  const TipCard(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: V6Colors.lagoonContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: V6Colors.lagoonText, size: 20),
          const SizedBox(width: 10),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(color: background, shape: const StadiumBorder()),
      child: Text(text, style: V6Text.labelMedium.copyWith(color: foreground)),
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
    return MergeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: V6Text.labelLargeBold),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: V6Colors.onPrimary,
            activeTrackColor: V6Colors.primary,
            inactiveThumbColor: V6Colors.onPrimary,
            inactiveTrackColor: V6Colors.borderInput,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

/// A round audio button. Callers only build it when the clip exists (§1.4).
class AudioButton extends StatelessWidget {
  const AudioButton({
    super.key,
    required this.clip,
    required this.label,
    this.slow = false,
    this.size = 56,
    this.background = V6Colors.primary,
    this.foreground = V6Colors.onPrimary,
  });

  final String clip;
  final String label;
  final bool slow;
  final double size;
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
                  slow ? Icons.hourglass_bottom_rounded : Icons.volume_up_rounded,
                  color: foreground,
                  size: size * 0.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White card with a light border, used by most parts.
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
