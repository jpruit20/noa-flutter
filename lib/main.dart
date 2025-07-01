import 'package:audio_session/audio_session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:frame_ble/brilliant_bluetooth.dart';
import 'package:noa/pages/splash.dart';
import 'package:noa/util/app_log.dart';
import 'package:noa/util/foreground_service.dart';
import 'package:noa/util/location.dart';
import 'whisper_caption_service.dart;

final globalPageStorageBucket = PageStorageBucket();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final whisper = WhisperCaptionService();
  whisper.start(); // launch captioning loop
  runApp(MyApp());
  // Load environment variables
  await dotenv.load();

  // Start logging
  final container = ProviderContainer();
  container.read(appLog);

  // Set up Android foreground service
  initializeForegroundService();

  // Request bluetooth permission
  BrilliantBluetooth.requestPermission();

  // Start location stream
  Location.startLocationStream();

  _setupAudioSession();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MainApp(),
  ));
}

void _setupAudioSession() {
  AudioSession.instance.then((audioSession) async {
    await audioSession.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.assistant,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    audioSession.setActive(true);
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    startForegroundService();
    return const WithForegroundTask(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    ));
  }
}
