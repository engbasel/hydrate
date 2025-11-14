import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/models/water_log.dart';

class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WaterLogAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DailySummaryAdapter());
    }
  }

  Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }

  Future<void> close() async {
    await Hive.close();
  }
}
