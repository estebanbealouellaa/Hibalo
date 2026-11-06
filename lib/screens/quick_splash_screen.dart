import '../l10n/app_localizations.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/v6/v6.dart';

/// The short splash on every launch after the first: V6 violet with the
/// "Hibalo" wordmark only. It starts the sign-in check at once ([onReady]);
/// a spinner appears only if that takes longer than a second.
class QuickSplashScreen extends StatefulWidget {
  const QuickSplashScreen({super.key, required this.onReady});

  final VoidCallback onReady;

  @override
  State<QuickSplashScreen> createState() => _QuickSplashScreenState();
}

class _QuickSplashScreenState extends State<QuickSplashScreen> {
  bool _slow = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _slow = true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onReady();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: V6Colors.primary,
        body: Stack(
          children: [
            Center(
              child: Text('Hibalo', style: V6AppText.displayWordmark.copyWith(color: V6Colors.onPrimary)),
            ),
            if (_slow)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom + 80,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: V6Colors.citrus,
                      backgroundColor: V6Colors.onPrimary.withValues(alpha: 0.3),
                      semanticsLabel: t.commonLoading,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
