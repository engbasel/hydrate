import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationInitProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions();
});