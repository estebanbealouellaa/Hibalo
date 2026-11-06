import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'offline_translator.dart';
import 'text_rules.dart';

/// Photo text: ML Kit reads it, each line or sentence is translated by the offline model (Firestore only as fallback).

/// The text in a photo, and the pieces it is translated in.
class PhotoText {
  const PhotoText(this.text, this.segments);

  final String text;
  final List<String> segments;
}

/// Reads the text in [image] with ML Kit (Latin script).
Future<PhotoText> readPhotoText(File image) async {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final recognizedText = await textRecognizer.processImage(InputImage.fromFile(image));
    return PhotoText(
      recognizedText.text,
      scanSegments([
        for (final block in recognizedText.blocks) [for (final line in block.lines) line.text],
      ]),
    );
  } finally {
    await textRecognizer.close();
  }
}

class ScanTranslation {
  const ScanTranslation(this.text, this.isDictionaryMeaning);

  final String text;
  final bool isDictionaryMeaning;
}

/// Translates a scan piece by piece; [onPartial] gets the text so far.
/// [isStale] stops early when a newer request replaced this one.
Future<ScanTranslation?> translateScan({
  required String fullText,
  required List<String> segments,
  required bool fromHiligaynon,
  required void Function(String textSoFar) onPartial,
  required bool Function() isStale,
}) async {
  if (segments.isEmpty) return const ScanTranslation('', false);
  var isDictionaryMeaning = false;
  try {
    // One line of the result for each piece of the scan.
    final done = <String>[];
    for (final segment in segments) {
      final result = await OfflineTranslator.instance.translate(
        segment,
        fromHiligaynon: fromHiligaynon,
        partOfParagraph: segments.length >= 2,
        onPartial: (textSoFar) {
          if (isStale()) return;
          onPartial([...done, textSoFar].join('\n'));
        },
      );
      if (isStale()) return null;
      done.add(result.text);
      isDictionaryMeaning = segments.length == 1 && result.isDictionaryMeaning;
      onPartial(done.join('\n'));
    }
    return ScanTranslation(done.join('\n'), isDictionaryMeaning);
  } catch (e) {
    debugPrint('[HibaloTranslate] using Firestore instead: $e');
    final text = await _firestoreTranslate(fullText);
    return ScanTranslation(text, false);
  }
}

/// Lowercase, no punctuation except - ' ? (Firestore entries like "sud-an", "gab-i", "diin kita makadto?").
String _clean(String text) {
  return text.toLowerCase().replaceAll(RegExp(r"[^\w\s\-?']"), '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Low-level Firestore lookup: checks hil→fil then fil→hil for an exact phrase.
Future<String?> _firestoreLookup(String phrase) async {
  final hilSnap = await FirebaseFirestore.instance
      .collection('translations')
      .where('hil', isEqualTo: phrase)
      .limit(1)
      .get();
  if (hilSnap.docs.isNotEmpty) {
    return hilSnap.docs.first['fil'] as String?;
  }

  final filSnap = await FirebaseFirestore.instance
      .collection('translations')
      .where('fil', isEqualTo: phrase)
      .limit(1)
      .get();
  if (filSnap.docs.isNotEmpty) {
    return filSnap.docs.first['hil'] as String?;
  }

  return null;
}

/// Firestore match with OCR-tolerant fallbacks: as-is, without end punctuation, then with "?" added.
Future<String?> _lookupPhrase(String phrase) async {
  String? result = await _firestoreLookup(phrase);
  if (result != null) return result;

  final stripped = phrase.replaceAll(RegExp(r'[?!.,]+$'), '').trim();
  if (stripped != phrase) {
    result = await _firestoreLookup(stripped);
    if (result != null) return result;
  }

  result = await _firestoreLookup('$phrase?');
  return result;
}

Future<String> _firestoreTranslate(String text) async {
  try {
    final cleaned = _clean(text);

    final fullMatch = await _lookupPhrase(cleaned);
    if (fullMatch != null) return fullMatch;

    final lines = cleaned.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (lines.length > 1) {
      final translatedLines = <String>[];
      for (final line in lines) {
        final lineMatch = await _lookupPhrase(line);
        if (lineMatch != null) {
          translatedLines.add(lineMatch);
        } else {
          translatedLines.add(await _translateWordByWord(line));
        }
      }
      return translatedLines.join('\n');
    }

    return await _translateWordByWord(cleaned);
  } catch (e) {
    return 'Translation error: $e';
  }
}

Future<String> _translateWordByWord(String cleaned) async {
  final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();
  final result = <String>[];

  for (final word in words) {
    final match = await _lookupPhrase(word);
    result.add(match ?? word);
  }

  return result.join(' ');
}
