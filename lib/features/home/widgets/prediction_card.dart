
import 'package:flutter/material.dart';
import 'package:save_more/theme.dart';

class PredictionCard extends StatelessWidget {
  final String day;
  final String timeRange;
  final String demandLevel;

  const PredictionCard({
    super.key,
    required this.day,
    required this.timeRange,
    required this.demandLevel,
    
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: AppColors.softblue,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // =====================================================
            // LEFT: PREDICTION INFORMATION
            // =====================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "$demandLevel expected\n"
                    "from $timeRange.",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 3, 3, 3),
                      height: 1.4,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(width: 12),

          
            // RIGHT: Cloud Image
        Image.asset(
          'assets/images/clouds-and-sun.png',
          width: 65,
          height: 65,
          fit: BoxFit.contain,
        ),
          ],
        ),
      ),
    );
  }
}

