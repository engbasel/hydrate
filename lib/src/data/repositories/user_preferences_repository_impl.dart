import 'package:hive/hive.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';

class UserPreferencesRepositoryImpl implements IUserPreferencesRepository {
  final Box<UserPreferences> _userPreferencesBox;

  UserPreferencesRepositoryImpl(this._userPreferencesBox);

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _userPreferencesBox.put('user_preferences', preferences);
  }

  @override
  Future<UserPreferences?> loadUserPreferences() async {
    return _userPreferencesBox.get('user_preferences');
  }
}
