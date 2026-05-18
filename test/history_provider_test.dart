import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/providers/history_provider.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'history_provider_test.mocks.dart';
import 'test_helper.dart';

@GenerateMocks([IWaterRepository])
void main() {
  late ProviderContainer container;
  late MockIWaterRepository mockWaterRepository;

  setUp(() async {
    await initHive();
    mockWaterRepository = MockIWaterRepository();
    when(mockWaterRepository.getWaterIntakeHistory()).thenAnswer((_) async => []);
    // Stub calls made by WaterIntakeNotifier during initialization
    when(mockWaterRepository.getWaterLogsForDate(any)).thenAnswer((_) async => []);
    when(mockWaterRepository.addDailySummary(any)).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      waterRepositoryProvider.overrideWithValue(mockWaterRepository),
    ]);
  });

  tearDown(() => container.dispose());

  test('initial state is an empty list', () {
    final state = container.read(historyProvider);
    expect(state.history, []);
  });

  test('loadHistory should update the state with the history', () async {
    final history = [DailySummary(date: DateTime.now(), totalIntakeMl: 1500)];
    when(mockWaterRepository.getWaterIntakeHistory()).thenAnswer((_) async => history);

    await container.read(historyProvider.notifier).loadHistory();

    expect(container.read(historyProvider).history, history);
  });
}
