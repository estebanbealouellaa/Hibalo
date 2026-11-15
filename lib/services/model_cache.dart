import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// flutter_onnxruntime opens a bundled model by copying it from the APK into the app's
/// cache folder. Once the session is open, ONNX Runtime has the model in memory, so the
/// copy is deleted (MainActivity.kt, channel "hibalo/model_cache"): the models then sit
/// only in the APK instead of twice on the phone. The next app start copies them again.
class ModelCache {
  ModelCache._();

  static const MethodChannel _channel = MethodChannel('hibalo/model_cache');

  /// Deletes the cached copy of [assetKey] ("assets/…/model.onnx"). Never throws.
  static Future<void> dropCopy(String assetKey) async {
    if (kIsWeb) return;
    try {
      final freed = await _channel.invokeMethod<int>('delete', {'name': assetKey.split('/').last});
      debugPrint('[ModelCache] deleted the cached copy of ${assetKey.split('/').last} (${(freed ?? 0) ~/ 1000000} MB)');
    } catch (e) {
      debugPrint('[ModelCache] could not delete the cached copy of $assetKey: $e');
    }
  }
}
