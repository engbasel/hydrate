import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/app/providers/water_intake_provider.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'test_helper.dart';
import 'water_intake_provider_test.mocks.dart';

@GenerateMocks([IWaterRepository])
void main() {
  late WaterIntakeNotifier waterIntakeNotifier;
  late MockIWaterRepository mockWaterRepository;

  setUp(() async {
    await initHive();
    mockWaterRepository = MockIWaterRepository();
    waterIntakeNotifier = WaterIntakeNotifier(mockWaterRepository);
  });

  test('initial state is correct', () {
    expect(waterIntakeNotifier.state.currentIntake, 0);
    expect(waterIntakeNotifier.state.dailyGoal, 2000);
    expect(waterIntakeNotifier.state.unit, 'ml');
  });

  test(
    'addWater should update the current intake and call the repository',
    () async {
      const amount = 250.0;
      when(mockWaterRepository.addWaterLog(any)).thenAnswer((_) async => {});

      await waterIntakeNotifier.addWater(amount);

      expect(waterIntakeNotifier.state.currentIntake, amount);
      verify(mockWaterRepository.addWaterLog(any)).called(1);
    },
  );
}
