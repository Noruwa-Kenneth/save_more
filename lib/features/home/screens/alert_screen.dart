import 'package:flutter/material.dart';
import '/theme.dart';

class AlertItem {
  final String dateGroup;
  final String title;
  final String time;
  final String body;
  final String type;

  const AlertItem({
    required this.dateGroup,
    required this.title,
    required this.time,
    required this.body,
    required this.type,
  });
}

class AlertScreen extends StatefulWidget {
   final VoidCallback onBack;

  const AlertScreen({
    super.key,
     required this.onBack,
    });

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  String _selectedFilter = 'All';

  final List<AlertItem> _alerts = const [
    AlertItem(
      dateGroup: 'Today',
      title: 'High Demand Alert',
      time: '2:30 PM',
      body: 'High electricity demand expected from 4:00 PM to 8:00 PM today.',
      type: 'high_demand',
    ),
    AlertItem(
      dateGroup: 'Yesterday',
      title: 'Energy Tip',
      time: '9:15 AM',
      body: 'Run your dishwasher after 9:00 PM to save on energy costs.',
      type: 'tip',
    ),
    AlertItem(
      dateGroup: '2 Days Ago',
      title: 'Savings Opportunity',
      time: '10:45 AM',
      body:
          'You could save up to \$1.45 today by shifting usage to off-peak hours.',
      type: 'savings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // FILTER ALERTS
    // ============================================================

    final filteredAlerts = _alerts.where((alert) {
      if (_selectedFilter == 'All') {
        return true;
      }

      if (_selectedFilter == 'High' && alert.type == 'high_demand') {
        return true;
      }

      if (_selectedFilter == 'Tips' && alert.type == 'tip') {
        return true;
      }

      if (_selectedFilter == 'Savings' && alert.type == 'savings') {
        return true;
      }

      return false;
    }).toList();

    return Container(
      color: AppColors.primaryNavy,

      child: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // NAVY HEADER
            // ============================================================
            Container(
              height: 50,
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

                  // Alert title
                  const Text(
                    'Alerts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Settings
                  Positioned(
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        // Alert settings will go here
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // WHITE CONTENT SECTION
            // ============================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    width: double.infinity,

                    color: Colors.white,

                    // ========================================================
                    // SINGLE SCROLL VIEW
                    // ========================================================
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),

                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // ==================================================
// FILTER SELECTOR
// ==================================================

Padding(
  padding: const EdgeInsets.fromLTRB(
    20,
    0,
    20,
    0,
  ),

  child: Container(
    width: double.infinity,
    height: 46,

    padding: const EdgeInsets.all(4),

    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(14),
    ),

    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),

      child: Row(
        children: [
          _buildFilterTab('All'),

          const SizedBox(width: 5),

          _buildFilterTab('High'),

          const SizedBox(width: 5),

          _buildFilterTab('Tips'),

          const SizedBox(width: 5),

          _buildFilterTab('Savings'),
        ],
      ),
    ),
  ),
),
                          const SizedBox(height: 20),

                          // ==================================================
                          // ALERTS
                          // ==================================================
                          if (filteredAlerts.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30),
                                child: Text(
                                  'No alerts in this category',
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ),
                            )
                          else
                            ..._getDateGroups(filteredAlerts).map((dateGroup) {
                              final groupAlerts = filteredAlerts
                                  .where(
                                    (alert) => alert.dateGroup == dateGroup,
                                  )
                                  .toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ========================================
                                  // DATE GROUP
                                  // ========================================
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 12,
                                    ),
                                    child: Text(
                                      dateGroup,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),

                                  // ========================================
                                  // ALERT CARDS
                                  // ========================================
                                  ...groupAlerts.map(_buildAlertCard),

                                  const SizedBox(height: 12),
                                ],
                              );
                            }),
                        ],
                      ),
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
// FILTER TAB
// ==============================================================

Widget _buildFilterTab(String filterName) {
  final bool isSelected =
      _selectedFilter == filterName;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedFilter = filterName;
      });
    },

    child: AnimatedContainer(
      duration: const Duration(
        milliseconds: 180,
      ),

      height: 38,

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      alignment: Alignment.center,

      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryNavy
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Text(
        filterName,

        textAlign: TextAlign.center,

        style: TextStyle(
          fontFamily: 'Poppins',

          fontSize: 12,

          fontWeight: isSelected
              ? FontWeight.w600
              : FontWeight.w500,

          color: isSelected
              ? Colors.white
              : AppColors.secondaryNavy,
        ),
      ),
    ),
  );
}

  // ==============================================================
  // GET DATE GROUPS
  // ==============================================================

  List<String> _getDateGroups(List<AlertItem> items) {
    final groups = <String>[];

    for (final item in items) {
      if (!groups.contains(item.dateGroup)) {
        groups.add(item.dateGroup);
      }
    }

    return groups;
  }

  // ==============================================================
  // ALERT CARD
  // ==============================================================

  Widget _buildAlertCard(AlertItem alert) {
    Color cardBg;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    switch (alert.type) {
      case 'high_demand':
        cardBg = const Color(0xFFFDF2F2);
        borderColor = const Color(0xFFFDE8E8);
        iconColor = AppColors.highDemand;
        iconData = Icons.warning_amber_rounded;
        break;

      case 'tip':
        cardBg = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        iconColor = AppColors.moderateDemand;
        iconData = Icons.lightbulb_outline_rounded;
        break;

      case 'savings':
        cardBg = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        iconColor = AppColors.lowDemand;
        iconData = Icons.savings_outlined;
        break;

      default:
        cardBg = Colors.white;
        borderColor = Colors.grey.shade100;
        iconColor = AppColors.primaryNavy;
        iconData = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: cardBg,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: borderColor, width: 1.5),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==========================================================
            // ICON
            // ==========================================================
            Container(
              padding: const EdgeInsets.all(8),

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: Icon(iconData, color: iconColor, size: 24),
            ),

            const SizedBox(width: 14),

            // ==========================================================
            // TEXT CONTENT
            // ==========================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ================================================
                  // TITLE + TIME
                  // ================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        alert.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ================================================
                  // BODY
                  // ================================================
                  Text(
                    alert.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
