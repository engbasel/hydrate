import 'package:hive/hive.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/models/water_log.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';

class WaterRepositoryImpl implements IWaterRepository {
  final Box<WaterLog> _waterLogBox;
  final Box<DailySummary> _dailySummaryBox;

  WaterRepositoryImpl(this._waterLogBox, this._dailySummaryBox);

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<void> addWaterLog(WaterLog log) async {
    await _waterLogBox.add(log);
  }

  @override
  Future<List<WaterLog>> getWaterLogsForDate(DateTime date) async {
    return _waterLogBox.values
        .where((log) => _isSameDay(log.timestamp, date))
        .toList();
  }

  @override
  Future<void> clearWaterLogsForDate(DateTime date) async {
    final keysToDelete = <dynamic>[];

    for (final key in _waterLogBox.keys) {
      final log = _waterLogBox.get(key);
      if (log != null && _isSameDay(log.timestamp, date)) {
        keysToDelete.add(key);
      }
    }

    for (final key in keysToDelete) {
      await _waterLogBox.delete(key);
    }
  }

  @override
  Future<void> addDailySummary(DailySummary summary) async {
    await _dailySummaryBox.put(_dateKey(summary.date), summary);
  }

  @override
  Future<DailySummary?> getDailySummaryForDate(DateTime date) async {
    return _dailySummaryBox.get(_dateKey(date));
  }

  @override
  Future<List<DailySummary>> getWaterIntakeHistory() async {
    return _dailySummaryBox.values.toList();
  }
}
