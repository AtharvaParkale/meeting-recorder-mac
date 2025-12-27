import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class StartMicAudio {
  final RecorderRepository repository;
  StartMicAudio(this.repository);

  Future<void> call() => repository.startMicAudio();
}