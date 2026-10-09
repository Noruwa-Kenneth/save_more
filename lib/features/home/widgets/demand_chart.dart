import 'package:flutter/material.dart';

import 'package:save_more/core/models/demand_forecast.dart';
import '/theme.dart';

class DemandForecastChart extends StatelessWidget {
  final List<DemandForecastPoint> points;
  final DateTime? peakMarkerTime;
  final ForecastRange range;

  const DemandForecastChart({
    super.key,
    required this.points,
    required this.range,
    this.peakMarkerTime,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DemandChartPainter(
        points: points,
        range: range,
        peakMarkerTime: peakMarkerTime,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class DemandChartPainter extends CustomPainter {
  final List<DemandForecastPoint> points;
  final ForecastRange range;
  final DateTime? peakMarkerTime;

  DemandChartPainter({
    required this.points,
    required this.range,
    this.peakMarkerTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 38;
    const double right = 8;
    const double top = 6;
    const double bottom = 30;

    final double chartWidth = size.width - left - right;
    final double chartHeight = size.height - top - bottom;

    final Rect chartRect = Rect.fromLTWH(left, top, chartWidth, chartHeight);

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE6E6E6)
      ..strokeWidth = 1;

    for (final level in [1.0, 0.75, 0.50, 0.25, 0.0]) {
      final double y = top + chartHeight * (1 - level);
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= 4; i++) {
      final double x = left + chartWidth * (i / 4);
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + chartHeight),
        gridPaint,
      );
    }

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const yLabels = ['100%', '75%', '50%', '25%', '0%'];
    for (int i = 0; i < yLabels.length; i++) {
      final double y = top + chartHeight * (i / 4);
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(color: Color(0xFF555555), fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(left - textPainter.width - 7, y - textPainter.height / 2),
      );
    }

    if (points.isEmpty) return;

    final chartPoints = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final t = points.length == 1 ? 0.0 : i / (points.length - 1);
      final x = left + chartWidth * t;
      final y = top + chartHeight * (1 - points[i].normalizedScore);
      chartPoints.add(Offset(x, y));
    }

    final Path curvePath = Path();
    curvePath.moveTo(chartPoints.first.dx, chartPoints.first.dy);
    for (int i = 0; i < chartPoints.length - 1; i++) {
      final current = chartPoints[i];
      final next = chartPoints[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      curvePath.cubicTo(
        controlX,
        current.dy,
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    final Path fillPath = Path.from(curvePath)
      ..lineTo(chartPoints.last.dx, top + chartHeight)
      ..lineTo(chartPoints.first.dx, top + chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0x552ECC71),
          Color(0x5534C759),
          Color(0x55FFB300),
          Color(0x55FF9800),
          Color(0x55E74C3C),
        ],
        stops: [0.0, 0.30, 0.48, 0.68, 1.0],
      ).createShader(chartRect);
    canvas.drawPath(fillPath, fillPaint);

    final curvePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF2EAD45),
          Color(0xFF2EAD45),
          Color(0xFFFFB300),
          Color(0xFFFF9800),
          Color(0xFFE74C3C),
        ],
        stops: [0.0, 0.30, 0.48, 0.68, 1.0],
      ).createShader(chartRect);
    canvas.drawPath(curvePath, curvePaint);

    for (int i = 0; i < chartPoints.length; i++) {
      if (points[i].score < 40) continue;
      final color = points[i].score >= 70
          ? AppColors.highDemand
          : AppColors.moderateDemand;
      canvas.drawCircle(chartPoints[i], 3.5, Paint()..color = color);
    }

    // Peak marker
    if (peakMarkerTime != null && points.length > 1) {
      final markerIndex = _closestIndex(points, peakMarkerTime!);
      final markerX = chartPoints[markerIndex].dx;
      final markerPaint = Paint()
        ..color = const Color(0xFF202020)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(markerX, top),
        Offset(markerX, top + chartHeight),
        markerPaint,
      );
      canvas.drawCircle(
        Offset(markerX, top + chartHeight),
        3,
        Paint()..color = const Color(0xFF202020),
      );
    }

    final xLabels = _xLabels();
    for (int i = 0; i < xLabels.length; i++) {
      final double x = left + chartWidth * (i / (xLabels.length - 1));
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(color: Color(0xFF555555), fontSize: 9),
      );
      textPainter.layout();
      double textX = x - textPainter.width / 2;
      if (i == 0) textX = x;
      if (i == xLabels.length - 1) textX = x - textPainter.width;
      textPainter.paint(canvas, Offset(textX, top + chartHeight + 9));
    }
  }

  List<String> _xLabels() {
    if (range == ForecastRange.next7Days) {
      if (points.isEmpty) return ['', '', '', '', ''];
      final labels = <String>[];
      final step = (points.length / 4).clamp(1, points.length).floor();
      for (int i = 0; i < points.length; i += step) {
        final d = points[i].time;
        labels.add('${d.month}/${d.day}');
        if (labels.length >= 5) break;
      }
      while (labels.length < 5) {
        labels.add('');
      }
      return labels.take(5).toList();
    }

    return const ['12 AM', '6 AM', '12 PM', '6 PM', '12 AM'];
  }

  int _closestIndex(List<DemandForecastPoint> pts, DateTime target) {
    var best = 0;
    var bestDiff = (pts.first.time.difference(target)).inMinutes.abs();
    for (var i = 1; i < pts.length; i++) {
      final diff = (pts[i].time.difference(target)).inMinutes.abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = i;
      }
    }
    return best;
  }

  @override
  bool shouldRepaint(covariant DemandChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.range != range ||
        oldDelegate.peakMarkerTime != peakMarkerTime;
  }
}
