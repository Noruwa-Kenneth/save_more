import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:save_more/core/models/app_location.dart';
import 'package:save_more/core/providers/home_dashboard_provider.dart';
import 'package:save_more/core/providers/location_provider.dart';
import 'package:save_more/theme.dart';

import '../widgets/demand_meter.dart';
import '../widgets/grid_status_card.dart';
import '../widgets/prediction_card.dart';
import 'peak_forecast.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _openPeakForecast(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PeakForecastPage(
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        titleSpacing: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Welcome to PeakSaver NS',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppLocation>(
                    value: location,
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
                    selectedItemBuilder: (context) {
                      return AppLocation.all.map((loc) {
                        return Text(
                          loc.shortName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                    items: AppLocation.all.map((loc) {
                      return DropdownMenuItem(
                        value: loc,
                        child: Text(loc.shortName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      ref.read(locationProvider.notifier).setLocation(value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
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
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.primaryNavy,
          ),
          Positioned(
            top: 400,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: const Color.fromARGB(255, 235, 231, 231)),
          ),
          SafeArea(
            child: dashboardAsync.when(
              loading: () => const _HomeLoadingBody(),
              error: (error, _) => _HomeErrorBody(
                message: error.toString(),
                onRetry: () => ref.invalidate(homeDashboardProvider),
              ),
              data: (data) => _HomeSuccessBody(
                data: data,
                onOpenPeakForecast: () => _openPeakForecast(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingBody extends StatelessWidget {
  const _HomeLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Loading energy data…',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HomeErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Could not load energy data',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSuccessBody extends StatelessWidget {
  final HomeDashboardData data;
  final VoidCallback onOpenPeakForecast;

  const _HomeSuccessBody({
    required this.data,
    required this.onOpenPeakForecast,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = data.prediction;
    final recommendation = data.recommendation;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            // Meter = grid demand right now
            Center(
              child: DemandMeter(
                percentage: prediction.score / 100,
                statusText: prediction.statusText,
                labelText: 'Grid Demand',
                onTap: onOpenPeakForecast,
              ),
            ),
            const SizedBox(height: 16),
            // Outlook = today's forecast peak window (same as Peak Forecast)
            PredictionCard(
              day: "Today's Outlook",
              timeRange: data.outlookTimeRange,
              demandLevel: data.outlookDemandLevel,
              onTap: onOpenPeakForecast,
            ),
            const SizedBox(height: 16),
            GridStatusCard(
              title: 'Best Time to Use Appliances',
              timeRange: recommendation.timeRange,
              subtitle: recommendation.subtitle,
              demandColor: recommendation.isLowerCost
                  ? AppColors.lowDemand
                  : AppColors.moderateDemand,
            ),
          ],
        ),
      ),
    );
  }
}
