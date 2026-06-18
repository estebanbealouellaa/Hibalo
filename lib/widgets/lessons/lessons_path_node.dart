import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'lessons_dashed_circle.dart';

class LessonsPathNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback onTap;

  const LessonsPathNode({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isLocked,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _NodeIcon(isLocked: isLocked, isCompleted: isCompleted),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isLocked ? inkMuted : ink,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isLocked ? FontWeight.w400 : FontWeight.w500,
                      color: isLocked ? inkMuted : purple,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: purplePale,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderMid),
              ),
              child: Text(
                '+20 XP',
                style: TextStyle(
                  fontSize: 10,
                  color: isLocked ? inkMuted : purple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeIcon extends StatelessWidget {
  final bool isLocked;
  final bool isCompleted;

  const _NodeIcon({required this.isLocked, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return DashedCircleBorder(
        size: 56,
        borderColor: purpleLight,
        backgroundColor: surface,
        child: Icon(Icons.lock_outline_rounded, color: purpleMid, size: 20),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: purple,
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.35),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isCompleted
            ? const Text('👑', style: TextStyle(fontSize: 22))
            : const Icon(Icons.waving_hand_rounded, color: white, size: 22),
      ),
    );
  }
}

class LessonsPathConnector extends StatelessWidget {
  final bool isActive;

  const LessonsPathConnector({super.key, this.isActive = true});

  static const double _lineHeight = 27;
  static const double _iconCenter = 28;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _lineHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: _iconCenter - 1),
          child: Container(
            width: 2,
            height: _lineHeight,
            decoration: BoxDecoration(
              color: isActive ? purpleLight : purpleLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonsPathList extends StatelessWidget {
  final List<LessonsPathNode> nodes;
  final List<bool> connectorActive;

  const LessonsPathList({
    super.key,
    required this.nodes,
    required this.connectorActive,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < nodes.length; i++) {
      children.add(nodes[i]);
      if (i < nodes.length - 1) {
        children.add(
          LessonsPathConnector(
            isActive: i < connectorActive.length ? connectorActive[i] : true,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
