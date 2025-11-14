import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/src/app/providers/repository_providers.dart';
import 'package:hydrate/src/data/repositories/dummy_user_preferences_repository.dart';
import 'package:hydrate/src/data/repositories/user_preferences_repository_impl.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      (ref) {
        final repository = ref.watch(userPreferencesRepositoryProvider);
        return UserPreferencesNotifier(repository);
      },
    );

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
      ) {
    // Load saved preferences on initialization if we have a real repository
    if (_userPreferencesRepository is! DummyUserPreferencesRepository) {
      _loadInitialPreferences();
    }
  }

  Future<void> _loadInitialPreferences() async {
    await loadUserPreferences();
  }

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

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
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
