import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class HistoryNotifier extends StateNotifier<List<DailySummary>> {
  final IWaterRepository _waterRepository;

  HistoryNotifier(this._waterRepository) : super(const []);

  Future<void> loadHistory() async {
    // Logic to load history
  }

  Future<void> addDailySummary(DailySummary summary) async {
    // Logic to add daily summary
  }
}
