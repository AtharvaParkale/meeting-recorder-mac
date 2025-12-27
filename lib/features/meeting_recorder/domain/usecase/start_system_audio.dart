import 'package:meeting_recorder/features/meeting_recorder/domain/repository/recorder_repository.dart';

class StartSystemAudio {
  final RecorderRepository repository;
  StartSystemAudio(this.repository);

  Future<void> call() => repository.startSystemAudio();
}