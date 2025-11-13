# Hydrate

A Flutter water reminder and tracking app.

## Features

- **Water Intake Tracking:** Easily log your daily water intake.
- **Daily Goal Setting:** Set and track your personalized daily hydration goals.
- **Unit Customization:** Choose between milliliters (ml) and ounces (oz) for water intake.
- **Notification Reminders:** Set custom intervals to receive reminders to drink water.
- **Weight-based Recommendation:** Get a recommended daily water intake based on your weight.
- **Dark Mode:** Toggle between light and dark themes for comfortable viewing.
- **History and Statistics:** View your daily, weekly, and monthly water intake history with interactive charts.

## Getting Started

### Prerequisites

- Flutter SDK installed.
- A code editor like VS Code or Android Studio.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/hydrate.git
    cd hydrate
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Generate Hive adapters (if models are changed):**
    ```bash
    flutter packages pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

The project follows a clean architecture pattern with the following layers:

-   **`lib/src/app`**: Contains Riverpod providers for state management and dependency injection.
-   **`lib/src/domain`**: Defines core business logic, models (`WaterLog`, `UserPreferences`, `DailySummary`), and repository interfaces.
-   **`lib/src/data`**: Implements data sources and repositories (e.g., `HiveService`, `WaterRepositoryImpl`, `UserPreferencesRepositoryImpl`).
-   **`lib/src/features`**: Contains UI and specific logic for different features (e.g., `home`, `history`, `settings`).
-   **`lib/main.dart`**: The application entry point, responsible for setting up the main app structure and navigation.

## Contributing

Contributions are welcome! Please feel free to open issues or pull requests.

## License

This project is licensed under the MIT License.