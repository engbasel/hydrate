import 'package:hive/hive.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';

class AppInitializer {
  static UserPreferences? _cachedPreferences;
  
  static Future<void> initialize() async {
    // Load preferences synchronously during app startup
    try {
      final box = await Hive.openBox<UserPreferences>('user_preferences');
      _cachedPreferences = box.get('user_preferences');
    } catch (e) {
      // If there's an error, use default preferences
      _cachedPreferences = null;
    }
  }
  
  static UserPreferences getInitialPreferences() {
    return _cachedPreferences ?? UserPreferences(
      dailyGoalMl: 2000,
      unit: 'ml',
      notificationIntervalMinutes: 120, // Default: every 2 hours
      darkModeEnabled: false,
      weightKg: 70,
    );
  }
  
  static bool get hasLoadedPreferences => _cachedPreferences != null;
}