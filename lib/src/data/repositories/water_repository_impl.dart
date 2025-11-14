import 'package:hive/hive.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/water_log.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';

class WaterRepositoryImpl implements IWaterRepository {
  final Box<WaterLog> _waterLogBox;
  final Box<DailySummary> _dailySummaryBox;

  WaterRepositoryImpl(this._waterLogBox, this._dailySummaryBox);

  @override
  Future<void> addWaterLog(WaterLog log) async {
    await _waterLogBox.add(log);
  }

  @override
  Future<List<WaterLog>> getWaterLogsForDate(DateTime date) async {
    return _waterLogBox.values
        .where(
          (log) =>
              log.timestamp.year == date.year &&
              log.timestamp.month == date.month &&
              log.timestamp.day == date.day,
        )
        .toList();
  }

  @override
  Future<void> clearWaterLogsForDate(DateTime date) async {
    // Find keys of logs for the specified date
    final keysToDelete = <dynamic>[];
    
    for (int i = 0; i < _waterLogBox.length; i++) {
      final log = _waterLogBox.getAt(i);
      if (log != null &&
          log.timestamp.year == date.year &&
          log.timestamp.month == date.month &&
          log.timestamp.day == date.day) {
        keysToDelete.add(i);
      }
    }
    
    // Delete logs in reverse order to maintain correct indices
    for (int i = keysToDelete.length - 1; i >= 0; i--) {
      await _waterLogBox.deleteAt(keysToDelete[i]);
    }
  }

  @override
  Future<void> addDailySummary(DailySummary summary) async {
    await _dailySummaryBox.put(summary.date.toIso8601String(), summary);
  }

  @override
  Future<DailySummary?> getDailySummaryForDate(DateTime date) async {
    return _dailySummaryBox.get(date.toIso8601String());
  }

  @override
  Future<List<DailySummary>> getWaterIntakeHistory() async {
    return _dailySummaryBox.values.toList();
  }
}
