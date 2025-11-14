import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/domain/models/user_preferences.dart';
import 'package:hydrate/src/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/src/app/providers/repository_providers.dart';
import 'package:hydrate/src/app/providers/notification_provider.dart';
import 'package:hydrate/src/app/services/notification_service.dart';
import 'package:hydrate/src/data/repositories/dummy_user_preferences_repository.dart';
import 'package:hydrate/src/data/repositories/user_preferences_repository_impl.dart';
import 'package:hydrate/src/app/app_initializer.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      (ref) {
        final repository = ref.watch(userPreferencesRepositoryProvider);
        final notificationService = ref.watch(notificationServiceProvider);
        return UserPreferencesNotifier(repository, ref, notificationService);
      },
    );

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final IUserPreferencesRepository _userPreferencesRepository;
  final Ref _ref;
  final NotificationService _notificationService;

  UserPreferencesNotifier(this._userPreferencesRepository, this._ref, this._notificationService)
    : super(AppInitializer.getInitialPreferences()) {
    // Load saved preferences on initialization if we have a real repository
    // Only load if we haven't already loaded them during app initialization
    if (_userPreferencesRepository is! DummyUserPreferencesRepository && 
        !AppInitializer.hasLoadedPreferences) {
      _loadInitialPreferences();
    } else if (_userPreferencesRepository is! DummyUserPreferencesRepository) {
      // If preferences were already loaded, just schedule notifications
      _scheduleNotifications();
    }
  }

  Future<void> _loadInitialPreferences() async {
    await loadUserPreferences();
    // Schedule initial notifications after loading preferences
    await _scheduleNotifications();
  }

  Future<void> loadUserPreferences() async {
    final preferences = await _userPreferencesRepository.loadUserPreferences();
    if (preferences != null) {
      state = preferences;
    }
  }

  Future<void> updateGoal(double newGoal) async {
    state = state.copyWith(dailyGoalMl: newGoal);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> updateUnit(String newUnit) async {
    state = state.copyWith(unit: newUnit);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> updateNotificationInterval(int intervalMinutes) async {
    state = state.copyWith(notificationIntervalMinutes: intervalMinutes);
    await _userPreferencesRepository.saveUserPreferences(state);
    // Schedule new notifications
    await _scheduleNotifications();
  }
  
  Future<void> _scheduleNotifications() async {
    try {
      await _notificationService.scheduleIntervalReminders(state.notificationIntervalMinutes);
    } catch (e) {
      // Handle notification scheduling errors silently
      print('Failed to schedule notifications: $e');
    }
  }

  Future<void> updateWeight(double newWeight) async {
    state = state.copyWith(weightKg: newWeight);
    await _userPreferencesRepository.saveUserPreferences(state);
  }
}
