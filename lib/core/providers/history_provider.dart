import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/providers/water_intake_provider.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';

enum DateRange { daily, weekly, monthly }

class HistoryState {
  final List<DailySummary> history;
  final bool isLoading;
  final DateRange dateRange;

  HistoryState({
    required this.history,
    this.isLoading = false,
    this.dateRange = DateRange.daily,
  });

  HistoryState copyWith({
    List<DailySummary>? history,
    bool? isLoading,
    DateRange? dateRange,
  }) {
    return HistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final IWaterRepository _waterRepository;
  final Ref _ref;

  HistoryNotifier(this._waterRepository, this._ref)
    : super(HistoryState(history: [])) {
    loadHistory();

    // Listen to water intake changes and refresh history
    _ref.listen(waterIntakeNotifierProvider, (previous, next) {
      // Only refresh if the intake actually changed
      if (previous?.currentIntake != next.currentIntake) {
        // Add a small delay to ensure daily summary is updated first
        Future.delayed(const Duration(milliseconds: 100), () {
          loadHistory();
        });
      }
    });
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final history = await _waterRepository.getWaterIntakeHistory();
    state = state.copyWith(history: history, isLoading: false);
  }

  void setDateRange(DateRange dateRange) {
    state = state.copyWith(dateRange: dateRange);
    loadHistory();
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(ref.watch(waterRepositoryProvider), ref),
);
