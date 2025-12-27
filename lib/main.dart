import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/data/datasource/audio_datasource.dart';
import 'package:meeting_recorder/features/meeting_recorder/data/repositories/recorder_repository_impl.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/start_recording.dart';
import 'package:meeting_recorder/features/meeting_recorder/domain/usecase/stop_recording.dart';
import 'package:meeting_recorder/features/meeting_recorder/presentation/bloc/recorder_bloc.dart';
import 'package:meeting_recorder/features/meeting_recorder/presentation/pages/home_screen.dart';

void main() {
  final dataSource = SystemAudioDataSource();
  final repository = RecorderRepositoryImpl(dataSource);

  runApp(
    MyApp(
      recorderBloc: RecorderBloc(
        startRecording: StartRecording(repository),
        stopRecording: StopRecording(repository),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final RecorderBloc recorderBloc;

  const MyApp({super.key, required this.recorderBloc});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider.value(
        value: recorderBloc,
        child: const RecorderPage(),
      ),
    );
  }
}
