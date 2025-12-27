abstract class RecorderRepository {
  Future<void> startSystemAudio();
  Future<void> stopSystemAudio();

  Future<void> startMicAudio();
  Future<void> stopMicAudio();
}