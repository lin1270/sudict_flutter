import 'package:just_audio/just_audio.dart';

// Feed your own stream of bytes into the player
class _MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  _MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class FishAudioPlayer extends AudioPlayer {
  Future<Duration?> setBytes(List<int> bytes) {
    return setAudioSource(_MyCustomSource(bytes));
  }

  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    final audioSource = LockCachingAudioSource(Uri.parse(url), headers: headers);
    return await setAudioSource(
      audioSource,
      preload: preload,
      initialPosition: initialPosition,
    );
  }
}
