import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hydrate/src/data/hive_service.dart';
import 'package:hydrate/src/data/repositories/dummy_water_repository.dart';
import 'package:hydrate/src/data/repositories/water_repository_impl.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/water_log.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final waterLogBoxProvider = FutureProvider<Box<WaterLog>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox<WaterLog>('water_log');
});

final dailySummaryBoxProvider = FutureProvider<Box<DailySummary>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox<DailySummary>('daily_summary');
});

final waterRepositoryProvider = Provider<IWaterRepository>((ref) {
  final waterLogBox = ref.watch(waterLogBoxProvider);
  final dailySummaryBox = ref.watch(dailySummaryBoxProvider);

  return waterLogBox.when(
    data: (waterLogBoxData) => dailySummaryBox.when(
      data: (dailySummaryBoxData) =>
          WaterRepositoryImpl(waterLogBoxData, dailySummaryBoxData),
      loading: () => DummyWaterRepository(),
      error: (error, stackTrace) => DummyWaterRepository(),
    ),
    loading: () => DummyWaterRepository(),
    error: (error, stackTrace) => DummyWaterRepository(),
  );
});
