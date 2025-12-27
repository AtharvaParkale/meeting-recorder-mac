part of 'recorder_bloc.dart';

@immutable
sealed class RecorderEvent {}

class ToggleEvent extends RecorderEvent {}
