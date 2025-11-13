import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/water_log.dart';

abstract class IWaterRepository {
  Future<void> saveWaterLog(WaterLog log);
  Future<List<WaterLog>> getWaterLogsForDate(DateTime date);
  Future<void> saveDailySummary(DailySummary summary);
  Future<DailySummary?> getDailySummaryForDate(DateTime date);
  Future<List<DailySummary>> getAllDailySummaries();
}
