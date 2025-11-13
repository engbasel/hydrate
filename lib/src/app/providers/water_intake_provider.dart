import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/data/repositories/dummy_water_repository.dart';
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
    // TODO: Save water log to repository
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
      // TODO: Provide actual WaterRepository implementation
      return WaterIntakeNotifier(DummyWaterRepository());
    });
