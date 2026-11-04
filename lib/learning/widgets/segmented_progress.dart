import 'package:flutter/material.dart';

import '../theme/v6_colors.dart';

/// "Lesson progress · Segmented": one equal segment per part (8 to 14),
/// 4 px apart. Done = violet, current = dark violet, next = light violet.
/// It moves only when the part changes, never per card or letter (§1.6).
class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({super.key, required this.count, required this.current});

  /// Number of parts (partsCount).
  final int count;

  /// The part being shown (0-based).
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${current + 1} / $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: i < current
                      ? V6Colors.primary
                      : i == current
                          ? V6Colors.primaryStrong
                          : V6Colors.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
