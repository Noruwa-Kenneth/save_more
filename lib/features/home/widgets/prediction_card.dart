import 'package:flutter/material.dart';
import 'package:save_more/theme.dart';

class PredictionCard extends StatelessWidget {
  final String day;
  final String timeRange;
  final String demandLevel;
  final VoidCallback? onTap;

  const PredictionCard({
    super.key,
    required this.day,
    required this.timeRange,
    required this.demandLevel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                        '$demandLevel expected\nfrom $timeRange.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 3, 3, 3),
                          height: 1.4,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'View full peak forecast ➜',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryNavy,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/images/clouds-and-sun.png',
                  width: 65,
                  height: 65,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
