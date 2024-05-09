import '../recordings_database/database.dart';

class Recording {
  final int id;
  final String path;
  final DateTime recordedAt;
  final String predictedAge;
  final String predictedGender;
  String actualAge;
  String actualGender;

  Recording(this.id, this.path, this.recordedAt, this.predictedAge,
      this.predictedGender, this.actualAge, this.actualGender);

  Map<String, dynamic> toMap() {
    return {
      RecordingsDatabase.columnId: id,
      RecordingsDatabase.columnPath: path,
      RecordingsDatabase.columnRecordedAt: recordedAt.toString(),
      RecordingsDatabase.columnPredictedAge: predictedAge,
      RecordingsDatabase.columnPredictedGender: predictedGender,
      RecordingsDatabase.columnActualAge: actualAge,
      RecordingsDatabase.columnActualGender: actualGender,
    };
  }

  static Recording fromMap(Map<String, dynamic> map) => Recording(
        map[RecordingsDatabase.columnId] as int,
        map[RecordingsDatabase.columnPath] as String,
        DateTime.parse(map[RecordingsDatabase.columnRecordedAt] as String),
        map[RecordingsDatabase.columnPredictedAge] as String,
        map[RecordingsDatabase.columnPredictedGender] as String,
        map[RecordingsDatabase.columnActualAge] as String,
        map[RecordingsDatabase.columnActualGender] as String,
      );
}
