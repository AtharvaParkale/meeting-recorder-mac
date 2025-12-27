part of 'recorder_bloc.dart';

@immutable
sealed class RecorderState {}

final class RecorderInitial extends RecorderState {}

class RecordingState extends RecorderState {
  final bool isRecording;

  RecordingState(this.isRecording);
}
