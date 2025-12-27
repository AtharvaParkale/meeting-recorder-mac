import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/presentation/bloc/recorder_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<RecorderBloc, RecorderState>(
          builder: (context, state) {
            final recording = state as RecordingState;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 56,
                  icon: Icon(
                    recording.isSystemRecording
                        ? Icons.pause_circle
                        : Icons.volume_up,
                  ),
                  onPressed: () {
                    context.read<RecorderBloc>().add(ToggleSystemAudio());
                  },
                ),
                const Text("System Audio (Google Meet)"),

                const SizedBox(height: 24),

                IconButton(
                  iconSize: 56,
                  icon: Icon(
                    recording.isMicRecording ? Icons.pause_circle : Icons.mic,
                  ),
                  onPressed: () {
                    context.read<RecorderBloc>().add(ToggleMicAudio());
                  },
                ),
                const Text("Microphone"),
              ],
            );
          },
        ),
      ),
    );
  }
}
