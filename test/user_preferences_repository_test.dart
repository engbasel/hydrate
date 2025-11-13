import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hydrate/src/data/repositories/user_preferences_repository_impl.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_preferences_repository_test.mocks.dart';
import 'test_helper.dart';

@GenerateMocks([Box])
void main() {
  late UserPreferencesRepositoryImpl userPreferencesRepository;
  late MockBox<UserPreferences> mockUserPreferencesBox;

  setUp(() async {
    await initHive();
    mockUserPreferencesBox = MockBox<UserPreferences>();
    userPreferencesRepository = UserPreferencesRepositoryImpl(
      mockUserPreferencesBox,
    );
  });

  group('UserPreferencesRepository', () {
    test('saveUserPreferences should put preferences in the box', () async {
      final preferences = UserPreferences(
        dailyGoalMl: 2000,
        unit: 'ml',
        notificationIntervals: [9, 12, 15, 18],
        darkModeEnabled: false,
        weightKg: 70,
      );
      when(mockUserPreferencesBox.put(any, any)).thenAnswer((_) async => {});

      await userPreferencesRepository.saveUserPreferences(preferences);

      verify(
        mockUserPreferencesBox.put('user_preferences', preferences),
      ).called(1);
    });

    test(
      'loadUserPreferences should return preferences from the box',
      () async {
        final preferences = UserPreferences(
          dailyGoalMl: 2000,
          unit: 'ml',
          notificationIntervals: [9, 12, 15, 18],
          darkModeEnabled: false,
          weightKg: 70,
        );
        when(mockUserPreferencesBox.get(any)).thenReturn(preferences);

        final result = await userPreferencesRepository.loadUserPreferences();

        expect(result, preferences);
      },
    );
  });
}
