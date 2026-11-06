import 'package:flutter/material.dart';

import '../../widgets/v6/v6.dart';

/// Figma 619:5983 "Clear translation history?". True = clear.
Future<bool> confirmClearHistory(BuildContext context) async {
  const clear = 'Clear history';
  final picked = await showV6ChoiceDialog(
    context,
    mascot: 'firefly_trash',
    mascotCircle: V6Colors.coralTonal,
    title: 'Clear translation history?',
    message: 'This removes all your past translations from this phone. Your saved words stay.',
    primaryLabel: 'Keep history',
    textActions: const [clear],
    dangerActions: const {clear},
  );
  return picked == clear;
}

/// Figma 619:6084 "Clear saved words?". True = clear.
Future<bool> confirmClearSaved(BuildContext context) async {
  const clear = 'Clear saved words';
  final picked = await showV6ChoiceDialog(
    context,
    mascot: 'firefly_trash',
    mascotCircle: V6Colors.coralTonal,
    title: 'Clear saved words?',
    message: 'This removes every word you saved. Your lesson progress stays.',
    primaryLabel: 'Keep saved words',
    textActions: const [clear],
    dangerActions: const {clear},
  );
  return picked == clear;
}
