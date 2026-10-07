import 'package:flutter/material.dart';
import '/theme.dart';

class SavingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SavingsScreen({super.key, required this.onBack});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  String _selectedMonth = 'This Month';
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
                  // Header: title, back button, calendar icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color.fromARGB(255, 243, 245, 248),
                          size: 20,
                        ),
                        onPressed: widget.onBack,
                      ),
                      const Text(
                        'Your Savings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 231, 239, 250),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color.fromARGB(255, 248, 250, 252),
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                    ],
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

                // IMPORTANT:
                // Clip the content so it respects the rounded corners.
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),

                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF7F7F7),

                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),

                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // MONTH SELECTOR
                          // ==================================================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),

                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedMonth,

                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.primaryNavy,
                                ),

                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryNavy,
                                ),

                                items: const [
                                  DropdownMenuItem(
                                    value: 'This Month',
                                    child: Text('This Month'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Last Month',
                                    child: Text('Last Month'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Last 3 Months',
                                    child: Text('Last 3 Months'),
                                  ),
                                ],

                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedMonth = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),

                          // ==================================================
                          // ESTIMATED SAVINGS CARD
                          // ==================================================
                          Container(
                            // 1. Clips the overlay texture image to the card's rounded corners
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.0),
                              color: const Color(0xFF04211A),
                              gradient: const RadialGradient(
                                center: Alignment(-0.6, -0.2),
                                radius: 1.4,
                                colors: [Color(0xFF0A362A), Color(0xFF031A15)],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // ============================================================
                                // 2. SUBTLE PATTERN/DESIGN OVERLAY LAYER
                                // ============================================================
                                Positioned.fill(
                                  child: Opacity(
                                    opacity:
                                        0.90, // Keeps the underlying design pattern ultra-subtle
                                    child: Image.asset(
                                       'assets/images/card_pattern.png', // Replace with your exact local pattern filename
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // ============================================================
                                // 3. CARD CONTENT LAYER
                                // ============================================================
                                Padding(
                                  padding: const EdgeInsets.all(22.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Left Text Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Estimated Savings',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              '\$18.60',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "You're doing great! Keep\nshifting usage to off-peak.",
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Right Chart & Icon Column
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Orange Coin Icon
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(
                                                0xFFFFA726,
                                              ), // Smooth golden orange
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Text(
                                              'S',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          // Mini Bar Graph
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              _buildChartBar(
                                                20,
                                                const Color(0xFF2E7D32),
                                              ), // Darker green
                                              const SizedBox(width: 6),
                                              _buildChartBar(
                                                40,
                                                const Color(0xFF4CAF50),
                                              ), // Mid green
                                              const SizedBox(width: 6),
                                              _buildChartBar(
                                                70,
                                                const Color(0xFF81C784),
                                              ), // Bright highlight green
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ==================================================
                          // SAVINGS BREAKDOWN
                          // ==================================================
                          // ==================================================
                          // SAVINGS BREAKDOWN
                          // ==================================================
                          const Text(
                            'Savings Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ONE WHITE CONTAINER FOR ALL BREAKDOWN ITEMS
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildBreakdownItem(
                                  title: 'Peak Avoided',
                                  amount: '\$10.40',
                                  percentage: 0.70,
                                ),

                               

                                _buildBreakdownItem(
                                  title: 'Off-Peak Usage',
                                  amount: '\$6.75',
                                  percentage: 0.45,
                                ),

                               

                                _buildBreakdownItem(
                                  title: 'Efficient Habits',
                                  amount: '\$1.45',
                                  percentage: 0.12,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
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
  // MINI BAR
  // ==============================================================

  Widget _buildChartBar(double height, Color color) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBreakdownItem({
  required String title,
  required String amount,
  required double percentage,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 2,
      bottom: 18,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // TITLE + AMOUNT
        // ==========================================================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ==========================================================
        // PROGRESS BAR
        // ==========================================================

        Stack(
          children: [
            // Track
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Progress
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.lowDemand,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}
