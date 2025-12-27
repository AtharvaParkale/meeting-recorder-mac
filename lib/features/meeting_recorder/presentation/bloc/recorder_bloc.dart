import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/start_recording.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/stop_recording.dart';
import 'package:meta/meta.dart';

part 'recorder_event.dart';

part 'recorder_state.dart';

class RecorderBloc extends Bloc<RecorderEvent, RecorderState> {
  final StartRecording startRecording;
  final StopRecording stopRecording;

  RecorderBloc({required this.startRecording, required this.stopRecording})
    : super(RecordingState(false)) {
    on<ToggleEvent>(_onToggle);
  }

  Future<void> _onToggle(ToggleEvent event, Emitter<RecorderState> emit) async {
    final current = state as RecordingState;

    if (!current.isRecording) {
      await startRecording();
      emit(RecordingState(true));
    } else {
      await stopRecording();
      emit(RecordingState(false));
    }
  }
}
