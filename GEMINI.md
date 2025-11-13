# Hydrate App - Gemini Implementation Details

This document provides an overview of the Hydrate Flutter application, its purpose, and the implementation details, focusing on the architectural layout and key components.

## 1. Application Purpose

The Hydrate app is a simple yet effective water reminder and tracking application built with Flutter. Its primary goal is to help users maintain healthy hydration habits by allowing them to:

-   Log their daily water intake.
-   Set personalized daily hydration goals.
-   Receive timely notifications to drink water.
-   View their water intake history through intuitive charts.
-   Customize units (ml/oz) and other preferences.

## 2. Implementation Details

The application is structured following a clean architecture approach, separating concerns into distinct layers: Domain, Data, and Presentation (UI/Application). Riverpod is used for state management, and Hive serves as the local database for persistence.

### 2.1. Core Technologies

-   **Flutter**: UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
-   **Riverpod**: A reactive caching and data-binding framework for Flutter, used for state management and dependency injection.
-   **Hive**: A lightweight and fast key-value database for Flutter and Dart, used for local data persistence.
-   **`fl_chart`**: A powerful Flutter chart library used for visualizing water intake history.
-   **`flutter_local_notifications`**: A plugin for displaying local notifications.
-   **`equatable`**: A package to simplify equality comparisons in Dart classes.

### 2.2. Architectural Layers

#### 2.2.1. Domain Layer (`lib/src/domain`)

This layer contains the core business logic and entities, independent of any specific implementation details.

-   **`models/`**:
    -   `water_log.dart`: Defines the `WaterLog` model, representing a single instance of water intake.
    -   `user_preferences.dart`: Defines the `UserPreferences` model, storing user-specific settings like daily goal, unit, notification intervals, dark mode preference, and weight.
    -   `daily_summary.dart`: Defines the `DailySummary` model, aggregating water intake for a specific day.
-   **`repositories/`**:
    -   `water_repository.dart`: Abstract interface for water intake data operations.
    -   `user_preferences_repository.dart`: Abstract interface for user preferences data operations.
-   **`use_cases/`**: Contains business logic operations that orchestrate interactions between repositories and models. (Currently, these are implicitly handled within notifiers but could be extracted for more complex logic).

#### 2.2.2. Data Layer (`lib/src/data`)

This layer is responsible for data retrieval, storage, and manipulation. It implements the repository interfaces defined in the domain layer.

-   **`hive_service.dart`**: Handles the initialization of Hive and provides methods to open and manage Hive boxes for different data models.
-   **`repositories/`**:
    -   `water_repository_impl.dart`: Implementation of `IWaterRepository` using Hive for data persistence.
    -   `user_preferences_repository_impl.dart`: Implementation of `IUserPreferencesRepository` using Hive for data persistence.
    -   `dummy_water_repository.dart`: A dummy implementation of `IWaterRepository` for testing or development without actual persistence.
    -   `dummy_user_preferences_repository.dart`: A dummy implementation of `IUserPreferencesRepository`.

#### 2.2.3. Application Layer (`lib/src/app`)

This layer acts as an intermediary between the UI and the domain/data layers. It contains Riverpod providers for state management.

-   **`providers/`**:
    -   `history_provider.dart`: Manages the state related to water intake history.
    -   `repository_providers.dart`: Provides instances of repositories to other parts of the application using Riverpod.
    -   `user_preferences_provider.dart`: Manages the state related to user preferences.
    -   `water_intake_provider.dart`: Manages the state related to current water intake.

#### 2.2.4. Presentation Layer (`lib/src/features`)

This layer contains the user interface components and their associated logic.

-   **`home/`**:
    -   `home_screen.dart`: The main screen for tracking daily water intake.
    -   `widgets/` (e.g., `water_progress_indicator.dart`, `current_intake_display.dart`, `quick_add_buttons.dart`): UI components specific to the home screen.
-   **`history/`**:
    -   `history_screen.dart`: Displays historical water intake data.
    -   `widgets/` (e.g., `daily_chart.dart`, `weekly_chart.dart`, `monthly_chart.dart`): Chart widgets for visualizing historical data.
-   **`settings/`**:
    -   `settings_screen.dart`: Allows users to configure their preferences.
    -   `widgets/` (e.g., `goal_setting.dart`, `unit_selector.dart`, `notification_preferences.dart`, `weight_input.dart`, `dark_mode_toggle.dart`): UI components for various settings.

### 2.3. Main Application Flow (`lib/main.dart`)

The `main.dart` file sets up the root of the Flutter application. It initializes the `MainApp` widget, which uses a `BottomNavigationBar` for navigation between the `HomeScreen`, `HistoryScreen`, and `SettingsScreen`.

## 3. Future Enhancements

-   Implement notification scheduling based on user preferences.
-   Add more robust input validation and error handling in UI components.
-   Expand charting capabilities with more detailed statistics and filtering options.
-   Implement data synchronization with cloud services (e.g., Firebase).

This document serves as a guide to understanding the structure and functionality of the Hydrate app.
