import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';


class StopSystemAudio {
  final RecorderRepository repository;
  StopSystemAudio(this.repository);

  Future<void> call() => repository.stopSystemAudio();
}