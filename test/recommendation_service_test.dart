import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/models/electricity_rate.dart';
import 'package:save_more/core/services/recommendation_service.dart';

void main() {
  const service = RecommendationService();

  group('Recommendation Service', () {
    test('Low demand + Off-Peak should recommend lower demand and lower cost',
        () {
      const rate = RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 PM',
        endTime: '7:00 AM',
      );

      final result = service.createRecommendation(
        currentRate: rate,
        currentDemandScore: 30,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Lower demand • Lower cost');
      expect(result.isLowerCost, true);
      expect(result.demandLabel, 'Low demand');
    });

    test('Low demand + flat rate should only say lower demand', () {
      final result = service.createRecommendation(
        currentRate: null,
        currentDemandScore: 30,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Lower demand');
      expect(result.isLowerCost, false);
      expect(result.demandLabel, 'Low demand');
    });

    test('High demand + peak rate should recommend shifting usage', () {
      const rate = RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '4:00 PM',
        endTime: '11:00 PM',
      );

      final result = service.createRecommendation(
        currentRate: rate,
        currentDemandScore: 85,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Consider shifting usage');
      expect(result.isLowerCost, false);
      expect(result.demandLabel, 'Higher demand');
    });

    test('Moderate demand + Off-Peak should recognize lower cost', () {
      const rate = RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 PM',
        endTime: '7:00 AM',
      );

      final result = service.createRecommendation(
        currentRate: rate,
        currentDemandScore: 60,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Lower cost');
      expect(result.isLowerCost, true);
    });


    test('Standard Residential should not claim lower electricity cost', () {
  final result = service.createRecommendation(
    currentRate: null,
    currentDemandScore: 30,
    recommendedTimeRange: '9:00 PM – 7:00 AM',
  );

  expect(result.subtitle, 'Lower demand');
  expect(result.isLowerCost, false);
});
  });
}