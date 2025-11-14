import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/models/water_log.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';

class DummyWaterRepository implements IWaterRepository {
  @override
  Future<void> addWaterLog(WaterLog log) {
    return Future.value();
  }

  @override
  Future<List<WaterLog>> getWaterLogsForDate(DateTime date) {
    return Future.value([]);
  }

  @override
  Future<void> clearWaterLogsForDate(DateTime date) {
    return Future.value();
  }

  @override
  Future<void> addDailySummary(DailySummary summary) {
    return Future.value();
  }

  @override
  Future<DailySummary?> getDailySummaryForDate(DateTime date) {
    return Future.value(null);
  }

  @override
  Future<List<DailySummary>> getWaterIntakeHistory() {
    return Future.value([]);
  }
}
