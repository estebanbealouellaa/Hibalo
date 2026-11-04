import 'package:flutter/material.dart';

import '../logic/unlocking.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import 'lesson_image.dart';

/// One lesson in the S01 list (Figma component "Lesson row", 335 × 80):
/// number box, icon, title, one meta line and a trailing icon. The look
/// follows [state]; the texts are worked out by the Learn screen.
class LessonRow extends StatelessWidget {
  const LessonRow({
    super.key,
    required this.number,
    required this.title,
    required this.meta,
    required this.state,
    required this.icon,
    required this.fallbackPicture,
    required this.stateLabel,
    required this.onTap,
  });

  final int number;
  final String title;

  /// "8 parts • 8 min", or the quiz-pending / locked message.
  final String meta;
  final LessonRowState state;

  /// Lesson icon asset path, or null (→ firefly_reading).
  final String? icon;
  final String fallbackPicture;

  /// Spoken state for screen readers ("Completed", "Locked"), or null.
  final String? stateLabel;
  final VoidCallback onTap;

  static const double _height = 80;
  static const double _radius = 16;

  bool get _locked => state == LessonRowState.locked;
  bool get _outlined =>
      state == LessonRowState.current || state == LessonRowState.quizPending;

  @override
  Widget build(BuildContext context) {
    final border = _outlined
        ? Border.all(color: V6Colors.primary, width: 2)
        : Border.all(color: V6Colors.borderDivider);

    return Semantics(
      button: true,
      label: [
        '$number. $title',
        meta,
        ?stateLabel,
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: _locked ? V6Colors.neutralBackground : V6Colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: _height),
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(_radius),
            ),
            // Figma: number box at 13, icon at 55, text at 117, icon end at 326.
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                _NumberBox(number: number, state: state),
                const SizedBox(width: 10),
                Opacity(
                  opacity: _locked ? 0.6 : 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LessonImage(
                      path: icon,
                      fallback: fallbackPicture,
                      width: 52,
                      height: 52,
                      fallbackColor: V6Colors.primaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _texts()),
                const SizedBox(width: 4),
                _trailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _texts() {
    final metaColor = switch (state) {
      LessonRowState.quizPending => V6Colors.primary,
      LessonRowState.locked => V6Colors.textSecondary,
      _ => V6Colors.textMuted,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: V6Text.titleMedium.copyWith(
            color: _locked ? V6Colors.textSecondary : V6Colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          meta,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: V6Text.caption.copyWith(color: metaColor),
        ),
      ],
    );
  }

  Widget _trailing() {
    final (icon, color) = switch (state) {
      LessonRowState.completed || LessonRowState.current =>
        (Icons.chevron_right_rounded, V6Colors.primary),
      LessonRowState.quizPending => (Icons.assignment_outlined, V6Colors.primary),
      LessonRowState.locked => (Icons.lock_rounded, V6Colors.textSecondary),
    };
    return Icon(icon, color: color, size: 24);
  }
}

/// The 32 × 32 number box at the start of a row.
class _NumberBox extends StatelessWidget {
  const _NumberBox({required this.number, required this.state});

  final int number;
  final LessonRowState state;

  @override
  Widget build(BuildContext context) {
    final (background, textColor) = switch (state) {
      LessonRowState.completed => (V6Colors.success, V6Colors.onPrimary),
      LessonRowState.current ||
      LessonRowState.quizPending =>
        (V6Colors.citrus, V6Colors.onCitrus),
      LessonRowState.locked => (V6Colors.navInactiveIcon, V6Colors.onPrimary),
    };

    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$number', style: V6Text.labelLessonNumber.copyWith(color: textColor)),
            ),
          ),
          if (state == LessonRowState.completed)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: V6Colors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: V6Colors.surface, width: 1.5),
                ),
                child: const Icon(Icons.check_rounded, size: 11, color: V6Colors.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
