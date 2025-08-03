import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();

  factory TTSService() => _instance;

  late FlutterTts _flutterTts;

  TTSService._internal();

  Future<void> initTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("it-IT");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
