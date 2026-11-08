import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/services/grid_demand_service.dart';

void main() {
  group('GridDemandService.parseReport', () {
    test('reads net load and the report timestamp', () {
      const html = '''
        <html><body>
          <h2>Current System Conditions</h2>
          <p>Last Updated: 07-Nov-26 06:41 MW</p>
          <table><tr><td>Net Load</td><td>1,007.0</td></tr></table>
        </body></html>
      ''';

      final reading = GridDemandService.parseReport(
        html,
        fetchedAtUtc: DateTime.utc(2026, 11, 8, 12),
      );

      expect(reading.netLoadMw, 1007.0);
      // 06:41 Atlantic Standard Time is 10:41 UTC.
      expect(reading.reportedAtUtc, DateTime.utc(2026, 11, 7, 10, 41));
    });

    test('rejects a report without a current net-load value', () {
      expect(
        () => GridDemandService.parseReport(
          '<html><body>Report unavailable</body></html>',
          fetchedAtUtc: DateTime.utc(2026, 11, 8),
        ),
        throwsFormatException,
      );
    });
  });
}
