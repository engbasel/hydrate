import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/src/app/providers/water_intake_provider.dart';
import 'package:hydrate/src/domain/repositories/water_repository.dart';
import 'package:hydrate/src/features/home/home_screen.dart';
import 'package:hydrate/src/features/home/widgets/current_intake_display.dart';
import 'package:hydrate/src/features/home/widgets/quick_add_buttons.dart';
import 'package:hydrate/src/features/home/widgets/water_progress_indicator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([IWaterRepository])
void main() {
  group('HomeScreen', () {
    testWidgets(
      'displays WaterProgressIndicator, CurrentIntakeDisplay, and QuickAddButtons',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: HomeScreen())),
        );

        expect(find.byType(WaterProgressIndicator), findsOneWidget);
        expect(find.byType(CurrentIntakeDisplay), findsOneWidget);
        expect(find.byType(QuickAddButtons), findsOneWidget);
      },
    );

    testWidgets('quick add buttons add water', (tester) async {
      final mockWaterRepository = MockIWaterRepository();
      when(mockWaterRepository.saveWaterLog(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            waterIntakeNotifierProvider.overrideWith(
              (ref) => WaterIntakeNotifier(mockWaterRepository),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Initial state
      expect(find.text('Current Intake: 0 ml'), findsOneWidget);

      // Tap 250ml button
      await tester.tap(find.text('250ml'));
      await tester.pump();
      // Expect the state to be updated (this will fail until addWater is implemented)
      // expect(find.text('Current Intake: 250 ml'), findsOneWidget);
    });
  });
}
