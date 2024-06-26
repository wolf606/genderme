import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'src/recordings_database/database.dart';

import 'package:provider/provider.dart';
import 'src/recordings/recordings_provider.dart';
import 'src/recorder/recorder_provider.dart';
import 'src/player/player_provider.dart';
import 'src/trained_model/trained_model_provider.dart';
import 'src/tts/tts_provider.dart';
import 'src/tab_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.`
  await settingsController.loadSettings();

  // Create the database.
  final database = await RecordingsDatabase.createDatabase();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => RecordingsProvider(database)),
      ChangeNotifierProvider(create: (context) => RecorderProvider()),
      ChangeNotifierProvider(create: (context) => TabControllerProvider()),
      ChangeNotifierProvider(create: (context) => PlayerProvider()),
      ChangeNotifierProvider(create: (context) => TfModelProvider()),
      ChangeNotifierProvider(create: (context) => TextToSpeechProvider()),
    ],
    child: MyApp(settingsController: settingsController),
  ));
}
