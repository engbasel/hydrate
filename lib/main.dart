import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';
import 'core/utils/app_initializer.dart';
import 'core/data/hive_service.dart';
import 'core/domain/models/water_log.dart';
import 'core/domain/models/daily_summary.dart';
import 'core/domain/models/user_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  tz.initializeTimeZones();

  final hiveService = HiveService();
  await hiveService.init();

  // Open all boxes before runApp so FutureProviders resolve immediately
  // and the app never uses dummy repositories
  await Future.wait([
    hiveService.openBox<WaterLog>('water_log'),
    hiveService.openBox<DailySummary>('daily_summary'),
    hiveService.openBox<UserPreferences>('user_preferences'),
  ]);

  await AppInitializer.initialize();

  runApp(ProviderScope(child: MyApp()));
}
