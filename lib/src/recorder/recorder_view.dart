import 'package:flutter/material.dart';
import 'recorder_provider.dart';
import 'package:provider/provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../recordings/recordings_provider.dart';
import '../recordings/recording.dart';
import '../player/player_provider.dart';
import '../trained_model/trained_model_provider.dart';
import '../tts/tts_provider.dart';
import '../tab_provider.dart';
import 'dart:ui';

class RecorderView extends StatelessWidget {
  const RecorderView({super.key});

  static const routeName = '/recordings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record your voice',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: const Center(
          child: SizedBox(
        child: RecordingWidget(),
      )),
    );
  }
}

class RecordingWidget extends StatefulWidget {
  const RecordingWidget({super.key});

  @override
  RecordingWidgetState createState() => RecordingWidgetState();
}

class RecordingWidgetState extends State<RecordingWidget> {
  @override
  Widget build(BuildContext context) {
    final recorderProvider = Provider.of<RecorderProvider>(context);
    final recordingsProvider = Provider.of<RecordingsProvider>(context);
    final tabProvider = Provider.of<TabControllerProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final TfModelProvider tfModelProvider =
        Provider.of<TfModelProvider>(context);
    final TextToSpeechProvider ttsProvider =
        Provider.of<TextToSpeechProvider>(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double top = (constraints.maxHeight - 100) /
            2; // Calculate the top position for centering

        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: recorderProvider.isRecording ? top - 100 : top - 20,
              child: SizedBox(
                width: 100,
                height: 100,
                child: FloatingActionButton(
                  heroTag: 'record',
                  onPressed: () async {
                    if (recorderProvider.isRecording) {
                      recorderProvider
                          .setLoading(true); // Show the loading dialog
                      await recorderProvider.stopRecording(context);
                      recorderProvider.setRecording(false);
                      final result = await tfModelProvider
                          .processAudio(recorderProvider.currentPath ?? '');

                      if (result) {
                        final didIt = await tfModelProvider.predict();
                        if (didIt) {
                          recorderProvider
                              .setPredictedAge(tfModelProvider.predictedAge);
                          recorderProvider.setPredictedGender(
                              tfModelProvider.predictedGender);

                          recorderProvider
                              .setActualAge(tfModelProvider.predictedAge);
                          recorderProvider
                              .setActualGender(tfModelProvider.predictedGender);
                          recorderProvider.setLoading(false);
                          recorderProvider.setChecking(true);

                          //wait 2 seconds before speaking
                          await Future.delayed(
                              const Duration(milliseconds: 500));

                          await ttsProvider.speak(generateTttsString(
                              tfModelProvider.predictedAge,
                              tfModelProvider.predictedGender));
                        } else {
                          recorderProvider.setLoading(false);
                          tfModelProvider.setError(true);
                        }
                      } else {
                        recorderProvider.setChecking(false);
                        recorderProvider.setLoading(false);
                        tfModelProvider.setError(true);
                      }
                    } else {
                      await recorderProvider.startRecording();
                      recorderProvider.setRecording(true);
                    }
                  },
                  shape: const CircleBorder(),
                  child: Icon(
                      recorderProvider.isRecording
                          ? Icons.stop
                          : Icons.mic_rounded,
                      size: 50),
                ),
              ),
            ),
            AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: recorderProvider.isRecording ? top - 20 : -100,
                child: AudioWaveforms(
                    size: const Size(300, 100),
                    recorderController: recorderProvider.controller,
                    enableGesture: false,
                    waveStyle: WaveStyle(
                      showDurationLabel: true,
                      spacing: 8.0,
                      showBottom: true,
                      extendWaveform: true,
                      showMiddleLine: false,
                      waveColor: Theme.of(context).hintColor,
                      durationLinesColor: Colors.deepPurple.shade400,
                      durationStyle: TextStyle(
                        color: Colors.deepPurple.shade400,
                        fontSize: 16,
                      ),
                    ))),
            if (tfModelProvider.isError)
              BackdropFilter(
                //Button to close the error dialog
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AlertDialog(
                  title: const Text('Error processing audio'),
                  content: const Text('Please try again'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        tfModelProvider.setError(false);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            if (recorderProvider.isLoading)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: const AlertDialog(
                  title: Text('Processing audio'),
                  content: LinearProgressIndicator(),
                ),
              ),
            if (recorderProvider.isChecking)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AlertDialog(
                    contentPadding: const EdgeInsets.all(0),
                    // dropdowns for actual age and actual gender
                    title: const Text('Checking prediction accuracy'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              heroTag: 'play',
                              shape: const CircleBorder(),
                              onPressed: () async {
                                if (playerProvider.state ==
                                    PlayerState.playing
                                        .toString()
                                        .split('.')
                                        .last) {
                                  await playerProvider.controller.pausePlayer();
                                } else if (playerProvider.state ==
                                    PlayerState.stopped
                                        .toString()
                                        .split('.')
                                        .last) {
                                  await playerProvider.startPlaying(
                                      recorderProvider.currentPath ?? '');
                                } else {
                                  await playerProvider.controller
                                      .startPlayer(finishMode: FinishMode.stop);
                                }
                              },
                              child: Icon(playerProvider.state ==
                                      PlayerState.playing
                                          .toString()
                                          .split('.')
                                          .last
                                  ? Icons.pause
                                  : Icons.play_arrow),
                            ),
                            AudioFileWaveforms(
                              size: const Size(200, 100),
                              playerController: playerProvider.controller,
                              playerWaveStyle: PlayerWaveStyle(
                                  fixedWaveColor: Theme.of(context).hintColor,
                                  liveWaveColor: Colors.deepPurple.shade400,
                                  seekLineColor: Theme.of(context).hintColor),
                              enableSeekGesture: true,
                              waveformType: WaveformType.long,
                            )
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 150,
                                height: 50,
                                child: ListTile(
                                  title: Text(
                                      recorderProvider.predictedGender ?? ''),
                                  leading: (recorderProvider.predictedGender ==
                                          'male')
                                      ? Icon(
                                          Icons.male,
                                          color: Theme.of(context).hintColor,
                                        )
                                      : Icon(
                                          Icons.female,
                                          color: Theme.of(context).hintColor,
                                        ),
                                )),
                            SizedBox(
                                width: 150,
                                height: 50,
                                child: ListTile(
                                  title:
                                      Text(recorderProvider.predictedAge ?? ''),
                                  leading: const Icon(Icons.person),
                                ))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text('Select actual age and gender',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Age: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 100,
                                    child: DropdownButton<String>(
                                      value: recorderProvider.actualAge,
                                      items: <String>[
                                        'teens',
                                        'twenties',
                                        'thirties',
                                        'fourties',
                                        'fifties',
                                        'sixties',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        recorderProvider
                                            .setActualAge(value ?? '');
                                      },
                                      isExpanded: true,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Gender: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 100,
                                    child: DropdownButton<String>(
                                      value: recorderProvider.actualGender,
                                      items: <String>['male', 'female']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        recorderProvider
                                            .setActualGender(value ?? '');
                                      },
                                      isExpanded: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                recorderProvider.setLoading(true);
                                recorderProvider.setChecking(false);
                                final recording = Recording(
                                    null,
                                    recorderProvider.currentPath ?? '',
                                    DateTime.now(),
                                    recorderProvider.predictedAge ?? '',
                                    recorderProvider.predictedGender ?? '',
                                    recorderProvider.actualAge ?? '',
                                    recorderProvider.actualGender ?? '');

                                await recordingsProvider
                                    .insertRecording(recording);
                                recorderProvider.cleanUp();
                                recorderProvider.setLoading(false);
                                tabProvider.changeTab(1);
                              },
                              child: const Text('Submit'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                recorderProvider.setChecking(false);
                                recorderProvider.cleanUp();
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
          ],
        );
      },
    );
  }

  generateTttsString(String predictedAge, String predictedGender) {
    if (predictedGender == 'male') {
      return 'A $predictedGender in her $predictedAge';
    } else {
      return 'A $predictedGender in his $predictedAge';
    }
  }
}
