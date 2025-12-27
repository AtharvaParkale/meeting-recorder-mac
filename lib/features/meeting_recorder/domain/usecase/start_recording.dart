import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class StartRecording {
  final RecorderRepository repository;

  StartRecording(this.repository);

  Future<void> call() {
    return repository.startRecording();
  }
}