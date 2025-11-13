**2025-11-13**
*   **Phase 6:** Settings Screen UI.
*   **Learnings:**
    *   None.
*   **Surprises:**
    *   None.
*   **Deviations:**
    *   None.

---

## Phase 1: Project Setup and Initialization

- [x] Create a Flutter package in the current directory (`/home/duhhh/Documents/GitHub/hydrate`).
- [x] Remove any boilerplate in the new package that will be replaced, including the `test` directory.
- [x] Update the `description` of the package in `pubspec.yaml` and set the version to `0.1.0`.
- [x] Update `README.md` to include a short placeholder description of the package.
- [x] Create `CHANGELOG.md` with the initial version `0.1.0`.
- [x] Commit this empty version of the package to the current branch.
- [ ] After committing the change, start running the app with the `launch_app` tool on the user's preferred device.

After completing a task, if you added any TODOs to the code or didn't fully implement anything, make sure to add new tasks so that you can come back and complete them later.

After this phase, I will:
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart_format` to make sure that the formatting is correct.
- [ ] Re-read the `IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the `IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if the app is running, use the `hot_reload` tool to reload it.

## Phase 2: Core Data and Domain Layer

- [x] Create the directory structure for the app (`lib/src`, `lib/src/features`, `lib/src/core`, etc.).
- [x] Define the data models in the domain layer: `WaterLog`, `UserPreferences`, `DailySummary`.
- [x] Add the necessary dependencies to `pubspec.yaml`: `flutter_riverpod`, `hive`, `hive_flutter`, `flutter_local_notifications`, `fl_chart`, `path_provider`.
- [x] Run `flutter pub get`.
- [x] Create the `HiveService` in the infrastructure layer to handle Hive initialization and box management.
- [x] Generate `TypeAdapter`s for the data models.
- [x] Define the repository interfaces in the domain layer (e.g., `IWaterRepository`, `IUserPreferencesRepository`).
- [x] Implement the repositories in the infrastructure layer using Hive.

After this phase, I will perform the post-phase checks as outlined in Phase 1.

## Phase 3: State Management and Application Layer

- [x] Implement the Riverpod providers in the application layer:
    - `WaterIntakeNotifier`
    - `UserPreferencesNotifier`
    - `HistoryNotifier`
- [x] Implement the `NotificationService` to wrap `flutter_local_notifications`.
- [x] Implement the logic for calculating recommended water intake.
- [x] Implement the logic for resetting the counter at midnight.

After this phase, I will perform the post-phase checks as outlined in Phase 1.

## Phase 4: Home Screen UI

- [x] Create the `HomeScreen` widget.
- [x] Implement the `WaterProgressIndicator` widget with animations.
- [x] Implement the `CurrentIntakeDisplay` widget.
- [x] Implement the `QuickAddButtons` widget.
- [x] Connect the UI to the `WaterIntakeNotifier` to display and update data.

After this phase, I will perform the post-phase checks as outlined in Phase 1.

## Phase 5: History Screen UI

- [x] Create the `HistoryScreen` widget.
- [x] Implement the `DailyChart`, `WeeklyChart`, and `MonthlyChart` widgets using `fl_chart`.
- [x] Implement a date range selector.
- [x] Connect the UI to the `HistoryNotifier` to display historical data.

After this phase, I will perform the post-phase checks as outlined in Phase 1.

## Phase 6: Settings Screen UI

- [ ] Create the `SettingsScreen` widget.
- [ ] Implement the `GoalSetting`, `UnitSelector`, `NotificationPreferences`, `WeightInput`, and `DarkModeToggle` widgets.
- [ ] Connect the UI to the `UserPreferencesNotifier` to display and update settings.

After this phase, I will perform the post-phase checks as outlined in Phase 1.

## Phase 7: Finalization and Documentation

- [ ] Create a comprehensive `README.md` file for the package.
- [ ] Create a `GEMINI.md` file in the project directory that describes the app, its purpose, and implementation details of the application and the layout of the files.
- [ ] Ask the user to inspect the app and the code and say if they are satisfied with it, or if any modifications are needed.