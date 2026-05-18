import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';

class ResetDailyIntake {
  final IWaterRepository _waterRepository;

  ResetDailyIntake(this._waterRepository);

  Future<void> call() async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    await _waterRepository.clearWaterLogsForDate(today);
    await _waterRepository.addDailySummary(
      DailySummary(date: normalizedDate, totalIntakeMl: 0.0),
    );
  }
}
