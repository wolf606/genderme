import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechProvider with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  TextToSpeechProvider() {
    _flutterTts.setLanguage('en-US');
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
