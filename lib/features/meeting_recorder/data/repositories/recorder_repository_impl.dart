

import 'package:meeting_recorder/features/meeting_recorder/data/datasource/audio_datasource.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class RecorderRepositoryImpl implements RecorderRepository {
  final SystemAudioDataSource dataSource;

  RecorderRepositoryImpl(this.dataSource);

  @override
  Future<void> startRecording() {
    return dataSource.start();
  }

  @override
  Future<String?> stopRecording() {
    return dataSource.stop();
  }
}