import 'package:flutter/material.dart';
import 'package:save_more/theme.dart';

class DemandMeter extends StatelessWidget {
  final double percentage;
  final String statusText;
  final String labelText;
  final VoidCallback? onTap;

  const DemandMeter({
    super.key,
    required this.percentage,
    required this.statusText,
    required this.labelText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double value = (percentage * 100).clamp(0.0, 100.0);

    final Color demandColor = value <= 40
        ? AppColors.lowDemand
        : value <= 75
        ? AppColors.moderateDemand
        : AppColors.highDemand;

    return Column(
      children: [
        /// Gauge + Overlay
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [

              // GAUGE IMAGE
              Positioned(
                top: -45,
                left: 0, 
                right: 0,
                child: Image.asset(
                  'assets/images/gauge.png',
                  width: 300,
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),

              /// Overlay Content
              Positioned(
                left: 10,
                right: 0,
                bottom: 10,             
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 42, color: demandColor),

                    const SizedBox(height: 4),

                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: demandColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      labelText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${value.toInt()}%",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),

                    InkWell(
                      onTap: onTap,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Tap to see peak forecast ➜',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
