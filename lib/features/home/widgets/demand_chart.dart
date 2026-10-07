
import 'package:flutter/material.dart';
import '/theme.dart';

class DemandForecastChart extends StatelessWidget {
  const DemandForecastChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DemandChartPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class DemandChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double left = 38;
    const double right = 8;
    const double top = 6;
    const double bottom = 30;

    final double chartWidth = size.width - left - right;
    final double chartHeight = size.height - top - bottom;

    final Rect chartRect = Rect.fromLTWH(
      left,
      top,
      chartWidth,
      chartHeight,
    );

    // ================================================================
    // GRID
    // ================================================================

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE6E6E6)
      ..strokeWidth = 1;

    const List<double> levels = [
      1.0,
      0.75,
      0.50,
      0.25,
      0.0,
    ];

    for (final level in levels) {
      final double y = top + chartHeight * (1 - level);

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    // Vertical guide lines
    for (int i = 0; i <= 4; i++) {
      final double x = left + chartWidth * (i / 4);

      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + chartHeight),
        gridPaint,
      );
    }

    // ================================================================
    // Y AXIS LABELS
    // ================================================================

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const List<String> yLabels = [
      '100%',
      '75%',
      '50%',
      '25%',
      '0%',
    ];

    for (int i = 0; i < yLabels.length; i++) {
      final double y = top + chartHeight * (i / 4);

      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 9,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          left - textPainter.width - 7,
          y - textPainter.height / 2,
        ),
      );
    }

    // ================================================================
    // DATA POINTS
    // ================================================================

    final List<Offset> points = [
      Offset(
        left,
        top + chartHeight * 0.83,
      ),
      Offset(
        left + chartWidth * 0.10,
        top + chartHeight * 0.67,
      ),
      Offset(
        left + chartWidth * 0.22,
        top + chartHeight * 0.78,
      ),
      Offset(
        left + chartWidth * 0.34,
        top + chartHeight * 0.65,
      ),
      Offset(
        left + chartWidth * 0.47,
        top + chartHeight * 0.48,
      ),
      Offset(
        left + chartWidth * 0.59,
        top + chartHeight * 0.36,
      ),
      Offset(
        left + chartWidth * 0.72,
        top + chartHeight * 0.16,
      ),
      Offset(
        left + chartWidth * 0.82,
        top + chartHeight * 0.08,
      ),
      Offset(
        left + chartWidth * 0.91,
        top + chartHeight * 0.18,
      ),
      Offset(
        left + chartWidth,
        top + chartHeight * 0.40,
      ),
    ];

    // ================================================================
    // SMOOTH CURVE
    // ================================================================

    final Path curvePath = Path();

    curvePath.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];

      final double controlX =
          (current.dx + next.dx) / 2;

      curvePath.cubicTo(
        controlX,
        current.dy,
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    // ================================================================
    // COLORED AREA
    // ================================================================

    final Path fillPath = Path.from(curvePath);

    fillPath.lineTo(
      points.last.dx,
      top + chartHeight,
    );

    fillPath.lineTo(
      points.first.dx,
      top + chartHeight,
    );

    fillPath.close();

    final Paint fillPaint = Paint()
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
        stops: [
          0.0,
          0.30,
          0.48,
          0.68,
          1.0,
        ],
      ).createShader(chartRect);

    canvas.drawPath(
      fillPath,
      fillPaint,
    );

    // ================================================================
    // CURVE
    // ================================================================

    final Paint curvePaint = Paint()
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
        stops: [
          0.0,
          0.30,
          0.48,
          0.68,
          1.0,
        ],
      ).createShader(chartRect);

    canvas.drawPath(
      curvePath,
      curvePaint,
    );

    // ================================================================
    // DATA DOTS
    // ================================================================

    final List<int> highlightedIndexes = [
      3,
      4,
      6,
      7,
      8,
    ];

    for (final index in highlightedIndexes) {
      final Offset point = points[index];

      final Color dotColor =
          index <= 3
              ? AppColors.moderateDemand
              : AppColors.highDemand;

      final Paint dotPaint = Paint()
        ..color = dotColor;

      canvas.drawCircle(
        point,
        4,
        dotPaint,
      );
    }

    // ================================================================
    // 6 PM MARKER
    // ================================================================

    final double markerX =
        left + chartWidth * 0.78;

    final Paint markerPaint = Paint()
      ..color = const Color(0xFF202020)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(markerX, top),
      Offset(
        markerX,
        top + chartHeight,
      ),
      markerPaint,
    );

    canvas.drawCircle(
      Offset(
        markerX,
        top + chartHeight,
      ),
      3,
      Paint()..color = const Color(0xFF202020),
    );

    // ================================================================
    // X AXIS LABELS
    // ================================================================

    const List<String> xLabels = [
      '12 AM',
      '6 AM',
      '12 PM',
      '6 PM',
      '12 AM',
    ];

    for (int i = 0; i < xLabels.length; i++) {
      final double x =
          left + chartWidth * (i / 4);

      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 9,
        ),
      );

      textPainter.layout();

      double textX =
          x - textPainter.width / 2;

      if (i == 0) {
        textX = x;
      }

      if (i == 4) {
        textX = x - textPainter.width;
      }

      textPainter.paint(
        canvas,
        Offset(
          textX,
          top + chartHeight + 9,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

