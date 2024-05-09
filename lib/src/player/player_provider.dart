import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:developer';

class PlayerProvider with ChangeNotifier {
  final PlayerController _controller = PlayerController();

  PlayerController get controller => _controller;

  String _state = 'stopped';

  String get state => _state;

  PlayerProvider() {
    _controller.updateFrequency = UpdateFrequency.low;

    _controller.onPlayerStateChanged.listen((state) {
      _state = state.toString().split('.').last;
      notifyListeners();
    });

    _controller.onCurrentDurationChanged.listen((duration) {
      // Handle current duration updates here
    });

    _controller.onCurrentExtractedWaveformData.listen((data) {
      // Handle latest extraction data updates here
    });

    _controller.onExtractionProgress.listen((progress) {
      // Handle extraction progress updates here
    });

    _controller.onCompletion.listen((_) {
      _controller.stopPlayer();
      notifyListeners();
    });
  }

  Future<void> startPlaying(String path) async {
    try {
      // Stop the player if it's currently playing
      if (_controller.playerState == PlayerState.playing) {
        await _controller.stopPlayer();
      }

      // Prepare the player
      if (_controller.playerState == PlayerState.stopped) {
        await _controller.preparePlayer(
          path: path,
          shouldExtractWaveform: true,
          noOfSamples: 100,
          volume: 1.0,
        );
      }

      // Start the player
      await _controller.startPlayer(finishMode: FinishMode.stop);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
