import 'package:flutter/material.dart';
import 'recorder_provider.dart';
import 'package:provider/provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../trained_model/trained_model.dart';
import '../recordings/recordings_provider.dart';
import '../recordings/recording.dart';
import '../tab_provider.dart';
import 'dart:ui';
import 'dart:developer';

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
                  onPressed: () async {
                    if (recorderProvider.isRecording) {
                      recorderProvider
                          .setLoading(true); // Show the loading dialog
                      await recorderProvider.stopRecording(context);
                      recorderProvider.setRecording(false);
                      final result = await processAudio(
                          recorderProvider.currentPath ?? '');

                      recorderProvider.setPredictedAge(result['predicted_age']);
                      recorderProvider
                          .setPredictedGender(result['predicted_gender']);

                      recorderProvider.setActualAge(result['predicted_age']);
                      recorderProvider
                          .setActualGender(result['predicted_gender']);

                      recorderProvider.setLoading(false);
                      recorderProvider.setChecking(true);
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
                      showBottom: false,
                      extendWaveform: true,
                      showMiddleLine: false,
                      waveColor: Theme.of(context).hintColor,
                      durationLinesColor: Colors.purple.shade200,
                      durationStyle: TextStyle(
                        color: Colors.purple.shade200,
                        fontSize: 16,
                      ),
                    ))),
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
                    // dropdowns for actual age and actual gender
                    title: const Text('Checking prediction accuracy'),
                    content: Column(
                      children: [
                        const Text('Select actual age and gender'),
                        DropdownButton<String>(
                          value: recorderProvider.actualAge,
                          items: <String>[
                            'teens',
                            'twenties',
                            'thirties',
                            'forties',
                            'fifties',
                            'sixties',
                            'seventies',
                            'eighties',
                            'nineties',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            recorderProvider.setActualAge(value ?? '');
                          },
                        ),
                        DropdownButton<String>(
                          value: recorderProvider.actualGender,
                          items: <String>['male', 'female']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            recorderProvider.setActualGender(value ?? '');
                          },
                        ),
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

                            await recordingsProvider.insertRecording(recording);
                            recorderProvider.cleanUp();
                            recorderProvider.setLoading(false);
                            tabProvider.changeTab(1);
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    )),
              ),
          ],
        );
      },
    );
  }
}
