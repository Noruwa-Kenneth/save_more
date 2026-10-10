import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/models/electricity_rate.dart';
import 'package:save_more/core/services/recommendation_service.dart';

void main() {
  const service = RecommendationService();

  group('Recommendation Service', () {
    test('Low demand + cheaper recommendation reports lower demand and cost',
        () {
      const currentRate = RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '4:00 PM',
        endTime: '11:00 PM',
      );
      const recommendedRate = RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 PM',
        endTime: '7:00 AM',
      );

      final result = service.createRecommendation(
        currentRate: currentRate,
        recommendedRate: recommendedRate,
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
        recommendedRate: null,
        currentDemandScore: 30,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Lower demand');
      expect(result.isLowerCost, false);
      expect(result.demandLabel, 'Low demand');
    });

    test('High demand + no rate reduction should recommend shifting usage', () {
      const currentRate = RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '4:00 PM',
        endTime: '11:00 PM',
      );

      final result = service.createRecommendation(
        currentRate: currentRate,
        recommendedRate: currentRate,
        currentDemandScore: 85,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Consider shifting usage');
      expect(result.isLowerCost, false);
      expect(result.demandLabel, 'Higher demand');
    });

    test('Moderate demand + cheaper recommendation recognizes lower cost', () {
      const currentRate = RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '4:00 PM',
        endTime: '11:00 PM',
      );
      const recommendedRate = RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 PM',
        endTime: '7:00 AM',
      );

      final result = service.createRecommendation(
        currentRate: currentRate,
        recommendedRate: recommendedRate,
        currentDemandScore: 60,
        recommendedTimeRange: '9:00 PM – 7:00 AM',
      );

      expect(result.subtitle, 'Lower cost');
      expect(result.isLowerCost, true);
    });


    test('Standard Residential should not claim lower electricity cost', () {
  final result = service.createRecommendation(
    currentRate: null,
    recommendedRate: null,
    currentDemandScore: 30,
    recommendedTimeRange: '9:00 PM – 7:00 AM',
  );

  expect(result.subtitle, 'Lower demand');
  expect(result.isLowerCost, false);
});
  });
}
