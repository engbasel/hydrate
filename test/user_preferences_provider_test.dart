import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/providers/notification_provider.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';
import 'package:hydrate/core/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/core/services/notification_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_preferences_provider_test.mocks.dart';
import 'test_helper.dart';

class _FakeNotificationService extends Fake implements NotificationService {
  @override
  Future<void> scheduleIntervalReminders(int intervalMinutes) async {}

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<bool> areNotificationsEnabled() async => false;
}

@GenerateMocks([IUserPreferencesRepository])
void main() {
  late ProviderContainer container;
  late MockIUserPreferencesRepository mockUserPreferencesRepository;

  setUp(() async {
    await initHive();
    mockUserPreferencesRepository = MockIUserPreferencesRepository();
    when(mockUserPreferencesRepository.loadUserPreferences()).thenAnswer((_) async => null);
    when(mockUserPreferencesRepository.saveUserPreferences(any)).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      userPreferencesRepositoryProvider.overrideWithValue(mockUserPreferencesRepository),
      notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
    ]);
  });

  tearDown(() => container.dispose());

  test('initial state is correct', () {
    final state = container.read(userPreferencesProvider);
    expect(
      state,
      UserPreferences(
        dailyGoalMl: 2000,
        unit: 'ml',
        notificationIntervalMinutes: 60,
        darkModeEnabled: false,
        weightKg: 70,
      ),
    );
  });

  test('loadUserPreferences should update the state', () async {
    final preferences = UserPreferences(
      dailyGoalMl: 2500,
      unit: 'oz',
      notificationIntervalMinutes: 180,
      darkModeEnabled: true,
      weightKg: 80,
    );
    when(mockUserPreferencesRepository.loadUserPreferences()).thenAnswer((_) async => preferences);

    await container.read(userPreferencesProvider.notifier).loadUserPreferences();

    expect(container.read(userPreferencesProvider), preferences);
  });

  test('updateGoal should update the state and save the preferences', () async {
    const newGoal = 3000.0;

    await container.read(userPreferencesProvider.notifier).updateGoal(newGoal);

    expect(container.read(userPreferencesProvider).dailyGoalMl, newGoal);
    verify(mockUserPreferencesRepository.saveUserPreferences(any)).called(greaterThanOrEqualTo(1));
  });
}
