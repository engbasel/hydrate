import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';
import 'package:state_notifier/state_notifier.dart';

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
    // Logic to load user preferences
  }

  Future<void> updateGoal(double newGoal) async {
    // Logic to update goal
  }

  Future<void> updateUnit(String newUnit) async {
    // Logic to update unit
  }

  Future<void> toggleDarkMode() async {
    // Logic to toggle dark mode
  }

  Future<void> updateNotificationIntervals(List<int> newIntervals) async {
    // Logic to update notification intervals
  }

  Future<void> updateWeight(double newWeight) async {
    // Logic to update weight
  }
}
