import 'package:flutter/material.dart';
import '/theme.dart';

class EnergyTipItem {
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color themeColor;

  const EnergyTipItem({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.themeColor,
  });
}

class EnergyTipsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const EnergyTipsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<EnergyTipsScreen> createState() => _EnergyTipsScreenState();
}

class _EnergyTipsScreenState extends State<EnergyTipsScreen> {
  String _selectedCategory = 'All';

  // ==============================================================
  // ENERGY TIPS
  // ==============================================================

  final List<EnergyTipItem> _tips = const [
    EnergyTipItem(
      title: 'Heat Smart',
      description:
          'Keep your thermostat at 20°C or lower in winter.',
      category: 'Heating',
      icon: Icons.thermostat_outlined,
      themeColor: Color(0xFFE74C3C),
    ),

    EnergyTipItem(
      title: 'Use Off-Peak Hours',
      description:
          'Run appliances like laundry or dishwasher after 9:00 PM.',
      category: 'Appliances',
      icon: Icons.access_time_outlined,
      themeColor: Color(0xFF2ECC71),
    ),

    EnergyTipItem(
      title: 'Seal & Insulate',
      description:
          'Proper insulation helps reduce heating costs by keeping warmth in.',
      category: 'Heating',
      icon: Icons.home_work_outlined,
      themeColor: Color(0xFF3498DB),
    ),

    EnergyTipItem(
      title: 'Unplug Devices',
      description:
          'Unplug electronics when not in use to save phantom energy load.',
      category: 'General',
      icon: Icons.power_outlined,
      themeColor: Color(0xFF9B59B6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // FILTER TIPS
    // ============================================================

    final filteredTips = _tips.where((tip) {
      if (_selectedCategory == 'All') {
        return true;
      }

      return tip.category == _selectedCategory;
    }).toList();

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
                  // ======================================================
                  // BACK BUTTON
                  // ======================================================

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

                  // ======================================================
                  // TITLE
                  // ======================================================

                  const Text(
                    'Energy Tips',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // ======================================================
                  // SETTINGS
                  // ======================================================

                  Positioned(
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        // Energy tip settings
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),

                // IMPORTANT:
                // Keeps all scrolling content clipped to the
                // curved white section.
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),

                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF7F7F7),

                    child: Column(
                      children: [
                        // ==================================================
                        // CATEGORY SELECTOR
                        // ==================================================

                        // ==================================================
// CATEGORY SELECTOR
// ==================================================

Padding(
  padding: const EdgeInsets.fromLTRB(
    20,
    20,
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
          _buildCategoryTab('All'),

          const SizedBox(width: 8),

          _buildCategoryTab('Heating'),

          const SizedBox(width: 8),

          _buildCategoryTab('Appliances'),

          const SizedBox(width: 8),

          _buildCategoryTab('General'),
        ],
      ),
    ),
  ),
),

                        const SizedBox(height: 20),

                        // ==================================================
                        // TIPS LIST
                        // ==================================================

                        Expanded(
                          child: filteredTips.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No tips under this category',
                                    style: TextStyle(
                                      color:
                                          AppColors.textMuted,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics:
                                      const BouncingScrollPhysics(),

                                  padding:
                                      const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    30,
                                  ),

                                  itemCount:
                                      filteredTips.length,

                                  itemBuilder:
                                      (context, index) {
                                    final tip =
                                        filteredTips[index];

                                    return _buildTipCard(
                                      tip,
                                    );
                                  },
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
  // CATEGORY TAB
  // ==============================================================

// ==============================================================
// CATEGORY TAB
// ==============================================================

Widget _buildCategoryTab(String category) {
  final bool isSelected =
      _selectedCategory == category;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCategory = category;
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
        category,

        textAlign: TextAlign.center,

        style: TextStyle(
          fontFamily: 'Poppins',

          fontSize: 11.5,

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
  // TIP CARD
  // ==============================================================

  Widget _buildTipCard(EnergyTipItem tip) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            // ==========================================================
            // COLORED ICON
            // ==========================================================

            Container(
              padding:
                  const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: tip.themeColor.withValues(
                  alpha: 0.08,
                ),

                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Icon(
                tip.icon,

                color: tip.themeColor,

                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // ==========================================================
            // TEXT CONTENT
            // ==========================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    tip.title,

                    style: const TextStyle(
                      fontSize: 15,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          AppColors.primaryNavy,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    tip.description,

                    style: TextStyle(
                      fontSize: 13,

                      color:
                          Colors.grey.shade600,

                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // ==========================================================
            // ARROW
            // ==========================================================

            Icon(
              Icons.arrow_forward_ios,

              color:
                  Colors.grey.shade300,

              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}