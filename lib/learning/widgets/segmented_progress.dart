import 'package:flutter/material.dart';

import '../theme/v6_colors.dart';

/// One segment per part, moving only when the part changes, never per card or letter (§1.6).
class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({super.key, required this.count, required this.current});

  final int count;

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
