import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrate/core/services/background_notification_service.dart';

class NotificationService {
  static const String _notificationIdKey = 'water_reminder_notification_id';
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
        print('Notification tapped: ${details.id}');
      },
    );
  }
  
  /// Sets up reliable background water reminders using WorkManager
  /// This method works across all app states and survives phone restarts
  Future<void> scheduleIntervalReminders(int intervalMinutes) async {
    print('🔧 Setting up water reminders: $intervalMinutes minutes');
    
    if (intervalMinutes <= 0) {
      print('🛑 Disabling water reminders');
      await BackgroundNotificationService.stopWaterReminders();
      await cancelAllNotifications();
      await _clearStoredInterval();
      return;
    }

    // Check if we need to reschedule
    final currentInterval = await BackgroundNotificationService.getCurrentInterval();
    final isEnabled = await BackgroundNotificationService.areRemindersEnabled();
    
    if (isEnabled && currentInterval == intervalMinutes) {
      print('✅ Water reminders already running with interval $intervalMinutes minutes. No change needed.');
      return;
    }

    print('🚀 Starting reliable background water reminders every $intervalMinutes minutes');
    
    // Cancel any existing scheduled notifications and background tasks
    await cancelAllNotifications();
    
    // Start the new background reminder service
    await BackgroundNotificationService.startWaterReminders(intervalMinutes);
    
    // Store the current interval
    await _storeScheduleInfo(intervalMinutes);
    
    print('✅ Background water reminders activated! They will work even when app is closed.');
  }

  /// Check if we need to reschedule the notification
  Future<bool> _shouldRescheduleNotification(int intervalMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    final storedInterval = prefs.getInt(_intervalKey);
    final lastScheduled = prefs.getInt(_lastScheduledKey);
    
    // If interval changed, we need to reschedule
    if (storedInterval != intervalMinutes) {
      return true;
    }
    
    // If no notification is currently scheduled, we need to schedule
    final pendingNotifications = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    final hasMainNotification = pendingNotifications.any((notification) => notification.id == _mainNotificationId);
    
    if (!hasMainNotification) {
      return true;
    }
    
    // If it's been more than 2 hours since last schedule, reschedule to be safe
    if (lastScheduled != null) {
      final lastScheduledTime = DateTime.fromMillisecondsSinceEpoch(lastScheduled);
      final timeSinceLastSchedule = DateTime.now().difference(lastScheduledTime);
      if (timeSinceLastSchedule.inHours > 2) {
        return true;
      }
    }
    
    return false;
  }

  /// Schedule multiple individual notifications instead of trying to use repeating
  Future<void> _scheduleRepeatingNotification(int intervalMinutes) async {
    final now = tz.TZDateTime.now(tz.local);
    
    // Schedule individual notifications for the next 48 hours (much more reliable)
    const int hoursToSchedule = 48;
    final totalNotifications = (hoursToSchedule * 60) ~/ intervalMinutes;
    
    print('Scheduling $totalNotifications notifications over $hoursToSchedule hours, every $intervalMinutes minutes');
    
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
    
    print('Successfully scheduled ${totalNotifications > 50 ? 50 : totalNotifications} water reminders');
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
      
      print('Android notification permission: $notificationPermission');
      print('Android exact alarm permission: $exactAlarmPermission');
      
      return notificationPermission ?? false;
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
              
      final bool? grantedIOS = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        critical: false,
      );
      
      print('iOS notification permission: $grantedIOS');
      
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
    print('Cancelled all notifications');
  }

  /// Debug method to print all pending notifications
  Future<void> debugPendingNotifications() async {
    final pending = await getPendingNotifications();
    final now = DateTime.now();
    print('=== PENDING NOTIFICATIONS DEBUG ===');
    print('Current time: ${now.toString()}');
    print('Total pending notifications: ${pending.length}');
    for (int i = 0; i < pending.length && i < 10; i++) {
      final notification = pending[i];
      print('  ${i + 1}. ID: ${notification.id}');
      print('     Title: ${notification.title}');
      print('     Body: ${notification.body}');
      if (notification.payload != null) {
        print('     Payload: ${notification.payload}');
      }
    }
    if (pending.length > 10) {
      print('  ... and ${pending.length - 10} more notifications');
    }
    print('=================================');
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
    print('Immediate test notification sent at ${DateTime.now()}');
    
    // Also test the background service
    try {
      await BackgroundNotificationService.showTestNotification();
      print('Background service test notification also sent');
    } catch (e) {
      print('Background service test failed: $e');
    }
  }
}
