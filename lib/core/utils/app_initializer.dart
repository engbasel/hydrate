import 'package:hive/hive.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/services/background_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer {
  static UserPreferences? _cachedPreferences;

  static Future<void> initialize() async {
    // Initialize background notification service
    try {
      await BackgroundNotificationService.initialize();
      print('✅ Background notification service initialized');
    } catch (e) {
      print('❌ Failed to initialize background notification service: $e');
    }
    
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
    final preferences = _cachedPreferences ??
        UserPreferences(
          dailyGoalMl: 2000,
          unit: 'ml',
          notificationIntervalMinutes: 60, // Default: every 1 hour
          darkModeEnabled: false,
          weightKg: 70,
        );
    
    // Sync dark mode preference to SharedPreferences for background access
    _syncDarkModePreference(preferences.darkModeEnabled);
    
    return preferences;
  }

  /// Sync dark mode preference to SharedPreferences for background notifications
  static void _syncDarkModePreference(bool darkModeEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode_enabled', darkModeEnabled);
    } catch (e) {
      print('Failed to sync dark mode preference: $e');
    }
  }

  static bool get hasLoadedPreferences => _cachedPreferences != null;
}
