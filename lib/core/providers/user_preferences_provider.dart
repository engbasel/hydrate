import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/providers/notification_provider.dart';
import 'package:hydrate/core/services/notification_service.dart';
import 'package:hydrate/core/data/repositories/dummy_user_preferences_repository.dart';
import 'package:hydrate/core/data/repositories/user_preferences_repository_impl.dart';
import 'package:hydrate/core/utils/app_initializer.dart';
import 'package:hydrate/core/domain/use_cases/calculate_recommended_intake.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
      final repository = ref.watch(userPreferencesRepositoryProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      return UserPreferencesNotifier(repository, ref, notificationService);
    });

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final IUserPreferencesRepository _userPreferencesRepository;
  final Ref _ref;
  final NotificationService _notificationService;
  final CalculateRecommendedIntake _calculateRecommendedIntake =
      CalculateRecommendedIntake();

  UserPreferencesNotifier(
    this._userPreferencesRepository,
    this._ref,
    this._notificationService,
  ) : super(AppInitializer.getInitialPreferences()) {
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
    
    // Also save to SharedPreferences for background notification access
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode_enabled', value);
      print('Dark mode preference saved: $value');
    } catch (e) {
      print('Failed to save dark mode preference: $e');
    }
  }

  Future<void> updateNotificationInterval(int intervalMinutes) async {
    state = state.copyWith(notificationIntervalMinutes: intervalMinutes);
    await _userPreferencesRepository.saveUserPreferences(state);
    // Schedule new notifications without sending an immediate one
    await _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    try {
      await _notificationService.scheduleIntervalReminders(
        state.notificationIntervalMinutes,
      );
    } catch (e) {
      // Handle notification scheduling errors silently
      print('Failed to schedule notifications: $e');
    }
  }

  Future<void> updateWeight(double newWeight) async {
    // Calculate new recommended intake based on weight
    final recommendedIntake = _calculateRecommendedIntake(newWeight);

    state = state.copyWith(weightKg: newWeight, dailyGoalMl: recommendedIntake);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  double getRecommendedIntakeForCurrentWeight() {
    return _calculateRecommendedIntake(state.weightKg);
  }

  bool isUsingRecommendedGoal() {
    final recommended = getRecommendedIntakeForCurrentWeight();
    return (state.dailyGoalMl - recommended).abs() <
        50; // Within 50ml tolerance
  }

  Future<void> updateDailyGoal(double newGoalMl) async {
    state = state.copyWith(dailyGoalMl: newGoalMl);
    await _userPreferencesRepository.saveUserPreferences(state);
  }
}
