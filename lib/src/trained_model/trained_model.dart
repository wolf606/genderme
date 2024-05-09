import 'dart:async';

Future<Map<String, dynamic>> processAudio(String audioFilePath) async {
  await Future.delayed(const Duration(seconds: 3)); // Mimic processing delay
  return {
    'predicted_age': 'forties',
    'predicted_gender': 'male'
  }; // Return fixed age and gender
}
