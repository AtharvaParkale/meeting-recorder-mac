import 'package:meeting_recorder/features/meeting_recorder/data/datasource/system_audio_channel.dart';
import 'package:meeting_recorder/features/meeting_recorder/data/datasource/mic_audio_channel.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class RecorderRepositoryImpl implements RecorderRepository {
  final SystemAudioChannel systemAudioChannel;
  final MicAudioChannel micAudioChannel;

  RecorderRepositoryImpl({
    required this.systemAudioChannel,
    required this.micAudioChannel,
  });

  @override
  Future<void> startSystemAudio() {
    return systemAudioChannel.start();
  }

  @override
  Future<void> stopSystemAudio() {
    return systemAudioChannel.stop();
  }

  @override
  Future<void> startMicAudio() {
    return micAudioChannel.start();
  }

  @override
  Future<void> stopMicAudio() {
    return micAudioChannel.stop();
  }
}
