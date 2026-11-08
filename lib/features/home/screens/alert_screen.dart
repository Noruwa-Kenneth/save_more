import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:save_more/core/models/demand_forecast.dart';
import 'package:save_more/core/models/peak_prediction.dart';
import 'package:save_more/core/providers/peak_forecast_provider.dart';
import 'package:save_more/core/services/local_notification_service.dart';
import '/theme.dart';
import 'notifications_screen.dart';

class AlertItem {
  final String title;
  final String timeRange;
  final String body;
  final String type;

  const AlertItem({
    required this.title,
    required this.timeRange,
    required this.body,
    required this.type,
  });
}

class AlertScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const AlertScreen({super.key, required this.onBack});

  @override
  ConsumerState<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends ConsumerState<AlertScreen> {
  static const _range = ForecastRange.next7Days;
  static const _filters = ['All', 'High', 'Tips', 'Savings'];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final forecastAsync = ref.watch(peakForecastProvider(_range));

    return Container(
      color: AppColors.primaryNavy,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Forecast insights',
                            style: TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Based on the latest 7-day forecast. These are '
                            'forecast insights. You can test a notification '
                            'or schedule a local alert on this device.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildFilters(),
                          const SizedBox(height: 18),
                          forecastAsync.when(
                            loading: _buildLoading,
                            error: (error, _) => _buildError(
                              onRetry: () =>
                                  ref.invalidate(peakForecastProvider(_range)),
                            ),
                            data: (forecast) =>
                                _buildForecastInsights(forecast),
                          ),
                        ],
                      ),
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

  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      width: double.infinity,
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
            'Alerts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Positioned(
            right: 8,
            child: IconButton(
              tooltip: 'Alert settings',
              onPressed: _openNotificationSettings,
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8EA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [for (final filter in _filters) _buildFilterTab(filter)],
      ),
    );
  }

  Widget _buildFilterTab(String filter) {
    final selected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            filter,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.secondaryNavy,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryNavy),
      ),
    );
  }

  Widget _buildError({required VoidCallback onRetry}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Could not load forecast insights',
            style: TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again. Forecast insights need '
            'weather data to update.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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

  Widget _buildForecastInsights(DemandForecast forecast) {
    final allAlerts = _alertsFromForecast(forecast);
    final visibleAlerts = allAlerts.where((alert) {
      switch (_selectedFilter) {
        case 'High':
          return alert.type == 'high_demand';
        case 'Tips':
          return alert.type == 'tip';
        case 'Savings':
          // Household consumption is not measured, so the app cannot calculate
          // a verified personal savings alert yet.
          return false;
        default:
          return true;
      }
    }).toList();

    if (visibleAlerts.isEmpty) {
      return Column(
        children: [
          _buildDataNote(forecast),
          const SizedBox(height: 12),
          _buildNotificationActions(forecast),
          _buildEmptyState(
            _selectedFilter == 'Savings'
                ? 'Savings alerts need household usage data before the app can '
                      'estimate personal savings.'
                : 'There are no ${_selectedFilter.toLowerCase()} insights in this '
                      'forecast.',
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildDataNote(forecast),
        const SizedBox(height: 12),
        _buildNotificationActions(forecast),
        const SizedBox(height: 10),
        for (final alert in visibleAlerts) _buildAlertCard(alert),
        const SizedBox(height: 8),
        Text(
          'Forecast period: ${forecast.dateLabel}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDataNote(DemandForecast forecast) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        forecast.dataFreshnessNote,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildNotificationActions(DemandForecast forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _sendTestNotification,
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('Send test notification'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _schedulePeakAlert(forecast),
          icon: const Icon(Icons.schedule),
          label: const Text('Schedule peak alert'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'The alert is scheduled from this forecast snapshot. It will not '
          'refresh automatically if the forecast changes while the app is closed.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      final sent = await LocalNotificationService.instance
          .sendTestNotification();
      if (!mounted) return;
      _showMessage(
        sent
            ? 'Test notification sent. Check your notification shade.'
            : 'Notification permission was denied. Enable it in Android settings.',
      );
    } catch (error) {
      if (mounted) _showMessage('Could not send notification: $error');
    }
  }

  Future<void> _schedulePeakAlert(DemandForecast forecast) async {
    try {
      final (result, _) = await LocalNotificationService.instance
          .schedulePeakDemandAlert(forecast);
      if (!mounted) return;
      final message = switch (result) {
        PeakAlertScheduleResult.scheduled =>
          'Peak alert scheduled for about one hour before the forecast period.',
        PeakAlertScheduleResult.disabled =>
          'Turn on Peak Demand Alerts in notification settings first.',
        PeakAlertScheduleResult.permissionDenied =>
          'Notification permission was denied. Enable it in Android settings.',
        PeakAlertScheduleResult.noHighPeak =>
          'This forecast does not contain a high-demand period to alert on.',
        PeakAlertScheduleResult.tooSoon =>
          'The alert time has passed. Try again with an upcoming forecast.',
      };
      _showMessage(message);
    } catch (error) {
      if (mounted) _showMessage('Could not schedule alert: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<AlertItem> _alertsFromForecast(DemandForecast forecast) {
    final isHighDemand = forecast.peakLevel == DemandLevel.high;
    final isModerateDemand = forecast.peakLevel == DemandLevel.moderate;
    final demandTitle = isHighDemand
        ? 'High demand period forecast'
        : isModerateDemand
        ? 'Moderate demand outlook'
        : 'Lower demand outlook';
    final demandBody = isHighDemand
        ? 'Try to shift flexible, high-load appliances away from this period '
              'if it fits your routine.'
        : isModerateDemand
        ? 'This is the highest-scoring period in the forecast. Consider '
              'shifting flexible use if convenient.'
        : 'No elevated demand period is indicated by this forecast.';

    final alerts = <AlertItem>[
      AlertItem(
        title: demandTitle,
        timeRange: forecast.peakTimeRange,
        body: '$demandBody Forecast score: ${forecast.peakScore}/100.',
        type: isHighDemand ? 'high_demand' : 'outlook',
      ),
    ];

    final recommendedWindow = forecast.recommendedTimeRange;
    final recommendedScore = forecast.recommendedDemandScore;
    if (recommendedWindow != null && recommendedScore != null) {
      var body =
          'The forecast’s lowest-demand consecutive 3-hour window. '
          'Consider using flexible appliances then if it suits your schedule. '
          'Modeled demand score: $recommendedScore/100.';
      final rate = forecast.recommendedAverageRate;
      if (rate != null) {
        body += ' Estimated plan rate: ${rate.toStringAsFixed(2)}¢/kWh.';
      }
      alerts.add(
        AlertItem(
          title: 'Appliance timing suggestion',
          timeRange: recommendedWindow,
          body: body,
          type: 'tip',
        ),
      );
    }
    return alerts;
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none,
            size: 42,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nothing to show here',
            style: TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertItem alert) {
    final isHigh = alert.type == 'high_demand';
    final isTip = alert.type == 'tip';
    final color = isHigh
        ? AppColors.highDemand
        : isTip
        ? AppColors.lowDemand
        : AppColors.moderateDemand;
    final background = isHigh
        ? const Color(0xFFFDF2F2)
        : isTip
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFFFBEB);
    final icon = isHigh
        ? Icons.warning_amber_rounded
        : isTip
        ? Icons.lightbulb_outline_rounded
        : Icons.bolt_outlined;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.timeRange,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  alert.body,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NotificationsScreen(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }
}
