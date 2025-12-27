import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class StopRecording {
  final RecorderRepository repository;

  StopRecording(this.repository);

  Future<String?> call() {
    return repository.stopRecording();
  }
}