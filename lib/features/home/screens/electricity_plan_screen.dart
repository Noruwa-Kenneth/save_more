import 'package:flutter/material.dart';

import 'package:save_more/theme.dart';
import 'package:save_more/core/models/user_rate_plan.dart';
import 'package:save_more/core/services/user_rate_plan_service.dart';

class ElectricityPlanScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ElectricityPlanScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<ElectricityPlanScreen> createState() =>
      _ElectricityPlanScreenState();
}

class _ElectricityPlanScreenState
    extends State<ElectricityPlanScreen> {
  final UserRatePlanService _planService =
      UserRatePlanService.instance;

  UserRatePlan get _selectedPlan =>
      _planService.selectedPlan;

  void _selectPlan(UserRatePlan plan) {
    if (plan == UserRatePlan.timeOfUse ||
        plan == UserRatePlan.criticalPeak) {
      return;
    }

    setState(() {
      _planService.setPlan(plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Electricity Plan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              const Text(
                'Your Electricity Plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select the electricity plan you currently use. '
                'PeakSaver NS will use this information to give '
                'you more accurate recommendations.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              _buildPlanCard(
                plan: UserRatePlan.standardResidential,
                title: 'Standard Residential',
                description:
                    'Standard residential electricity service.',
                status: 'Available',
                enabled: true,
              ),

              const SizedBox(height: 14),

              _buildPlanCard(
                plan: UserRatePlan.timeOfDay,
                title: 'Time-of-Day',
                description:
                    'Seasonal electricity pricing with '
                    'peak, mid-peak and off-peak periods.',
                status: 'Available',
                enabled: true,
              ),

              const SizedBox(height: 14),

              _buildPlanCard(
                plan: UserRatePlan.timeOfUse,
                title: 'Time-of-Use',
                description:
                    'Peak and off-peak pricing designed to '
                    'encourage shifting electricity usage.',
                status: 'Currently unavailable',
                enabled: false,
              ),

              const SizedBox(height: 14),

              _buildPlanCard(
                plan: UserRatePlan.criticalPeak,
                title: 'Critical Peak',
                description:
                    'Special pricing during critical grid '
                    'demand events.',
                status: 'Coming later',
                enabled: false,
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your selected plan helps PeakSaver NS '
                        'determine when electricity may be cheaper '
                        'and when demand is likely to be higher.',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required UserRatePlan plan,
    required String title,
    required String description,
    required String status,
    required bool enabled,
  }) {
    final bool isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: enabled ? () => _selectPlan(plan) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryNavy
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primaryNavy.withValues(
                        alpha: 0.08,
                      )
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                enabled
                    ? Icons.electric_bolt_outlined
                    : Icons.lock_outline,
                color: enabled
                    ? AppColors.primaryNavy
                    : Colors.grey,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: enabled
                          ? AppColors.primaryNavy
                          : Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled
                          ? Colors.black54
                          : Colors.grey,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? AppColors.primaryNavy
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            if (enabled)
              Radio<UserRatePlan>(
                value: plan,
                groupValue: _selectedPlan,
                onChanged: (_) => _selectPlan(plan),
                activeColor: AppColors.primaryNavy,
              )
            else
              const Icon(
                Icons.lock_outline,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}