import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class NotificationService {
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
  
  // Schedule multiple notifications in advance (for next 7 days)
  Future<void> scheduleIntervalReminders(int intervalMinutes) async {
    // Cancel existing notifications first
    await cancelAllNotifications();
    
    if (intervalMinutes <= 0) {
      return; // No reminders if interval is 0 or negative
    }
    
    await _scheduleMultipleReminders(intervalMinutes);
  }
  
  Future<void> _scheduleMultipleReminders(int intervalMinutes) async {
    final now = tz.TZDateTime.now(tz.local);
    const int daysToSchedule = 7; // Schedule for next 7 days
    const int maxNotificationsPerDay = 16; // Reasonable limit to avoid too many notifications
    
    // Calculate how many notifications per day based on interval
    final notificationsPerDay = (24 * 60) ~/ intervalMinutes;
    final actualNotificationsPerDay = notificationsPerDay > maxNotificationsPerDay 
        ? maxNotificationsPerDay 
        : notificationsPerDay;
    
    // Define active hours (8 AM to 10 PM by default)
    const int startHour = 8;
    const int endHour = 22;
    const int activeHours = endHour - startHour;
    
    // Calculate interval during active hours
    final activeMinutesPerDay = activeHours * 60;
    final effectiveInterval = activeMinutesPerDay ~/ actualNotificationsPerDay;
    
    int notificationId = 1000; // Start with a high ID to avoid conflicts
    
    for (int day = 0; day < daysToSchedule; day++) {
      final dayStart = now.add(Duration(days: day));
      
      // Schedule notifications only during active hours
      for (int notificationIndex = 0; notificationIndex < actualNotificationsPerDay; notificationIndex++) {
        final minutesFromDayStart = (startHour * 60) + (notificationIndex * effectiveInterval);
        final notificationTime = tz.TZDateTime(
          tz.local,
          dayStart.year,
          dayStart.month,
          dayStart.day,
          0,
          0,
        ).add(Duration(minutes: minutesFromDayStart));
        
        // Only schedule if the time is in the future
        if (notificationTime.isAfter(now)) {
          await _scheduleNotification(
            notificationId++,
            notificationTime,
            _getRandomNotificationContent(),
          );
        }
      }
    }
    
    print('Scheduled ${notificationId - 1000} water reminder notifications for the next $daysToSchedule days');
  }
  
  Future<void> _scheduleNotification(int id, tz.TZDateTime scheduledTime, Map<String, String> content) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      content['title']!,
      content['body']!,
      scheduledTime,
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
          // These settings help ensure notifications work when app is closed
          fullScreenIntent: false,
          enableLights: true,
          ledColor: const Color(0xFF4A90E2),
          ledOnMs: 1000,
          ledOffMs: 500,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          subtitle: 'Hydration Reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  
  Map<String, String> _getRandomNotificationContent() {
    final List<Map<String, String>> notifications = [
      {
        'title': '💧 Time to Hydrate!',
        'body': 'Don\'t forget to drink water and stay hydrated!'
      },
      {
        'title': '🌊 Water Break!',
        'body': 'Your body needs water to function properly. Take a sip!'
      },
      {
        'title': '💦 Stay Hydrated!',
        'body': 'A glass of water can boost your energy and focus!'
      },
      {
        'title': '🚰 Hydration Check!',
        'body': 'Keep your body happy with some refreshing water!'
      },
      {
        'title': '💧 Water Reminder',
        'body': 'Small sips throughout the day keep dehydration away!'
      },
      {
        'title': '🌊 Drink Up!',
        'body': 'Your future self will thank you for staying hydrated!'
      },
    ];
    
    final now = DateTime.now();
    final index = now.millisecond % notifications.length;
    return notifications[index];
  }
  
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
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
  }
}
