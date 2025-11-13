import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/app/providers/history_provider.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'history_provider_test.mocks.dart';
import 'test_helper.dart';

@GenerateMocks([IWaterRepository])
void main() {
  late HistoryNotifier historyNotifier;
  late MockIWaterRepository mockWaterRepository;

  setUp(() async {
    await initHive();
    mockWaterRepository = MockIWaterRepository();
    when(
      mockWaterRepository.getWaterIntakeHistory(),
    ).thenAnswer((_) async => []);
    historyNotifier = HistoryNotifier(mockWaterRepository);
  });

  test('initial state is an empty list', () {
    expect(historyNotifier.state.history, []);
  });

  test('loadHistory should update the state with the history', () async {
    final history = [DailySummary(date: DateTime.now(), totalIntakeMl: 1500)];
    when(
      mockWaterRepository.getWaterIntakeHistory(),
    ).thenAnswer((_) async => history);

    await historyNotifier.loadHistory();

    expect(historyNotifier.state.history, history);
  });
}
