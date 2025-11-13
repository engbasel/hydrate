import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hydrate/src/data/repositories/water_repository_impl.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';
import 'package:hydrate/src/domain/models/water_log.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'water_repository_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late WaterRepositoryImpl waterRepository;
  late MockBox<WaterLog> mockWaterLogBox;
  late MockBox<DailySummary> mockDailySummaryBox;

  setUp(() {
    mockWaterLogBox = MockBox<WaterLog>();
    mockDailySummaryBox = MockBox<DailySummary>();
    waterRepository = WaterRepositoryImpl(mockWaterLogBox, mockDailySummaryBox);
  });

  group('WaterRepository', () {
    test('saveWaterLog should add a log to the box', () async {
      final waterLog = WaterLog(timestamp: DateTime.now(), amountMl: 250);
      when(mockWaterLogBox.add(any)).thenAnswer((_) async => 0);

      await waterRepository.saveWaterLog(waterLog);

      verify(mockWaterLogBox.add(waterLog)).called(1);
    });

    test(
      'getWaterLogsForDate should return logs for the specified date',
      () async {
        final date = DateTime.now();
        final waterLogs = [
          WaterLog(timestamp: date, amountMl: 250),
          WaterLog(
            timestamp: date.subtract(const Duration(days: 1)),
            amountMl: 500,
          ),
          WaterLog(timestamp: date, amountMl: 1000),
        ];
        when(mockWaterLogBox.values).thenReturn(waterLogs);

        final result = await waterRepository.getWaterLogsForDate(date);

        expect(result.length, 2);
        expect(result[0].amountMl, 250);
        expect(result[1].amountMl, 1000);
      },
    );

    test('saveDailySummary should put a summary in the box', () async {
      final summary = DailySummary(date: DateTime.now(), totalIntakeMl: 1500);
      when(mockDailySummaryBox.put(any, any)).thenAnswer((_) async => {});

      await waterRepository.saveDailySummary(summary);

      verify(
        mockDailySummaryBox.put(summary.date.toIso8601String(), summary),
      ).called(1);
    });

    test(
      'getDailySummaryForDate should return a summary for the specified date',
      () async {
        final date = DateTime.now();
        final summary = DailySummary(date: date, totalIntakeMl: 1500);
        when(mockDailySummaryBox.get(any)).thenReturn(summary);

        final result = await waterRepository.getDailySummaryForDate(date);

        expect(result, summary);
      },
    );

    test('getAllDailySummaries should return all summaries', () async {
      final summaries = [
        DailySummary(date: DateTime.now(), totalIntakeMl: 1500),
        DailySummary(
          date: DateTime.now().subtract(const Duration(days: 1)),
          totalIntakeMl: 2000,
        ),
      ];
      when(mockDailySummaryBox.values).thenReturn(summaries);

      final result = await waterRepository.getAllDailySummaries();

      expect(result, summaries);
    });
  });
}
