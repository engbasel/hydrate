import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hydrate/core/data/repositories/user_preferences_repository_impl.dart';
import 'package:hydrate/core/data/repositories/water_repository_impl.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/domain/models/water_log.dart';
import 'package:hydrate/core/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';

// Boxes are opened synchronously in main.dart before runApp(), so Hive.box()
// is always safe to call here without async.
final waterRepositoryProvider = Provider<IWaterRepository>((ref) {
  return WaterRepositoryImpl(
    Hive.box<WaterLog>('water_log'),
    Hive.box<DailySummary>('daily_summary'),
  );
});

final userPreferencesRepositoryProvider = Provider<IUserPreferencesRepository>((ref) {
  return UserPreferencesRepositoryImpl(
    Hive.box<UserPreferences>('user_preferences'),
  );
});
