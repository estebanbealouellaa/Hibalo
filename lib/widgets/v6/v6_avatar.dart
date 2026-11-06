import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';

/// The 6 local avatars (assets/images/profile/avatar1–6.webp). The value
/// saved in photoUrl is "asset:avatar1" … "asset:avatar6".
const int kAvatarCount = 6;

/// The photoUrl value for avatar [index] (0–5).
String avatarValue(int index) => 'asset:avatar${index + 1}';

/// The asset path for avatar [index] (0–5).
String avatarAsset(int index) => 'assets/images/profile/avatar${index + 1}.webp';

/// The DiceBear seeds of the old picker, in the same order as the local
/// avatars, so an old photoUrl maps to the same slot.
const List<String> _diceBearSeeds = ['Lilly', 'Felix', 'Mochi', 'Coco', 'Kiki', 'Boba'];

/// Which local avatar (0–5) [photoUrl] stands for: "asset:avatarN", or the
/// matching slot of an old DiceBear address. Null for anything else.
int? avatarIndexOf(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  final local = RegExp(r'^asset:avatar([1-6])$').firstMatch(photoUrl);
  if (local != null) return int.parse(local.group(1)!) - 1;
  if (photoUrl.contains('dicebear.com')) {
    final seed = Uri.tryParse(photoUrl)?.queryParameters['seed'];
    final i = _diceBearSeeds.indexOf(seed ?? '');
    return i < 0 ? 0 : i;
  }
  return null;
}

/// The user's round avatar. [photoUrl] can be "asset:avatarN" (local), an
/// old DiceBear web address (shown from the web, or the matching local
/// avatar when offline), or an asset path ("assets/…"); anything missing or
/// broken falls back to assets/Account.png.
class V6Avatar extends StatelessWidget {
  const V6Avatar({super.key, required this.photoUrl, this.size = 48});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final index = avatarIndexOf(url);
    Widget account() => Image.asset('assets/Account.png', width: size, height: size, fit: BoxFit.cover);
    Widget local(int i) =>
        Image.asset(avatarAsset(i), width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => account());
    final Widget image;
    if (url == null || url.isEmpty) {
      image = account();
    } else if (url.startsWith('asset:')) {
      image = index == null ? account() : local(index);
    } else if (url.startsWith('assets/')) {
      image = Image.asset(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => account());
    } else {
      image = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => index == null ? account() : local(index),
      );
    }
    return Semantics(
      label: AppLocalizations.of(context).commonProfilePicture,
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
