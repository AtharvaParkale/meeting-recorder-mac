import 'package:flutter/services.dart';


class SystemAudioChannel {
  static const _channel = MethodChannel('system_audio');

  Future<void> start() async {
    await _channel.invokeMethod('start');
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}