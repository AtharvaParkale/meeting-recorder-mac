import 'package:flutter/services.dart' show MethodChannel;


class MicAudioChannel {
  static const _channel = MethodChannel('mic_audio');

  Future<void> start() async {
    await _channel.invokeMethod('start');
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}
