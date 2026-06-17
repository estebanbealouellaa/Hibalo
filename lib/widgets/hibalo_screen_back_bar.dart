import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Top bar with back button for pushed screens (Translate, Lessons, Camera).
class HibaloScreenBackBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Color iconColor;
  final Color titleColor;
  final Widget? trailing;

  const HibaloScreenBackBar({
    super.key,
    required this.title,
    this.onBack,
    this.iconColor = ink,
    this.titleColor = ink,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: iconColor,
              size: 18,
            ),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTheme.displaySmall.copyWith(
                color: titleColor,
                fontSize: 17,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
