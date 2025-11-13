import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/app/providers/history_provider.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';

import 'history_provider_test.mocks.dart';

@GenerateMocks([IWaterRepository])
void main() {
  late HistoryNotifier historyNotifier;
  late MockIWaterRepository mockWaterRepository;

  setUp(() {
    mockWaterRepository = MockIWaterRepository();
    historyNotifier = HistoryNotifier(mockWaterRepository);
  });

  test('initial state is an empty list', () {
    expect(historyNotifier.state, []);
  });
}
