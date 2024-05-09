import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../recordings_database/database.dart';
import 'recording.dart';

class RecordingsProvider extends ChangeNotifier {
  final Database database;

  List<Recording> _recordings = [];

  RecordingsProvider(this.database) {
    getRecordings().then((value) {
      _recordings = value;
      notifyListeners();
    });
  }

  List<Recording> get recordings => _recordings;

  Future<void> insertRecording(Recording recording) async {
    await database.insert(
      RecordingsDatabase.tableName,
      recording.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _recordings.add(recording);
    notifyListeners();
  }

  Future<List<Recording>> getRecordings() async {
    final List<Map<String, dynamic>> maps =
        await database.query(RecordingsDatabase.tableName);
    return List.generate(maps.length, (i) => Recording.fromMap(maps[i]));
  }
}
