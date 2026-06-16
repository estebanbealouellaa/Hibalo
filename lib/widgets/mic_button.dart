import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onPressStart,
    required this.onPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressStart(),
      onTapUp: (_) => onPressEnd(),
      onTapCancel: onPressEnd,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 90,
        height: 90,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: isListening ? Colors.redAccent : purple,
        ),

        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: isListening ? 42 : 36,
        ),
      ),
    );
  }
}
