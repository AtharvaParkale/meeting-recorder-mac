import 'package:flutter/services.dart';

class SystemAudioDataSource {
  static const MethodChannel _channel = MethodChannel('system_audio');

  Future<void> start() async {
    await _channel.invokeMethod('start');
  }

  Future<String?> stop() async {
    return await _channel.invokeMethod<String>('stop');
  }
}