import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/start_mic_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/start_system_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/stop_mic_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/stop_system_audio.dart';
import 'package:meta/meta.dart';

part 'recorder_event.dart';

part 'recorder_state.dart';

class RecorderBloc extends Bloc<RecorderEvent, RecorderState> {
  final StartSystemAudio startSystemAudio;
  final StopSystemAudio stopSystemAudio;
  final StartMicAudio startMicAudio;
  final StopMicAudio stopMicAudio;

  RecorderBloc({
    required this.startSystemAudio,
    required this.stopSystemAudio,
    required this.startMicAudio,
    required this.stopMicAudio,
  }) : super(RecordingState(isSystemRecording: false, isMicRecording: false)) {
    on<ToggleSystemAudio>(_toggleSystem);
    on<ToggleMicAudio>(_toggleMic);
  }

  Future<void> _toggleSystem(
    ToggleSystemAudio event,
    Emitter<RecorderState> emit,
  ) async {
    final state = this.state as RecordingState;

    if (!state.isSystemRecording) {
      await startSystemAudio();
      emit(
        RecordingState(
          isSystemRecording: true,
          isMicRecording: state.isMicRecording,
        ),
      );
    } else {
      await stopSystemAudio();
      emit(
        RecordingState(
          isSystemRecording: false,
          isMicRecording: state.isMicRecording,
        ),
      );
    }
  }

  Future<void> _toggleMic(
    ToggleMicAudio event,
    Emitter<RecorderState> emit,
  ) async {
    final state = this.state as RecordingState;

    if (!state.isMicRecording) {
      await startMicAudio();
      emit(
        RecordingState(
          isSystemRecording: state.isSystemRecording,
          isMicRecording: true,
        ),
      );
    } else {
      await stopMicAudio();
      emit(
        RecordingState(
          isSystemRecording: state.isSystemRecording,
          isMicRecording: false,
        ),
      );
    }
  }
}
