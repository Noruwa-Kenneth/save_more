import 'package:flutter/material.dart';
import '/theme.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const NotificationsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  // ==============================================================
  // NOTIFICATION SETTINGS
  // ==============================================================

  bool _peakDemandAlerts = true;
  bool _energyTips = true;
  bool _savingsAlerts = true;

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,

      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================

            Container(
              height: 65,
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
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  35,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ======================================================
                    // INTRODUCTION
                    // ======================================================

                    const Text(
                      'Stay informed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Choose the alerts and recommendations '
                      'you want to receive from PeakSaver NS.',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.55),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ======================================================
                    // ALERTS
                    // ======================================================

                    _sectionTitle('ALERTS'),

                    const SizedBox(height: 10),

                    // Peak Demand
                    _buildNotificationCard(
                      icon: Icons.bolt_outlined,
                      iconColor: AppColors.moderateDemand,
                      title: 'Peak Demand Alerts',
                      subtitle:
                          'Get notified when electricity demand is expected to be high.',
                      value: _peakDemandAlerts,
                      onChanged: (value) {
                        setState(() {
                          _peakDemandAlerts = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Energy Tips
                    _buildNotificationCard(
                      icon: Icons.lightbulb_outline,
                      iconColor: const Color(0xFFFFC107),
                      title: 'Energy Tips',
                      subtitle:
                          'Receive personalized recommendations to reduce energy use.',
                      value: _energyTips,
                      onChanged: (value) {
                        setState(() {
                          _energyTips = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Savings
                    _buildNotificationCard(
                      icon: Icons.savings_outlined,
                      iconColor: AppColors.lowDemand,
                      title: 'Savings Alerts',
                      subtitle:
                          'Get notified when you have an opportunity to save money.',
                      value: _savingsAlerts,
                      onChanged: (value) {
                        setState(() {
                          _savingsAlerts = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // PREFERENCES
                    // ======================================================

                    _sectionTitle('PREFERENCES'),

                    const SizedBox(height: 10),

                    _buildPreferenceCard(
                      icon: Icons.tune_outlined,
                      title: 'Notification Preferences',
                      subtitle:
                          'Manage timing, frequency and alert settings.',
                      onTap: () {
                        _showPreferenceSheet();
                      },
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // INFO CARD
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: AppColors.secondaryNavy
                            .withValues(alpha: 0.70),

                        borderRadius:
                            BorderRadius.circular(16),

                        border: Border.all(
                          color: Colors.white
                              .withValues(alpha: 0.06),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white54,
                            size: 20,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'PeakSaver NS notifications help you '
                              'shift electricity usage away from '
                              'high-demand periods and discover '
                              'potential savings.',
                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.50),
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    // APP NAME
                    // ======================================================

                    Center(
                      child: Text(
                        'PeakSaver NS',
                        style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: 0.30),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),

      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.42),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ==============================================================
  // NOTIFICATION CARD
  // ==============================================================

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.secondaryNavy
            .withValues(alpha: 0.75),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),

      child: Row(
        children: [
          // ==========================================================
          // ICON
          // ==========================================================

          Container(
            width: 43,
            height: 43,

            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // ==========================================================
          // TEXT
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.48),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ==========================================================
          // SWITCH
          // ==========================================================

          Switch.adaptive(
            value: value,
            onChanged: onChanged,

            activeTrackColor:
                AppColors.lowDemand,

            inactiveTrackColor:
                Colors.white.withValues(alpha: 0.15),

            inactiveThumbColor:
                Colors.white54,
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PREFERENCE CARD
  // ==============================================================

  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: onTap,

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: AppColors.secondaryNavy
                .withValues(alpha: 0.75),

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: Colors.white
                  .withValues(alpha: 0.06),
            ),
          ),

          child: Row(
            children: [
              // Icon
              Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.07),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.48),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.white
                    .withValues(alpha: 0.35),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // NOTIFICATION PREFERENCES
  // ==============================================================

void _showPreferenceSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.primaryNavy,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================================
                // HANDLE
                // ==========================================================

                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================================
                // TITLE
                // ==========================================================

                const Text(
                  'Notification Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'More notification controls will be available here.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================================
                // ALERT TIMING
                // ==========================================================

                _buildBottomSheetItem(
                  icon: Icons.access_time_outlined,
                  title: 'Alert Timing',
                  subtitle:
                      'Choose when alerts can be delivered.',
                ),

                // ==========================================================
                // ALERT FREQUENCY
                // ==========================================================

                _buildBottomSheetItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Alert Frequency',
                  subtitle:
                      'Control how often you receive alerts.',
                ),

                // ==========================================================
                // NOTIFICATION SOUND
                // ==========================================================

                _buildBottomSheetItem(
                  icon: Icons.volume_up_outlined,
                  title: 'Notification Sound',
                  subtitle:
                      'Manage notification sound preferences.',
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  // ==============================================================
  // BOTTOM SHEET ITEM
  // ==============================================================

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 21,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}