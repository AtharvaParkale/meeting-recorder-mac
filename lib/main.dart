import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/data/datasource/mic_audio_channel.dart';
import 'package:meeting_recorder/features/meeting_recorder/data/datasource/system_audio_channel.dart';
import 'package:meeting_recorder/features/meeting_recorder/data/repositories/recorder_repository_impl.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/start_mic_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/start_system_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/stop_mic_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/stop_system_audio.dart';
import 'package:meeting_recorder/features/meeting_recorder/presentation/bloc/recorder_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/presentation/pages/home_screen.dart';

void main() {
  // 🔌 Data layer
  final systemAudioChannel = SystemAudioChannel();
  final micAudioChannel = MicAudioChannel();

  final repository = RecorderRepositoryImpl(
    systemAudioChannel: systemAudioChannel,
    micAudioChannel: micAudioChannel,
  );

  // 🎯 Domain layer (use cases)
  final startSystemAudio = StartSystemAudio(repository);
  final stopSystemAudio = StopSystemAudio(repository);
  final startMicAudio = StartMicAudio(repository);
  final stopMicAudio = StopMicAudio(repository);

  // 🧠 Presentation layer (Bloc)
  final recorderBloc = RecorderBloc(
    startSystemAudio: startSystemAudio,
    stopSystemAudio: stopSystemAudio,
    startMicAudio: startMicAudio,
    stopMicAudio: stopMicAudio,
  );

  runApp(MyApp(recorderBloc: recorderBloc));
}

class MyApp extends StatelessWidget {
  final RecorderBloc recorderBloc;

  const MyApp({super.key, required this.recorderBloc});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider.value(value: recorderBloc, child: const HomeScreen()),
    );
  }
}
