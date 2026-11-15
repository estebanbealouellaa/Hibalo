package com.example.hibalo_app

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val decoderThread = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Q09 pronunciation check: decodes a bundled lesson clip (bytes from Dart) to 16-bit PCM.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hibalo/clip_decoder")
            .setMethodCallHandler { call, result ->
                if (call.method != "decode") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) {
                    result.error("bad_args", "no clip bytes", null)
                    return@setMethodCallHandler
                }
                val main = Handler(Looper.getMainLooper())
                decoderThread.execute {
                    try {
                        val pcm = ClipDecoder.decode(bytes)
                        main.post {
                            result.success(
                                mapOf(
                                    "pcm" to pcm.data,
                                    "sampleRate" to pcm.sampleRate,
                                    "channels" to pcm.channels,
                                )
                            )
                        }
                    } catch (e: Exception) {
                        main.post { result.error("decode_failed", e.toString(), null) }
                    }
                }
            }
    }

    override fun onDestroy() {
        decoderThread.shutdown()
        super.onDestroy()
    }
}
