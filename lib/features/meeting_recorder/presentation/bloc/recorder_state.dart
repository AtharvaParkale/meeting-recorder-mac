part of 'recorder_bloc.dart';

@immutable
sealed class RecorderState {}

final class RecorderInitial extends RecorderState {}

final class RecordingState extends RecorderState {
  final bool isSystemRecording;
  final bool isMicRecording;

   RecordingState({
    required this.isSystemRecording,
    required this.isMicRecording,
  });
}
