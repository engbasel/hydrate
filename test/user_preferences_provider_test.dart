import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';
import 'package:mockito/annotations.dart';

import 'user_preferences_provider_test.mocks.dart';

@GenerateMocks([IUserPreferencesRepository])
void main() {
  late UserPreferencesNotifier userPreferencesNotifier;
  late MockIUserPreferencesRepository mockUserPreferencesRepository;

  setUp(() {
    mockUserPreferencesRepository = MockIUserPreferencesRepository();
    userPreferencesNotifier = UserPreferencesNotifier(
      mockUserPreferencesRepository,
    );
  });

  test('initial state is correct', () {
    expect(userPreferencesNotifier.state.dailyGoalMl, 2000);
    expect(userPreferencesNotifier.state.unit, 'ml');
    expect(userPreferencesNotifier.state.notificationIntervals, [
      9,
      12,
      15,
      18,
    ]);
    expect(userPreferencesNotifier.state.darkModeEnabled, false);
    expect(userPreferencesNotifier.state.weightKg, 70);
  });
}
