import 'dart:async';

import 'package:dio/dio.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/grid_demand_reading.dart';

/// Fetches Nova Scotia Power's public transmission-system current report.
class GridDemandService {
  static const reportUrl =
      'https://resourcesprd-nspower.aws.silvertech.net/oasis/current_report.shtml';
  static const pollingInterval = Duration(minutes: 5);
  static const _atlanticZone = 'America/Halifax';

  final Dio _dio;

  GridDemandService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 12),
              responseType: ResponseType.plain,
              headers: const {'Accept': 'text/html'},
            ),
          ) {
    timezone_data.initializeTimeZones();
  }

  Future<GridDemandReading> fetchLatest() async {
    final response = await _dio.get<String>(reportUrl);
    final body = response.data;
    if (body == null || body.isEmpty) {
      throw const FormatException('The grid report was empty.');
    }
    return parseReport(body, fetchedAtUtc: DateTime.now().toUtc());
  }

  /// Polls the public report. A temporary request failure keeps the last
  /// reading on screen and exposes a message instead of discarding it.
  Stream<GridDemandStatus> watchLatest() async* {
    GridDemandReading? lastReading;
    while (true) {
      try {
        lastReading = await fetchLatest();
        yield GridDemandStatus(reading: lastReading);
      } catch (_) {
        yield GridDemandStatus(
          reading: lastReading,
          refreshMessage: lastReading == null
              ? 'The live grid report could not be reached.'
              : 'Could not refresh the grid report. Showing the last reading.',
        );
      }
      await Future<void>.delayed(pollingInterval);
    }
  }

  /// Parses the report's visible text. Exposed so the format can be checked
  /// against representative report content without making a network request.
  static GridDemandReading parseReport(
    String html, {
    required DateTime fetchedAtUtc,
  }) {
    timezone_data.initializeTimeZones();
    final text = html
        .replaceAll(
          RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style\b[^>]*>[\s\S]*?</style>', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&nbsp;|&#160;|&#xA0;', caseSensitive: false), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ');
    final report = RegExp(
      r'Last\s+Updated\s*:\s*(\d{1,2})-([A-Za-z]{3})-(\d{2,4})\s+(\d{1,2}):(\d{2}).{0,180}?Net\s+Load\s*\|?\s*([\d,]+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (report == null) {
      throw const FormatException(
        'The grid report did not contain a recognized current net-load reading.',
      );
    }

    final day = int.parse(report.group(1)!);
    final month = _monthNumber(report.group(2)!);
    final yearValue = int.parse(report.group(3)!);
    final year = yearValue < 100 ? 2000 + yearValue : yearValue;
    final hour = int.parse(report.group(4)!);
    final minute = int.parse(report.group(5)!);
    final netLoadMw = double.parse(report.group(6)!.replaceAll(',', ''));
    if (netLoadMw <= 0 || netLoadMw > 10000) {
      throw const FormatException('The reported net-load value is invalid.');
    }

    final reportedAtUtc = tz.TZDateTime(
      tz.getLocation(_atlanticZone),
      year,
      month,
      day,
      hour,
      minute,
    ).toUtc();
    if (reportedAtUtc.isAfter(fetchedAtUtc.add(const Duration(minutes: 10)))) {
      throw const FormatException(
        'The grid report timestamp is unexpectedly in the future.',
      );
    }

    return GridDemandReading(
      netLoadMw: netLoadMw,
      reportedAtUtc: reportedAtUtc,
      fetchedAtUtc: fetchedAtUtc,
    );
  }

  static int _monthNumber(String abbreviation) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final month = months[abbreviation.toLowerCase()];
    if (month == null) {
      throw const FormatException('The grid report has an invalid month.');
    }
    return month;
  }
}
