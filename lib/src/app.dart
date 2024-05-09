import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'recordings/recordings_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

import 'recorder/recorder_view.dart';
import './tab_provider.dart';
import 'package:provider/provider.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final tabControllerProvider =
        Provider.of<TabControllerProvider>(context, listen: false);
    tabControllerProvider.initializeTabController(this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case RecordingsListView.routeName:
                    return const RecordingsListView();
                  case SampleItemListView.routeName:
                  default:
                    return const RecordingsListView();
                }
              },
            );
          },
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Gender Me'),
              bottom: TabBar(
                controller:
                    Provider.of<TabControllerProvider>(context).tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.mic), text: 'Recorder'),
                  Tab(icon: Icon(Icons.list), text: 'Recordings'),
                ],
              ),
            ),
            body: TabBarView(
              controller:
                  Provider.of<TabControllerProvider>(context).tabController,
              children: const [
                // Replace these with your actual views
                Center(child: RecorderView()),
                RecordingsListView(),
              ],
            ),
          ),
        );
      },
    );
  }
}
