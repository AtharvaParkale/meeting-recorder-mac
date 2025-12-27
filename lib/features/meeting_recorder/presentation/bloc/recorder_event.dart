part of 'recorder_bloc.dart';

@immutable
sealed class RecorderEvent {}

class ToggleEvent extends RecorderEvent {}
final class ToggleSystemAudio extends RecorderEvent {}
final class ToggleMicAudio extends RecorderEvent {}
