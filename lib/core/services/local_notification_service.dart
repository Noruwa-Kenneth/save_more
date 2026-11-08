import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/demand_forecast.dart';
import '../models/peak_prediction.dart';

enum PeakAlertScheduleResult {
  scheduled,
  disabled,
  permissionDenied,
  noHighPeak,
  tooSoon,
}

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();
  static const peakDemandPreferenceKey = 'notification_peak_demand_alerts';
  static const _peakNotificationId = 4101;
  static const _testNotificationId = 4102;
  static const _channelId = 'peak_demand_alerts';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Halifax'));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> _requestAndroidPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    // Android versions before 13 do not need this runtime permission.
    return granted ?? true;
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Peak demand alerts',
      channelDescription: 'Local alerts based on your electricity forecast.',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<bool> sendTestNotification() async {
    await initialize();
    if (!await _requestAndroidPermission()) return false;
    await _plugin.show(
      id: _testNotificationId,
      title: 'Save More notification test',
      body: 'Notifications are working on this device.',
      notificationDetails: _notificationDetails,
    );
    return true;
  }

  Future<(PeakAlertScheduleResult, DateTime?)> schedulePeakDemandAlert(
    DemandForecast forecast,
  ) async {
    await initialize();
    await _plugin.cancel(id: _peakNotificationId);

    final preferences = await SharedPreferences.getInstance();
    if (!(preferences.getBool(peakDemandPreferenceKey) ?? true)) {
      return (PeakAlertScheduleResult.disabled, null);
    }
    if (forecast.peakLevel != DemandLevel.high) {
      return (PeakAlertScheduleResult.noHighPeak, null);
    }
    if (!await _requestAndroidPermission()) {
      return (PeakAlertScheduleResult.permissionDenied, null);
    }

    final peak = forecast.peakStart;
    final alertAt = tz.TZDateTime(
      tz.getLocation('America/Halifax'),
      peak.year,
      peak.month,
      peak.day,
      peak.hour,
      peak.minute,
    ).subtract(const Duration(hours: 1));
    if (!alertAt.isAfter(tz.TZDateTime.now(tz.local))) {
      return (PeakAlertScheduleResult.tooSoon, null);
    }

    await _plugin.zonedSchedule(
      id: _peakNotificationId,
      title: 'High electricity demand expected soon',
      body:
          'A high-demand period is forecast to begin in about one hour. '
          'If convenient, shift flexible appliance use.',
      scheduledDate: alertAt,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return (PeakAlertScheduleResult.scheduled, alertAt);
  }

  Future<void> cancelPeakDemandAlert() async {
    await initialize();
    await _plugin.cancel(id: _peakNotificationId);
  }
}
