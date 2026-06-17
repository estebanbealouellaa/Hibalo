import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: searchBarBg,
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: searchPlaceholder),
            const SizedBox(width: 8),
            Text(
              'Search lessons, words...',
              style: TextStyle(
                fontSize: 13,
                color: searchPlaceholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
