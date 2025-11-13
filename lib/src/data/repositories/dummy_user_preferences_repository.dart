import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';

class DummyUserPreferencesRepository implements IUserPreferencesRepository {
  @override
  Future<UserPreferences?> loadUserPreferences() async {
    return UserPreferences(
      dailyGoalMl: 2000,
      unit: 'ml',
      notificationIntervals: [9, 12, 15, 18],
      darkModeEnabled: false,
      weightKg: 70,
    );
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    // Do nothing
  }
}
