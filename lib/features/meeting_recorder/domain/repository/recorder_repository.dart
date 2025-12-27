abstract class RecorderRepository {
  Future<void> startRecording();
  Future<String?> stopRecording();
}