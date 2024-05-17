import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';
import 'dart:io';

class RecorderProvider with ChangeNotifier {
  final RecorderController _controller = RecorderController();
  String? _currentPath;
  bool _isRecording = false;
  bool _isLoading = false;
  bool _isChecking = false;

  String? _predictedAge;
  String? _predictedGender;
  String? _actualAge;
  String? _actualGender;

  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;

  String? get predictedAge => _predictedAge;
  String? get predictedGender => _predictedGender;
  String? get actualAge => _actualAge;
  String? get actualGender => _actualGender;

  RecorderController get controller => _controller;
  String? get currentPath => _currentPath;

  RecorderProvider() {
    _controller.updateFrequency = const Duration(milliseconds: 100);
    _controller.androidEncoder = AndroidEncoder.aac;
    _controller.androidOutputFormat = AndroidOutputFormat.mpeg4;
    _controller.iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;
    _controller.sampleRate = 16000;
    _controller.bitRate = 48000;

    _controller.onRecorderStateChanged.listen((state) {
      // Handle recorder state changes here
    });

    _controller.onCurrentDuration.listen((duration) {
      // Handle current duration updates here
    });

    _controller.onRecordingEnded.listen((duration) {
      // Handle recording ended event here
    });
  }

  void setRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setChecking(bool value) {
    _isChecking = value;
    notifyListeners();
  }

  void setPredictedAge(String value) {
    _predictedAge = value;
    notifyListeners();
  }

  void setPredictedGender(String value) {
    _predictedGender = value;
    notifyListeners();
  }

  void setActualAge(String value) {
    _actualAge = value;
    notifyListeners();
  }

  void setActualGender(String value) {
    _actualGender = value;
    notifyListeners();
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await _controller.checkPermission();
      if (hasPermission) {
        Directory dir = await getApplicationDocumentsDirectory();
        String fileName =
            'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _currentPath = '${dir.path}/$fileName';
        await _controller.record(path: _currentPath);
      } else {
        throw Exception('Permission to record not granted');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> stopRecording(BuildContext context) async {
    try {
      await _controller.stop();
      if (_currentPath != null) {
        log('Recording stopped. Path: $_currentPath');
      } else {
        throw Exception('Current path is null');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void cleanUp() {
    _currentPath = null;
    _predictedAge = null;
    _predictedGender = null;
    _actualAge = null;
    _actualGender = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
