import 'package:flutter/material.dart';
import 'package:save_more/theme.dart';

class GridStatusCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final String subtitle;
  final Color demandColor;

  const GridStatusCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.subtitle,
    required this.demandColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 251, 255, 252).withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18.0),

        child: Row(
          children: [
            // LEFT: Appliance Usage Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    timeRange,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lowDemand,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 12, 11, 11)),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
