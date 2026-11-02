// What the user sees when the phone has no offline Filipino voice. All the
// text is here, so it is easy to change.

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kFilipinoVoiceDialogText =
    'Para marinig ang Filipino, i-install ang Filipino voice ng iyong telepono.';
const String kFilipinoVoiceInstallButton = 'I-install';
const String kFilipinoVoiceLaterButton = 'Mamaya na';
const String kFilipinoVoiceSnackBarText =
    'Wala pang Filipino voice sa telepono. I-install sa Settings.';
const String kFilipinoVoiceNotReadyText =
    'Hindi pa handa ang Filipino voice. Kumonekta sa internet at subukan ulit.';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(kFilipinoVoiceSnackBarText)),
    );
    return;
  }
  _dialogShown = true;

  final install = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: const Text(kFilipinoVoiceDialogText),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text(kFilipinoVoiceLaterButton),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(kFilipinoVoiceInstallButton),
        ),
      ],
    ),
  );
  if (install == true) await _openVoiceInstall();
}

/// The phone lists a Filipino voice, but it didn't speak.
void showFilipinoVoiceNotReady(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text(kFilipinoVoiceNotReadyText)),
  );
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
