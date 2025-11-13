import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_preferences_provider_test.mocks.dart';
import 'test_helper.dart';

@GenerateMocks([IUserPreferencesRepository])
void main() {
  late UserPreferencesNotifier userPreferencesNotifier;
  late MockIUserPreferencesRepository mockUserPreferencesRepository;

  setUp(() async {
    await initHive();
    mockUserPreferencesRepository = MockIUserPreferencesRepository();
    userPreferencesNotifier = UserPreferencesNotifier(
      mockUserPreferencesRepository,
    );
  });

  test('initial state is correct', () {
    expect(
      userPreferencesNotifier.state,
      UserPreferences(
        dailyGoalMl: 2000,
        unit: 'ml',
        notificationIntervals: [9, 12, 15, 18],
        darkModeEnabled: false,
        weightKg: 70,
      ),
    );
  });

  test('loadUserPreferences should update the state', () async {
    final preferences = UserPreferences(
      dailyGoalMl: 2500,
      unit: 'oz',
      notificationIntervals: [10, 14, 18],
      darkModeEnabled: true,
      weightKg: 80,
    );
    when(
      mockUserPreferencesRepository.loadUserPreferences(),
    ).thenAnswer((_) async => preferences);

    await userPreferencesNotifier.loadUserPreferences();

    expect(userPreferencesNotifier.state, preferences);
  });

  test('updateGoal should update the state and save the preferences', () async {
    const newGoal = 3000.0;
    when(
      mockUserPreferencesRepository.saveUserPreferences(any),
    ).thenAnswer((_) async => {});

    await userPreferencesNotifier.updateGoal(newGoal);

    expect(userPreferencesNotifier.state.dailyGoalMl, newGoal);
    verify(mockUserPreferencesRepository.saveUserPreferences(any)).called(1);
  });
}
