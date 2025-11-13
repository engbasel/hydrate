import 'package:hive/hive.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/water_log.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';

class WaterRepositoryImpl implements IWaterRepository {
  final Box<WaterLog> _waterLogBox;
  final Box<DailySummary> _dailySummaryBox;

  WaterRepositoryImpl(this._waterLogBox, this._dailySummaryBox);

  @override
  Future<void> saveWaterLog(WaterLog log) async {
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
  Future<void> saveDailySummary(DailySummary summary) async {
    await _dailySummaryBox.put(summary.date.toIso8601String(), summary);
  }

  @override
  Future<DailySummary?> getDailySummaryForDate(DateTime date) async {
    return _dailySummaryBox.get(date.toIso8601String());
  }

  @override
  Future<List<DailySummary>> getAllDailySummaries() async {
    return _dailySummaryBox.values.toList();
  }
}
