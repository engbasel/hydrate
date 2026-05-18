import 'package:hive/hive.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/services/background_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer {
  static UserPreferences? _cachedPreferences;

  static Future<void> initialize() async {
    try {
      await BackgroundNotificationService.initialize();
    } catch (_) {}

    try {
      final box = Hive.box<UserPreferences>('user_preferences');
      _cachedPreferences = box.get('user_preferences');
    } catch (_) {}
  }

  static UserPreferences getInitialPreferences() {
    final preferences = _cachedPreferences ??
        UserPreferences(
          dailyGoalMl: 2000,
          unit: 'ml',
          notificationIntervalMinutes: 60,
          darkModeEnabled: false,
          weightKg: 70,
        );
    _syncDarkModePreference(preferences.darkModeEnabled);
    return preferences;
  }

  static void _syncDarkModePreference(bool darkModeEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode_enabled', darkModeEnabled);
    } catch (_) {}
  }
}
