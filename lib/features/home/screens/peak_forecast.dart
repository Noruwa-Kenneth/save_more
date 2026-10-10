import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:save_more/core/models/demand_forecast.dart';
import 'package:save_more/core/models/peak_prediction.dart';
import 'package:save_more/core/providers/peak_forecast_provider.dart';
import '/theme.dart';
import '../widgets/demand_chart.dart';

class PeakForecastPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const PeakForecastPage({super.key, required this.onBack});

  @override
  ConsumerState<PeakForecastPage> createState() => _PeakForecastPageState();
}

class _PeakForecastPageState extends ConsumerState<PeakForecastPage> {
  ForecastRange _selectedRange = ForecastRange.today;

  @override
  Widget build(BuildContext context) {
    final forecastAsync = ref.watch(peakForecastProvider(_selectedRange));

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              color: AppColors.primaryNavy,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 8,
                    child: IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const Text(
                    'Peak Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 44,
                          width: double.infinity,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _buildTab(
                                title: 'Today',
                                range: ForecastRange.today,
                              ),
                              _buildTab(
                                title: 'Tomorrow',
                                range: ForecastRange.tomorrow,
                              ),
                              _buildTab(
                                title: '7 Days',
                                range: ForecastRange.next7Days,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        forecastAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          error: (error, _) => _ErrorState(
                            message: error.toString(),
                            onRetry: () => ref.invalidate(
                              peakForecastProvider(_selectedRange),
                            ),
                          ),
                          data: (forecast) => _ForecastContent(
                            forecast: forecast,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab() {
    final selected = _selectedRange == range;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRange = range);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.secondaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF222222),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ForecastContent extends StatelessWidget {
  final DemandForecast forecast;

  const _ForecastContent({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final peakColor = switch (forecast.peakLevel) {
      DemandLevel.high => AppColors.highDemand,
      DemandLevel.moderate => AppColors.moderateDemand,
      DemandLevel.low => AppColors.lowDemand,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          forecast.dateLabel,
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 190,
          child: DemandForecastChart(
            points: forecast.points,
            range: forecast.range,
            peakMarkerTime: forecast.peakStart,
          ),
        ),
        const SizedBox(height: 18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem(color: AppColors.lowDemand, text: 'Low (0–40%)'),
            const SizedBox(height: 10),
            _legendItem(
              color: AppColors.moderateDemand,
              text: 'Moderate (40–70%)',
            ),
            const SizedBox(height: 10),
            _legendItem(color: AppColors.highDemand, text: 'High (70–100%)'),
          ],
        ),
        if (forecast.recommendedTimeRange != null) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCDE6D4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Better time for appliances',
                  style: TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  forecast.recommendedTimeRange!,
                  style: const TextStyle(
                    color: Color(0xFF267443),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This is the lowest-demand consecutive window in the forecast. If it fits your routine, shift flexible use such as laundry or dishwashing to this time.',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (forecast.recommendedAverageRate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Estimated plan rate: ${forecast.recommendedAverageRate!.toStringAsFixed(2)}¢/kWh',
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E7E7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peak period',
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      forecast.peakTimeRange,
                      style: TextStyle(
                        color: peakColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Peak score ~${forecast.peakScore}%',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      forecast.peakAdvice,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 2),
                child: CustomPaint(
                  size: const Size(26, 26),
                  painter: ClockPainter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF222222), fontSize: 13),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Could not load forecast',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;

    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.48), paint);
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.48, center.dy + radius * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
