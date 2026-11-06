import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/v6/v6.dart';

/// Figma 619:5983 "Clear translation history?". True = clear.
Future<bool> confirmClearHistory(BuildContext context) async {
  final t = AppLocalizations.of(context);
  final picked = await showV6ChoiceDialog(
    context,
    mascot: 'firefly_trash',
    mascotCircle: V6Colors.coralTonal,
    title: t.clearHistoryTitle,
    message: t.clearHistoryBody,
    primaryLabel: t.clearHistoryKeep,
    textActions: [t.clearHistoryAction],
    dangerActions: {t.clearHistoryAction},
  );
  return picked == t.clearHistoryAction;
}

/// Figma 619:6084 "Clear saved words?". True = clear.
Future<bool> confirmClearSaved(BuildContext context) async {
  final t = AppLocalizations.of(context);
  final picked = await showV6ChoiceDialog(
    context,
    mascot: 'firefly_trash',
    mascotCircle: V6Colors.coralTonal,
    title: t.clearSavedTitle,
    message: t.clearSavedBody,
    primaryLabel: t.clearSavedKeep,
    textActions: [t.clearSavedAction],
    dangerActions: {t.clearSavedAction},
  );
  return picked == t.clearSavedAction;
}
