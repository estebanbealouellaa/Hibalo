
import '../l10n/app_localizations.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'v6/v6.dart';

/// The phone's voice install screen first, then its speech settings.
const List<String> _installActions = [
  'android.speech.tts.engine.INSTALL_TTS_DATA',
  'com.android.settings.TTS_SETTINGS',
];

/// The dialog is shown at most once each time the app runs.
bool _dialogShown = false;

/// Shows the dialog the first time, and a short SnackBar after that.
Future<void> showFilipinoVoiceHelp(BuildContext context) async {
  if (_dialogShown) {
    showV6Snackbar(context, AppLocalizations.of(context).voiceFilipinoMissing, icon: Icons.info_outline_rounded);
    return;
  }
  _dialogShown = true;

  final install = await showV6Dialog(
    context,
    title: AppLocalizations.of(context).voiceFilipinoTitle,
    message: AppLocalizations.of(context).voiceFilipinoInstall,
    mascot: 'firefly_phone',
    primaryLabel: AppLocalizations.of(context).voiceInstall,
    secondaryLabel: AppLocalizations.of(context).voiceLater,
  );
  if (install) await _openVoiceInstall();
}

/// The phone lists a Filipino voice, but it didn't speak.
void showFilipinoVoiceNotReady(BuildContext context) {
  showV6Snackbar(context, AppLocalizations.of(context).voiceFilipinoNotReady, icon: Icons.info_outline_rounded);
}

Future<void> _openVoiceInstall() async {
  for (final action in _installActions) {
    final intent = AndroidIntent(
      action: action,
      flags: const [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      if (await intent.canResolveActivity() == true) {
        await intent.launch();
        return;
      }
    } on PlatformException catch (e) {
      debugPrint('[FilipinoTTS] could not open $action: $e');
    }
  }
  debugPrint('[FilipinoTTS] no voice install screen on this phone');
}
