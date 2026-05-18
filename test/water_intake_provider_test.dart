import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/core/domain/models/water_log.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/providers/water_intake_provider.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'test_helper.dart';
import 'water_intake_provider_test.mocks.dart';

@GenerateMocks([IWaterRepository])
void main() {
  late ProviderContainer container;
  late MockIWaterRepository mockWaterRepository;

  setUp(() async {
    await initHive();
    mockWaterRepository = MockIWaterRepository();
    when(mockWaterRepository.getWaterLogsForDate(any)).thenAnswer((_) async => []);
    when(mockWaterRepository.addDailySummary(any)).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      waterRepositoryProvider.overrideWithValue(mockWaterRepository),
    ]);
  });

  tearDown(() => container.dispose());

  test('initial state is correct', () {
    final state = container.read(waterIntakeNotifierProvider);
    expect(state.currentIntake, 0);
    expect(state.dailyGoal, 2000);
    expect(state.unit, 'ml');
  });

  test('addWater should update the current intake and call the repository', () async {
    const amount = 250.0;
    when(mockWaterRepository.addWaterLog(any)).thenAnswer((_) async {});
    when(mockWaterRepository.getWaterLogsForDate(any)).thenAnswer(
      (_) async => [WaterLog(timestamp: DateTime.now(), amountMl: amount)],
    );

    final notifier = container.read(waterIntakeNotifierProvider.notifier);
    await notifier.addWater(amount);

    expect(container.read(waterIntakeNotifierProvider).currentIntake, amount);
    verify(mockWaterRepository.addWaterLog(any)).called(1);
  });
}
