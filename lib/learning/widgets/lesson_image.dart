import 'package:flutter/material.dart';

/// A lesson picture that never breaks: if [path] is null (not in the app) or
/// the file can't be read, it shows [fallback] (firefly_reading) instead,
/// centred on [fallbackColor].
class LessonImage extends StatelessWidget {
  const LessonImage({
    super.key,
    required this.path,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackColor,
    this.semanticLabel,
  });

  /// Asset path, or null when the picture isn't made yet.
  final String? path;

  /// Asset path of the fallback picture.
  final String fallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? fallbackColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final picture = path;
    if (picture == null) return _fallback();
    return Image.asset(
      picture,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor,
      alignment: Alignment.center,
      child: Image.asset(
        fallback,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel,
        // The firefly is bundled, but stay safe in tests and previews.
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
