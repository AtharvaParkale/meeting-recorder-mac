import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class StopMicAudio {
  final RecorderRepository repository;

  StopMicAudio(this.repository);

  Future<void> call() => repository.stopMicAudio();
}
