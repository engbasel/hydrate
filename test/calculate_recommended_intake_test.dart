import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/domain/use_cases/calculate_recommended_intake.dart';

void main() {
  test('calculate recommended intake should return correct value', () {
    final calculateRecommendedIntake = CalculateRecommendedIntake();
    final weightKg = 70.0;
    final expectedIntake = 2450.0;

    final result = calculateRecommendedIntake(weightKg);

    expect(result, expectedIntake);
  });
}
