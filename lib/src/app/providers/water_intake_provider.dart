import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/repository_providers.dart';
import 'package:hydrate/src/domain/models/water_log.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';

class WaterIntakeState {
  final double currentIntake;
  final double dailyGoal;
  final String unit;

  WaterIntakeState({
    required this.currentIntake,
    required this.dailyGoal,
    required this.unit,
  });

  WaterIntakeState copyWith({
    double? currentIntake,
    double? dailyGoal,
    String? unit,
  }) {
    return WaterIntakeState(
      currentIntake: currentIntake ?? this.currentIntake,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      unit: unit ?? this.unit,
    );
  }
}

class WaterIntakeNotifier extends StateNotifier<WaterIntakeState> {
  final IWaterRepository _waterRepository;

  WaterIntakeNotifier(this._waterRepository)
    : super(WaterIntakeState(currentIntake: 0, dailyGoal: 2000, unit: 'ml'));

  Future<void> addWater(double amount) async {
    state = state.copyWith(currentIntake: state.currentIntake + amount);
    await _waterRepository.addWaterLog(
      WaterLog(timestamp: DateTime.now(), amountMl: amount),
    );
  }

  Future<void> setGoal(double goal) async {
    // Logic to set goal and update state
  }

  Future<void> resetDailyIntake() async {
    // Logic to reset daily intake
  }
}

final waterIntakeNotifierProvider =
    StateNotifierProvider<WaterIntakeNotifier, WaterIntakeState>((ref) {
      return WaterIntakeNotifier(ref.watch(waterRepositoryProvider));
    });
