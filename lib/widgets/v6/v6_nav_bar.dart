import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';

/// One destination of [V6NavBar].
class V6NavItem {
  const V6NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Figma "Navigation Bar" (448:1678, Items=4): Surface with a Divider top
/// border, 80 high. Each item: a 64 × 32 indicator (Primary Container when
/// selected), a 24 px icon and Label/Medium (Bold Primary when selected,
/// Text/Muted otherwise). The whole item is the touch target.
class V6NavBar extends StatelessWidget {
  const V6NavBar({super.key, required this.items, required this.selected, required this.onSelect});

  final List<V6NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: V6Colors.surface,
        border: Border(top: BorderSide(color: V6Colors.borderDivider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: Semantics(
                    selected: i == selected,
                    button: true,
                    label: item.label,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 64,
                              height: 32,
                              decoration: ShapeDecoration(
                                color: i == selected ? V6Colors.primaryContainer : Colors.transparent,
                                shape: const StadiumBorder(),
                              ),
                              child: Icon(
                                item.icon,
                                size: 24,
                                color: i == selected ? V6Colors.primary : V6Colors.navInactiveIcon,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              maxLines: 1,
                              style: i == selected
                                  ? V6Text.labelMediumBold.copyWith(color: V6Colors.primary)
                                  : V6Text.labelMedium.copyWith(color: V6Colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
