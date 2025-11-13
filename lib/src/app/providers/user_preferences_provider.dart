import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final IUserPreferencesRepository _userPreferencesRepository;

  UserPreferencesNotifier(this._userPreferencesRepository)
    : super(
        UserPreferences(
          dailyGoalMl: 2000,
          unit: 'ml',
          notificationIntervals: [9, 12, 15, 18],
          darkModeEnabled: false,
          weightKg: 70,
        ),
      );

  Future<void> loadUserPreferences() async {
    final preferences = await _userPreferencesRepository.loadUserPreferences();
    if (preferences != null) {
      state = preferences;
    }
  }

  Future<void> updateGoal(double newGoal) async {
    state = state.copyWith(dailyGoalMl: newGoal);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> updateUnit(String newUnit) async {
    state = state.copyWith(unit: newUnit);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkModeEnabled: !state.darkModeEnabled);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> updateNotificationIntervals(List<int> newIntervals) async {
    state = state.copyWith(notificationIntervals: newIntervals);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> updateWeight(double newWeight) async {
    state = state.copyWith(weightKg: newWeight);
    await _userPreferencesRepository.saveUserPreferences(state);
  }
}
