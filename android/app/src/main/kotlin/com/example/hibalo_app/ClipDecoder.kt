package com.example.hibalo_app

import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaDataSource
import android.media.MediaExtractor
import android.media.MediaFormat
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** Decodes a compressed clip (the lesson .m4a files) in memory with Android's MediaCodec. */
object ClipDecoder {
    class Pcm(val data: ByteArray, val sampleRate: Int, val channels: Int)

    private const val TIMEOUT_US = 10_000L
    private const val MAX_IDLE_LOOPS = 500 // ~5 s without progress = give up

    fun decode(bytes: ByteArray): Pcm {
        val extractor = MediaExtractor()
        var codec: MediaCodec? = null
        try {
            extractor.setDataSource(ByteSource(bytes))
            var track = -1
            for (i in 0 until extractor.trackCount) {
                val mime = extractor.getTrackFormat(i).getString(MediaFormat.KEY_MIME) ?: continue
                if (mime.startsWith("audio/")) {
                    track = i
                    break
                }
            }
            require(track >= 0) { "no audio track" }
            extractor.selectTrack(track)
            val format = extractor.getTrackFormat(track)
            var sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            var floatPcm = false

            codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
            codec.configure(format, null, null, 0)
            codec.start()

            val out = ByteArrayOutputStream()
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            var idle = 0
            while (true) {
                var progressed = false
                if (!inputDone) {
                    val inIndex = codec.dequeueInputBuffer(TIMEOUT_US)
                    if (inIndex >= 0) {
                        val buffer = codec.getInputBuffer(inIndex)!!
                        val size = extractor.readSampleData(buffer, 0)
                        if (size < 0) {
                            codec.queueInputBuffer(inIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(inIndex, 0, size, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                        progressed = true
                    }
                }
                val outIndex = codec.dequeueOutputBuffer(info, TIMEOUT_US)
                if (outIndex >= 0) {
                    val buffer = codec.getOutputBuffer(outIndex)!!
                    if (info.size > 0) {
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        if (floatPcm) writeFloatAs16(buffer, out) else {
                            val chunk = ByteArray(info.size)
                            buffer.get(chunk)
                            out.write(chunk)
                        }
                    }
                    codec.releaseOutputBuffer(outIndex, false)
                    progressed = true
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
                } else if (outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val f = codec.outputFormat
                    sampleRate = f.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                    channels = f.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    floatPcm = f.containsKey(MediaFormat.KEY_PCM_ENCODING) &&
                        f.getInteger(MediaFormat.KEY_PCM_ENCODING) == AudioFormat.ENCODING_PCM_FLOAT
                    progressed = true
                }
                idle = if (progressed) 0 else idle + 1
                require(idle < MAX_IDLE_LOOPS) { "decoder stalled" }
            }
            // Native byte order on Android phones is little-endian, as Dart reads it.
            return Pcm(out.toByteArray(), sampleRate, channels)
        } finally {
            try { codec?.stop() } catch (_: Exception) {}
            try { codec?.release() } catch (_: Exception) {}
            extractor.release()
        }
    }

    private fun writeFloatAs16(buffer: ByteBuffer, out: ByteArrayOutputStream) {
        val floats = buffer.order(ByteOrder.nativeOrder()).asFloatBuffer()
        val chunk = ByteBuffer.allocate(floats.remaining() * 2).order(ByteOrder.LITTLE_ENDIAN)
        while (floats.hasRemaining()) {
            val v = (floats.get().coerceIn(-1f, 1f) * 32767f).toInt()
            chunk.putShort(v.toShort())
        }
        out.write(chunk.array())
    }

    /** Lets MediaExtractor read the clip straight from memory (no temp file). */
    private class ByteSource(private val bytes: ByteArray) : MediaDataSource() {
        override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
            if (position >= bytes.size) return -1
            val n = minOf(size.toLong(), bytes.size - position).toInt()
            System.arraycopy(bytes, position.toInt(), buffer, offset, n)
            return n
        }

        override fun getSize(): Long = bytes.size.toLong()

        override fun close() {}
    }
}
