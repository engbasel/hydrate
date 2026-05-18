import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundNotificationService {
  static const String _taskName = "waterReminderTask";
  static const String _taskTag = "waterReminder";
  static const String _intervalKey = "notification_interval_minutes";
  static const String _enabledKey = "notifications_enabled";

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  /// Initialize the background service
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to false for production
    );

    // Initialize notifications for background use
    await _initializeNotifications();
  }

  /// Initialize notifications plugin for background usage
  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Start periodic water reminders
  static Future<void> startWaterReminders(int intervalMinutes) async {
    try {
      // Cancel any existing tasks first
      await stopWaterReminders();

      if (intervalMinutes <= 0) {
        return;
      }

      // Store interval in preferences for background task
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_intervalKey, intervalMinutes);
      await prefs.setBool(_enabledKey, true);

      if (intervalMinutes < 15) {
        // For intervals less than 15 minutes, use one-time tasks that reschedule themselves
        await _scheduleNextQuickReminder(intervalMinutes);
      } else {
        // For 15+ minutes, use WorkManager periodic tasks
        await Workmanager().registerPeriodicTask(
          _taskTag,
          _taskName,
          frequency: Duration(minutes: intervalMinutes),
          constraints: Constraints(
            networkType: NetworkType.notRequired,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
          inputData: {
            'intervalMinutes': intervalMinutes,
            'taskType': 'waterReminder',
          },
          backoffPolicy: BackoffPolicy.linear,
          backoffPolicyDelay: Duration(seconds: 30),
        );
      }


    } catch (e) {
    }
  }

  /// Schedule the next quick reminder (for intervals < 15 minutes)
  static Future<void> _scheduleNextQuickReminder(int intervalMinutes) async {
    await Workmanager().registerOneOffTask(
      '${_taskTag}_${DateTime.now().millisecondsSinceEpoch}', // Unique task ID
      _taskName,
      initialDelay: Duration(minutes: intervalMinutes),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      inputData: {
        'intervalMinutes': intervalMinutes,
        'taskType': 'quickWaterReminder',
        'reschedule': true, // This tells the background task to schedule the next one
      },
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: Duration(seconds: 10),
    );
    
  }

  /// Stop water reminders — cancels ALL WorkManager tasks for this app,
  /// including chained one-off quick-reminder tasks whose unique IDs are
  /// not predictable at call time.
  static Future<void> stopWaterReminders() async {
    try {
      await Workmanager().cancelAll();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, false);
    } catch (e) {
      // Ignore — best effort cancellation
    }
  }

  /// Check if reminders are currently enabled
  static Future<bool> areRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Get current interval
  static Future<int> getCurrentInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_intervalKey) ?? 0;
  }

  /// Mark reminders as enabled with a given interval (used on iOS where
  /// WorkManager is not available and scheduling is done via local notifications)
  static Future<void> markEnabled(int intervalMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, intervalMinutes);
    await prefs.setBool(_enabledKey, true);
  }

  /// Show immediate notification for testing
  static Future<void> showTestNotification() async {
    await _showWaterNotification(isTest: true);
  }

  /// Show a water reminder notification
  static Future<void> _showWaterNotification({bool isTest = false}) async {
    final title = isTest ? '🧪 Test Water Reminder' : _getRandomNotificationTitle();
    final body = isTest ? 'This is how your water reminders will appear!' : _getRandomNotificationBody();
    final id = isTest ? 9999 : DateTime.now().millisecondsSinceEpoch % 10000;

    // Get the current theme preference
    final isDarkMode = await _isDarkModeEnabled();
    
    // Choose colors based on theme
    final notificationColor = isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF1976D2); // Light blue for dark mode, dark blue for light mode
    final ledColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4A90E2); // Light green for dark mode, blue for light mode

    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders_bg',
          'Water Reminders (Background)',
          channelDescription: 'Background water intake reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon',
          enableVibration: true,
          playSound: true,
          autoCancel: true,
          ongoing: false,
          enableLights: true,
          ledColor: ledColor,
          ledOnMs: 1000,
          ledOffMs: 500,
          visibility: NotificationVisibility.public,
          channelShowBadge: true,
          category: AndroidNotificationCategory.reminder,
          color: notificationColor,
          colorized: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
    );

  }

  /// Check if dark mode is enabled
  static Future<bool> _isDarkModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Try to get dark mode preference from shared preferences
      // Default to false (light mode) if not found
      return prefs.getBool('dark_mode_enabled') ?? false;
    } catch (e) {
      // If there's an error, default to light mode
      return false;
    }
  }

  /// Get random notification title
  static String _getRandomNotificationTitle() {
    final List<String> titles = [
      '💧 Time to Hydrate!',
      '🌊 Water Break!',
      '💦 Stay Hydrated!',
      '🚰 Hydration Check!',
      '💧 Water Reminder',
      '🌊 Drink Up!',
    ];
    
    final now = DateTime.now();
    final index = now.millisecond % titles.length;
    return titles[index];
  }

  /// Get random notification body
  static String _getRandomNotificationBody() {
    final List<String> bodies = [
      'Don\'t forget to drink water and stay hydrated!',
      'Your body needs water to function properly. Take a sip!',
      'A glass of water can boost your energy and focus!',
      'Keep your body happy with some refreshing water!',
      'Small sips throughout the day keep dehydration away!',
      'Your future self will thank you for staying hydrated!',
    ];
    
    final now = DateTime.now();
    final index = (now.millisecond + now.second) % bodies.length;
    return bodies[index];
  }
}

/// This is the callback that gets called by WorkManager in the background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    
    try {
      // Initialize notifications for background usage
      await BackgroundNotificationService._initializeNotifications();

      switch (task) {
        case BackgroundNotificationService._taskName:
          // Show the notification
          await BackgroundNotificationService._showWaterNotification();
          
          // Check if this is a quick reminder that needs rescheduling
          final taskType = inputData?['taskType'] as String?;
          final shouldReschedule = inputData?['reschedule'] as bool? ?? false;
          final intervalMinutes = inputData?['intervalMinutes'] as int?;
          
          if (taskType == 'quickWaterReminder' && shouldReschedule && intervalMinutes != null) {
            // Check if reminders are still enabled
            final prefs = await SharedPreferences.getInstance();
            final isEnabled = prefs.getBool(BackgroundNotificationService._enabledKey) ?? false;
            final currentInterval = prefs.getInt(BackgroundNotificationService._intervalKey) ?? 0;
            
            if (isEnabled && currentInterval == intervalMinutes && currentInterval > 0) {
              // Schedule the next reminder
              await BackgroundNotificationService._scheduleNextQuickReminder(intervalMinutes);
            } else {
            }
          }
          
          break;
        default:
          return Future.value(false);
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}