import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/water_log.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';

class DummyWaterRepository implements IWaterRepository {
  @override
  Future<List<DailySummary>> getAllDailySummaries() {
    return Future.value([]);
  }

  @override
  Future<DailySummary?> getDailySummaryForDate(DateTime date) {
    return Future.value(null);
  }

  @override
  Future<List<WaterLog>> getWaterLogsForDate(DateTime date) {
    return Future.value([]);
  }

  @override
  Future<void> saveDailySummary(DailySummary summary) {
    return Future.value();
  }

  @override
  Future<void> saveWaterLog(WaterLog log) {
    return Future.value();
  }
}
