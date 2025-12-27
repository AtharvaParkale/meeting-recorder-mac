import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/presentation/bloc/recorder_bloc.dart';

class RecorderPage extends StatelessWidget {
  const RecorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<RecorderBloc, RecorderState>(
          builder: (context, state) {
            final isRecording = (state as RecordingState).isRecording;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 56,
                  icon: Icon(
                    isRecording
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  onPressed: () {
                    context.read<RecorderBloc>().add(ToggleEvent());
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  isRecording ? 'Recording…' : 'Tap to start recording',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
