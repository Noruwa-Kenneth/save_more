import 'package:flutter/material.dart';

import '../widgets/demand_meter.dart';
import '../widgets/grid_status_card.dart';
import '../widgets/prediction_card.dart';

import 'package:save_more/theme.dart';

import 'peak_forecast.dart';

import 'package:save_more/core/data/rate_database.dart';
import 'package:save_more/core/models/energy_recommendation.dart';
import 'package:save_more/core/models/peak_prediction.dart';
import 'package:save_more/core/models/user_rate_plan.dart';
import 'package:save_more/core/services/peak_prediction_service.dart';
import 'package:save_more/core/services/recommendation_service.dart';
import 'package:save_more/core/services/rate_schedule_service.dart';
import 'package:save_more/core/services/user_rate_plan_service.dart';
import 'package:save_more/core/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PeakPrediction? _prediction;
  EnergyRecommendation? _recommendation;

  final WeatherService _weatherService = WeatherService();
  final PeakPredictionService _predictionService = PeakPredictionService();

  final RecommendationService _recommendationService =
      const RecommendationService();

  final RateScheduleService _rateScheduleService = const RateScheduleService();

  final UserRatePlanService _userRatePlanService = UserRatePlanService.instance;

  @override
  void initState() {
    super.initState();

    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      // 1. Get current weather
      final weather = await _weatherService.getCurrentWeather(
        latitude: 44.6488,
        longitude: -63.5752,
      );

      // 2. Calculate demand prediction
      final prediction = _predictionService.calculate(weather: weather);

      // 3. Get the user's selected electricity plan
      final UserRatePlan selectedPlan = _userRatePlanService.selectedPlan;

      // 4. Get the corresponding rate
      final electricityRate = RateDatabase.getRateForPlan(selectedPlan);

      // 5. Get the rate that applies right now
      final currentRate = _rateScheduleService.getCurrentPeriod(
        rate: electricityRate,
        dateTime: DateTime.now(),
      );

      // 5a. Get the best time to use appliances based on the current rate and prediction
      final bestTime = _rateScheduleService.getBestTimeToUse(
        rate: electricityRate,
        dateTime: DateTime.now(),
      );
      // 6. Create the recommendation
      final recommendation = _recommendationService.createRecommendation(
        currentRate: currentRate,
        currentDemandScore: prediction.score.toDouble(),
        recommendedTimeRange:
            bestTime?.startTime != null && bestTime?.endTime != null
            ? '${bestTime!.startTime} – ${bestTime.endTime}'
            : prediction.recommendedTimeRange,
      );

      if (!mounted) return;

      setState(() {
        _prediction = prediction;
        _recommendation = recommendation;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _prediction = null;
        _recommendation = null;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,

      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        titleSpacing: 0,

        title: Stack(
          alignment: Alignment.center,
          children: [
            /// Center Greeting
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_getGreeting()} 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "Welcome to PeakSaver NS",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            /// Location - Left
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Halifax, NS',
                    isDense: true,

                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),

                    dropdownColor: Colors.white,

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),

                    selectedItemBuilder: (BuildContext context) {
                      return const [
                        Text(
                          'Halifax',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Dartmouth',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ];
                    },

                    items: const [
                      DropdownMenuItem(
                        value: 'Halifax, NS',
                        child: Text('Halifax'),
                      ),
                      DropdownMenuItem(
                        value: 'Dartmouth, NS',
                        child: Text('Dartmouth'),
                      ),
                    ],

                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
          ],
        ),

        /// Notification - Right
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),

              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.highDemand,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          // Deep Navy Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.primaryNavy,
          ),

          // White Section
          Positioned(
            top: 400,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: const Color.fromARGB(255, 235, 231, 231)),
          ),

          // Scrollable Dashboard
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Electricity\nPeak Status',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// DEMAND METER
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _prediction == null
                            ? const SizedBox(
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : DemandMeter(
                                percentage: _prediction!.score / 100,
                                statusText: _prediction!.statusText,
                                labelText: 'Grid Demand',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PeakForecastPage(
                                        onBack: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    /// TODAY'S OUTLOOK
                    const SizedBox(height: 16),

                    _prediction == null
                        ? const SizedBox.shrink()
                        : PredictionCard(
                            day: "Today's Outlook",
                            timeRange: _prediction!.timeRange,
                            demandLevel: _prediction!.demandText,
                          ),

                    /// BEST TIME TO USE APPLIANCES
                    const SizedBox(height: 16),

                    _prediction == null || _recommendation == null
                        ? const SizedBox.shrink()
                        : GridStatusCard(
                            title: "Best Time to Use Appliances",

                            timeRange: _recommendation!.timeRange,

                            subtitle: _recommendation!.subtitle,

                            demandColor: _recommendation!.isLowerCost
                                ? AppColors.lowDemand
                                : AppColors.moderateDemand,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
