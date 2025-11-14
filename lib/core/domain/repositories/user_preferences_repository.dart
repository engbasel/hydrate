import 'package:hydrate/core/domain/models/user_preferences.dart';

abstract class IUserPreferencesRepository {
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<UserPreferences?> loadUserPreferences();
}
