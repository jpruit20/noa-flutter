import 'package:flutter/foundation.dart';
import 'package:noa_api/noa_api.dart'; // adjust import as needed
import 'dart:async';

class WhisperCaptionService {
  final _bleManager = BleManager();

  Future<void> sendCaption(String text) async {
    try {
      await _bleManager.sendTextToFrame(
        text: text,
        position: FrameTextPosition.bottom,
        size: FrameTextSize.medium,
      );
    } catch (e) {
      debugPrint("[WhisperCaption] Error sending to frame: $e");
    }
  }

  Future<void> start() async {
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      // 👇 Replace this line with actual Whisper inference
      await sendCaption("This is a test caption.");
    }
  }
}
