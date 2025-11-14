import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/models/water_log.dart';

abstract class IWaterRepository {
  Future<void> addWaterLog(WaterLog log);
  Future<List<WaterLog>> getWaterLogsForDate(DateTime date);
  Future<void> clearWaterLogsForDate(DateTime date);
  Future<void> addDailySummary(DailySummary summary);
  Future<DailySummary?> getDailySummaryForDate(DateTime date);
  Future<List<DailySummary>> getWaterIntakeHistory();
}
