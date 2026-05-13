import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LanguageLabel extends StatelessWidget {
  final String name;
  final bool isActive;

  const LanguageLabel({super.key, required this.name, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isActive ? purple200 : purple400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
