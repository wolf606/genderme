import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'recordings_provider.dart';
import 'recording.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';

class RecordingsListView extends StatelessWidget {
  const RecordingsListView({
    super.key,
  });

  static const routeName = '/recordings';

  @override
  Widget build(BuildContext context) {
    final RecordingsProvider recordingsProvider =
        Provider.of<RecordingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Recordings', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // show the consitency matrix and the list of recordings
      body: ListView.builder(
        restorationId: 'recordingsListView',
        itemCount: recordingsProvider.recordings.length,
        itemBuilder: (BuildContext context, int index) {
          final recording = recordingsProvider.recordings[index];

          return buildRecordingCard(recording, context);
        },
      ),
    );
  }
}

// create card widget for each recording here in this file

Widget buildRecordingCard(Recording recording, BuildContext context) {
  final PlayerProvider playerProvider = Provider.of<PlayerProvider>(context);

  return Card(
    color: (recording.predictedAge == recording.actualAge &&
            recording.predictedGender == recording.actualGender)
        ? Colors.lightGreen.shade900.withOpacity(0.5)
        : Colors.red.shade900.withOpacity(0.5),
    child: Column(
      children: [
        ListTile(
            
            leading: FloatingActionButton(
              heroTag: 'play${recording.id}',
              shape: const CircleBorder(),
              onPressed: () async {
                await playerProvider.controller.stopPlayer();
                await playerProvider.startPlaying(recording.path);
              },
              
              
              child: const Icon(Icons.play_arrow),
            ),
            subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Predicted Age: ${recording.predictedAge}', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text('Actual Age: ${recording.actualAge}', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(Icons.person, color: Theme.of(context).hintColor,),
                  ),
                  ListTile(
                    title:
                        Text('Predicted gender: ${recording.predictedGender}', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)
                        ),
                    subtitle: Text('Actual gender: ${recording.actualGender}', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)
                    ),
                    leading: (recording.predictedGender == 'male')
                        ? Icon(Icons.male, color: Theme.of(context).hintColor,)
                        : Icon(Icons.female, color: Theme.of(context).hintColor,),
                  ),
                ])),
      ],
    ),
  );
}
