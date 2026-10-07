import 'package:flutter/material.dart';
import '/theme.dart';

class AboutPeakSaverScreen extends StatelessWidget {
  final VoidCallback onBack;

  const AboutPeakSaverScreen({
    super.key,
    required this.onBack,
  });

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
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'About PeakSaver NS',
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  35,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======================================================
                    // APP BRAND
                    // ======================================================

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: Colors.amber,
                              size: 48,
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'PeakSaver NS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Smart Energy. Smarter Savings.',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.55,
                              ),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.07,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ======================================================
                    // ABOUT
                    // ======================================================

                    _sectionTitle('ABOUT'),

                    _buildInfoCard(
                      icon: Icons.bolt_outlined,
                      title: 'What is PeakSaver NS?',
                      child: const Text(
                        'PeakSaver NS is an energy optimization platform '
                        'designed to help households understand their '
                        'electricity usage, reduce peak demand, and find '
                        'opportunities to save on energy costs.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.55,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.track_changes_outlined,
                      title: 'Our Mission',
                      child: const Text(
                        'Our mission is to help Nova Scotia households '
                        'make smarter energy decisions while supporting '
                        'a more stable and sustainable electricity grid.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.55,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // FEATURES
                    // ======================================================

                    _sectionTitle('WHAT WE DO'),

                    _buildFeatureItem(
                      icon: Icons.notifications_none,
                      title: 'Peak Demand Alerts',
                      description:
                          'Stay informed when electricity demand is expected '
                          'to be high.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.savings_outlined,
                      title: 'Savings Opportunities',
                      description:
                          'Discover opportunities to shift energy usage and '
                          'reduce costs.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.lightbulb_outline,
                      title: 'Energy Tips',
                      description:
                          'Get practical recommendations for more efficient '
                          'energy use.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.insights_outlined,
                      title: 'Energy Insights',
                      description:
                          'Understand your energy habits and identify areas '
                          'where you can improve.',
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // LEGAL
                    // ======================================================

                    _sectionTitle('LEGAL & INFORMATION'),

                    _buildActionItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        _showComingSoon(context, 'Privacy Policy');
                      },
                    ),

                    _buildActionItem(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {
                        _showComingSoon(context, 'Terms of Service');
                      },
                    ),

                    _buildActionItem(
                      icon: Icons.info_outline,
                      title: 'Acknowledgements',
                      onTap: () {
                        _showAcknowledgements(context);
                      },
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // FOOTER
                    // ======================================================

                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PeakSaver NS',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.30,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Built for a smarter energy future.',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.20,
                              ),
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '© 2026 PeakSaver NS',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ],
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
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ==============================================================
  // INFO CARD
  // ==============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.07,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 7),

                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // FEATURE ITEM
  // ==============================================================

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy.withValues(
          alpha: 0.70,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.07,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  description,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ACTION ITEM
  // ==============================================================

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.07,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // COMING SOON
  // ==============================================================

  void _showComingSoon(
    BuildContext context,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This section will be available soon.',
            style: TextStyle(
              color: Colors.white60,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // ACKNOWLEDGEMENTS
  // ==============================================================

  void _showAcknowledgements(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Acknowledgements',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'PeakSaver NS uses modern technology and energy insights '
            'to help households make smarter electricity decisions.',
            style: TextStyle(
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}