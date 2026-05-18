import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:hydrate/core/services/background_notification_service.dart';

class NotificationService {
  static const String _intervalKey = 'notification_interval_minutes';
  static const String _lastScheduledKey = 'last_scheduled_time';
  static const int _mainNotificationId = 1001; // Fixed ID for the repeating notification
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        // Handle notification tap - could open the app to a specific screen
      },
    );
  }
  
  /// Sets up water reminders. Uses WorkManager on Android, local scheduled
  /// notifications on iOS (WorkManager is Android-only).
  Future<void> scheduleIntervalReminders(int intervalMinutes) async {
    if (intervalMinutes <= 0) {
      await BackgroundNotificationService.stopWaterReminders();
      await cancelAllNotifications();
      await _clearStoredInterval();
      return;
    }

    final currentInterval = await BackgroundNotificationService.getCurrentInterval();
    final isEnabled = await BackgroundNotificationService.areRemindersEnabled();

    if (Platform.isIOS) {
      await _scheduleIosReminders(
        intervalMinutes: intervalMinutes,
        currentInterval: currentInterval,
        isEnabled: isEnabled,
      );
    } else {
      // Android: WorkManager owns the scheduling — skip if nothing changed.
      if (isEnabled && currentInterval == intervalMinutes) return;
      await cancelAllNotifications();
      await BackgroundNotificationService.startWaterReminders(intervalMinutes);
      await _storeScheduleInfo(intervalMinutes);
    }
  }

  /// iOS-specific scheduling logic.
  ///
  /// Pre-schedules up to 50 individual notifications (~48 h window).
  /// Reschedules automatically whenever:
  ///   - the interval changes, OR
  ///   - fewer than 10 notifications are still pending (i.e. window is nearly over).
  Future<void> _scheduleIosReminders({
    required int intervalMinutes,
    required int currentInterval,
    required bool isEnabled,
  }) async {
    final intervalChanged = !isEnabled || currentInterval != intervalMinutes;

    if (!intervalChanged) {
      // Check how many notifications are still waiting to fire.
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      // Keep at least 10 in the queue so there is no gap in reminders.
      if (pending.length >= 10) return;
    }

    // Cancel stale notifications then schedule a fresh 48-hour window.
    await cancelAllNotifications();
    await _scheduleRepeatingNotification(intervalMinutes);
    await BackgroundNotificationService.markEnabled(intervalMinutes);
    await _storeScheduleInfo(intervalMinutes);
  }

  /// Schedule multiple individual notifications instead of trying to use repeating
  Future<void> _scheduleRepeatingNotification(int intervalMinutes) async {
    final now = tz.TZDateTime.now(tz.local);
    
    // Schedule individual notifications for the next 48 hours (much more reliable)
    const int hoursToSchedule = 48;
    final totalNotifications = (hoursToSchedule * 60) ~/ intervalMinutes;
    
    
    for (int i = 1; i <= totalNotifications && i <= 50; i++) { // Limit to 50 to avoid system limits
      final notificationTime = now.add(Duration(minutes: intervalMinutes * i));
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _mainNotificationId + i - 1, // Sequential IDs starting from 1001
        _getRandomNotificationTitle(),
        _getRandomNotificationBody(),
        notificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'hydrate_reminders',
            'Water Reminders',
            channelDescription: 'Regular water intake reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'app_icon',
            enableVibration: true,
            playSound: true,
            autoCancel: true,
            ongoing: false,
            fullScreenIntent: false,
            enableLights: true,
            ledColor: const Color(0xFF4A90E2),
            ledOnMs: 1000,
            ledOffMs: 500,
            visibility: NotificationVisibility.public,
            // Add these for better background delivery
            channelShowBadge: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
            subtitle: 'Hydration Reminder',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Remove the matchDateTimeComponents - we want exact times, not daily repeats
      );
      
      // Add a small delay to avoid overwhelming the system
      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    
  }


  /// Store scheduling information
  Future<void> _storeScheduleInfo(int intervalMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, intervalMinutes);
    await prefs.setInt(_lastScheduledKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear stored interval information
  Future<void> _clearStoredInterval() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_intervalKey);
    await prefs.remove(_lastScheduledKey);
  }

  /// Get random notification title
  String _getRandomNotificationTitle() {
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
  String _getRandomNotificationBody() {
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

  
  
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Request notification permission
      final bool? notificationPermission = await androidImplementation?.requestNotificationsPermission();
      
      // Request exact alarm permission for Android 12+ (API 31+)
      final bool? exactAlarmPermission = await androidImplementation?.requestExactAlarmsPermission();
      
      
      return notificationPermission ?? false;
    } else if (Platform.isIOS) {
      final bool? grantedIOS = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
            critical: false,
          );
      return grantedIOS ?? false;
    }
    
    return false;
  }

  // Add a method to check current permission status
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      // For iOS, we can check if notifications are enabled
      return true; // iOS doesn't have a direct way to check, assume true after permission request
    }
    
    return false;
  }

  // Add method to get pending notifications (useful for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Debug method to print all pending notifications
  Future<void> debugPendingNotifications() async {
    final pending = await getPendingNotifications();
    final now = DateTime.now();
    for (int i = 0; i < pending.length && i < 10; i++) {
      final notification = pending[i];
      if (notification.payload != null) {
      }
    }
    if (pending.length > 10) {
    }
  }

  /// Show an immediate test notification to verify the system works
  Future<void> showImmediateTestNotification() async {
    // Test both old system and new background system
    await _flutterLocalNotificationsPlugin.show(
      9999,
      '🧪 Immediate Test',
      'If you see this, notifications are working! Time: ${DateTime.now().toString().substring(11, 19)}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hydrate_reminders',
          'Water Reminders',
          channelDescription: 'Regular water intake reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon',
          enableVibration: true,
          playSound: true,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    
    // Also test the background service
    try {
      await BackgroundNotificationService.showTestNotification();
    } catch (e) {
    }
  }
}
