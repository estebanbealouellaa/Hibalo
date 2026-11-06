import '../../l10n/app_localizations.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/v6/v6.dart';

/// Figma 595:4593 "Scan options": a bottom sheet with Take a photo and
/// Choose from gallery. Returns the picked source, or null for Cancel.
Future<ImageSource?> showScanOptions(BuildContext context) {
  final t = AppLocalizations.of(context);
  return showV6BottomSheet<ImageSource>(
    context,
    title: t.trScanPhoto,
    description: t.camSheetBody,
    children: (sheet) => [
      _ScanOption(
        icon: Icons.photo_camera_rounded,
        title: t.commonTakePhoto,
        subtitle: t.camUseCamera,
        onTap: () => Navigator.pop(sheet, ImageSource.camera),
      ),
      const SizedBox(height: 8),
      _ScanOption(
        icon: Icons.photo_library_rounded,
        title: t.commonChooseFromGallery,
        subtitle: t.camPickExisting,
        onTap: () => Navigator.pop(sheet, ImageSource.gallery),
      ),
      const SizedBox(height: 8),
      Center(
        child: V6Button(label: t.commonCancel, style: V6ButtonStyle.text, onPressed: () => Navigator.pop(sheet)),
      ),
    ],
  );
}

class _ScanOption extends StatelessWidget {
  const _ScanOption({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: V6Colors.glowContainerSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: V6Colors.borderDivider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 22, color: V6Colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: V6Text.titleMediumBold),
                    Text(subtitle, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: V6Colors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma 597:4775 "Scanning": the photo, "Reading the text…", a bar and
/// Cancel. It takes the input card's place in Translate.
class ScanningCard extends StatelessWidget {
  const ScanningCard({super.key, required this.photo, required this.onCancel});

  final File? photo;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 260,
              child: photo == null
                  ? const ColoredBox(color: V6Colors.surfaceTint)
                  : Image.file(photo!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.document_scanner_rounded, size: 22, color: V6Colors.primary),
                    const SizedBox(width: 10),
                    Flexible(child: Text(t.camReading, style: V6Text.titleMediumBold)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    minHeight: 8,
                    color: V6Colors.primary,
                    backgroundColor: V6Colors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.camTakesSeconds,
                  style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: V6Button(label: t.commonCancel, style: V6ButtonStyle.text, onPressed: onCancel),
          ),
        ],
      ),
    );
  }
}
