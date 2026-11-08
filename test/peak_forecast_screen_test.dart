import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/models/demand_forecast.dart';
import 'package:save_more/core/providers/peak_forecast_provider.dart';
import 'package:save_more/features/home/screens/peak_forecast.dart';

void main() {
  testWidgets('shows an error message and retry control when forecast fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // Riverpod 3 retries provider failures by default. Disable retries here
        // so the test can assert the screen's terminal error state directly.
        retry: (retryCount, error) => null,
        overrides: [
          peakForecastProvider(ForecastRange.today).overrideWith(
            (ref) async => throw Exception('Weather service unavailable'),
          ),
        ],
        child: MaterialApp(home: PeakForecastPage(onBack: _doNothing)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load forecast'), findsOneWidget);
    expect(find.textContaining('Weather service unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

void _doNothing() {}
