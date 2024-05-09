import 'package:sqflite/sqflite.dart';

class RecordingsDatabase {
  static const String tableName = 'recordings';

  static const String columnId = '_id';
  static const String columnPath = 'path';
  static const String columnRecordedAt = 'recorded_at';
  static const String columnPredictedAge = 'predicted_age';
  static const String columnPredictedGender = 'predicted_gender';
  static const String columnActualAge = 'actual_age';
  static const String columnActualGender = 'actual_gender';

  static Future<Database> createDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$tableName.db';
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnPath TEXT NOT NULL,
            $columnRecordedAt TEXT NOT NULL,
            $columnPredictedAge TEXT,
            $columnPredictedGender TEXT,
            $columnActualAge TEXT,
            $columnActualGender TEXT
          )
        ''');
      },
    );
/*
    // delete all recordings
    await db.delete(tableName);

    // Add a few recordings for testing.
    await db.insert(
      tableName,
      {
        columnPath: 'path/to/recording1',
        columnRecordedAt: DateTime.now().toIso8601String(),
        columnPredictedAge: 'twenties',
        columnPredictedGender: 'male',
        columnActualAge: 'twenties',
        columnActualGender: 'male'
      },
    );

    await db.insert(
      tableName,
      {
        columnPath: 'path/to/recording2',
        columnRecordedAt: DateTime.now().toIso8601String(),
        columnPredictedAge: 'thirties',
        columnPredictedGender: 'female',
        columnActualAge: 'twenties',
        columnActualGender: 'male'
      },
    );*/

    return db;
  }
}
