import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';

/// The user's round avatar. [photoUrl] can be a web address (the old
/// DiceBear pictures) or an asset path ("assets/…"); anything missing or
/// broken falls back to assets/Account.png.
class V6Avatar extends StatelessWidget {
  const V6Avatar({super.key, required this.photoUrl, this.size = 48});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    Widget fallback() => Image.asset('assets/Account.png', width: size, height: size, fit: BoxFit.cover);
    final Widget image;
    if (url == null || url.isEmpty) {
      image = fallback();
    } else if (url.startsWith('assets/')) {
      image = Image.asset(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    } else {
      image = Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    }
    return Semantics(
      label: 'Profile picture',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: V6Colors.primaryContainer),
        clipBehavior: Clip.antiAlias,
        child: image,
      ),
    );
  }
}
