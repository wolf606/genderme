import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer';
import 'package:path/path.dart';

class TfModelProvider with ChangeNotifier {
  late Interpreter _interpreter;
  final String preprocessingServer = 'http://127.0.0.1:5000/spectrogram';
  dynamic _imageArray;
  final List<String> _classes = [
    'F_teens',
    'F_twenties',
    'F_thirties',
    'F_fourties',
    'F_fifties',
    'F_sixties',
    'M_teens',
    'M_twenties',
    'M_thirties',
    'M_fourties',
    'M_fifties',
    'M_sixties'
  ];

  String predictedAge = '';
  String predictedGender = '';
  double confidence = 0.0;

  bool _isError = false;

  bool get isError => _isError;

  // change error state
  void setError(bool value) {
    _isError = value;
    notifyListeners();
  }

  TfModelProvider() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
    } catch (e) {
      log('Failed to load model: $e');
    }
  }

  Future<bool> processAudio(String audioFilePath) async {
    try {
      log('Processing audio file: $audioFilePath');
      _clearPredictions();
      // Load the audio file and send it to the server for preprocessing.
      final audioFile = File(audioFilePath);
      final audioBytes = await audioFile.readAsBytes();

      // Create a multipart request and add the audio file
      var request = http.MultipartRequest('POST', Uri.parse(preprocessingServer));
      request.files.add(http.MultipartFile.fromBytes('audiofile', audioBytes, filename: basename(audioFilePath)));

      // Send the request to the server
      var response = await request.send();
      // Convert the response to a String
      final respStr = await response.stream.bytesToString();

      // Decode the JSON response
      final jsonResponse = jsonDecode(respStr);
      if (jsonResponse['error'] != null) {
        log('Error: ${jsonResponse['error']}');
        throw Exception('Error processing audio');
      }
      // Get the spectrogram from the server
      final spectrogram = jsonResponse['spectrogram'];

      // Model expects a 4D array, for example (1, 240, 240, 3)
      // But the spectrogram is a 3D array, for example (240, 240, 3)
      // So we add an extra dimension to the spectrogram array
      _imageArray = [spectrogram];
      notifyListeners();
      return true;
    } catch (e) {
      log('FUCK: $e');
      return false;
    }
  }

  Future<bool> predict() async {
    try {
      //var output = List.filled(1*2, 0).reshape([1,2]);
      //model outputs a list with 12 of the result of a softmax function
      var output = List.filled(1*12, 0).reshape([1,12]);

      _interpreter.run(_imageArray, output);

      // Get the index of the maximum value in the output list
      final index = output[0].indexOf(output[0].reduce((double curr, double next) => curr > next? curr: next));
      
      // Get
      predictedAge = _classes[index].split('_')[1];
      predictedGender = _classes[index].split('_')[0] == 'F' ? 'female' : 'male';
      confidence = output[0][index];
      notifyListeners();
      return true;
    } catch (e) {
      log('Error predicting: $e');
      return false;
    }
  }

  _clearPredictions() {
    predictedAge = '';
    predictedGender = '';
    confidence = 0.0;
    notifyListeners();
  }
}
