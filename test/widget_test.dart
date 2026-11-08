import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:save_more/core/models/grid_demand_reading.dart';
import 'package:save_more/core/providers/grid_demand_provider.dart';
import 'package:save_more/main.dart';

void main() {
  testWidgets('PeakSaver NS app starts successfully', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveGridDemandProvider.overrideWith(
            (ref) => Stream.value(
              const GridDemandStatus(
                refreshMessage: 'Live grid source is mocked in this test.',
              ),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Allow the splash screen's timer to complete.
    await tester.pump(const Duration(seconds: 6));

    // Verify that the app started without an exception.
    expect(tester.takeException(), isNull);
  });
}
