import 'package:flutter/material.dart';
import '/theme.dart';
import '../widgets/demand_chart.dart';
import 'dart:math' as math;

class PeakForecastPage extends StatefulWidget {
  final VoidCallback onBack;

  const PeakForecastPage({super.key, required this.onBack});

  @override
  State<PeakForecastPage> createState() => _PeakForecastPageState();
}

class _PeakForecastPageState extends State<PeakForecastPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,

      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // NAVY HEADER
            // ============================================================
            Container(
              height: 60,
              width: double.infinity,
              color: AppColors.primaryNavy,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button
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

                  // Title
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

            // ============================================================
            // CONTENT
            // ============================================================
            Expanded(
              child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
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
                      // ====================================================
                      // DAY SELECTOR
                      // ====================================================
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
                            _buildTab(title: 'Today', index: 0),
                            _buildTab(title: 'Tomorrow', index: 1),
                            _buildTab(title: '7 Days', index: 2),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ====================================================
                      // DATE
                      // ====================================================
                      Text(
                        _getDateText(),
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ====================================================
                      // DEMAND CHART WIDGET
                      // ====================================================
                      const SizedBox(
                        width: double.infinity,
                        height: 190,
                        child: DemandForecastChart(),
                      ),

                      const SizedBox(height: 18),

                      // ====================================================
                      // LEGEND
                      // ====================================================
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(
                            color: AppColors.lowDemand,
                            text: 'Low (0–40%)',
                          ),

                          const SizedBox(height: 10),

                          _buildLegendItem(
                            color: AppColors.moderateDemand,
                            text: 'Moderate (40–70%)',
                          ),

                          const SizedBox(height: 10),

                          _buildLegendItem(
                            color: AppColors.highDemand,
                            text: 'High (70–100%)',
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ====================================================
                      // PEAK PERIOD CARD
                      // ====================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE7E7E7),
                            width: 1,
                          ),
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
                            // LEFT CONTENT
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

                                  const Text(
                                    '4:00 PM – 8:00 PM',
                                    style: TextStyle(
                                      color: AppColors.highDemand,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  const Text(
                                    'Avoid heavy appliance use\n'
                                    'during this time.',
                                    style: TextStyle(
                                      color: Color(0xFF222222),
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // CLOCK
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

  // ==============================================================
  // TAB
  // ==============================================================

  Widget _buildTab({required String title, required int index}) {
    final bool selected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
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

  // ==============================================================
  // LEGEND
  // ==============================================================

  Widget _buildLegendItem({required Color color, required String text}) {
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

  // ==============================================================
  // DATE
  // ==============================================================

  String _getDateText() {
    switch (_selectedTab) {
      case 0:
        return 'June 6, 2025';

      case 1:
        return 'June 7, 2025';

      case 2:
        return 'June 6 – 13, 2025';

      default:
        return 'June 6, 2025';
    }
  }
}

// ============================================================================
// CLOCK ICON
// ============================================================================

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;

    final Offset center = Offset(size.width / 2, size.height / 2);

    final double radius = math.min(size.width, size.height) / 2 - 2;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Hour hand
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius * 0.48),
      paint,
    );

    // Minute hand
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.48, center.dy + radius * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
