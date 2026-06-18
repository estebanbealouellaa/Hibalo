import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Me'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: white,
        border: Border(top: BorderSide(color: borderLight)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final active = selectedIndex == index;
            final item = items[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? purplePale : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.$1 : item.$2,
                        size: 20,
                        color: active ? purple : inkMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? purple : inkMuted,
                          fontWeight:
                              active ? FontWeight.w500 : FontWeight.w400,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
