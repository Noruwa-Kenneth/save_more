import 'package:flutter/material.dart';
import '/theme.dart';
import 'manage_account_screen.dart';
import 'notifications_screen.dart';
import 'location_screen.dart';
import 'appliance_preferences_screen.dart';
import 'about_peaksaver_screen.dart';
import 'help_support_screen.dart';
import 'electricity_plan_screen.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onPlanChanged;

  const MenuScreen({super.key, 
  required this.onBack, 
  required this.onPlanChanged});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
                    'Menu',
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

                padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // ======================================================
                    // ACCOUNT
                    // ======================================================
                    const Text(
                      'ACCOUNT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Manage Account',
                      subtitle: 'Manage your personal information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageAccountScreen(
                              onBack: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Manage alert preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsScreen(
                              onBack: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      subtitle: 'Halifax, Nova Scotia',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LocationScreen(
                              onBack: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // ENERGY
                    // ======================================================
                    const Text(
                      'ENERGY',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildMenuItem(
                      icon: Icons.home_outlined,
                      title: 'Appliance Preferences',
                      subtitle: 'Manage your appliances',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppliancePreferencesScreen(
                              onBack: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.home_outlined,
                      title: 'Electricity Plan',
                      subtitle: 'Manage your electricity plan',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ElectricityPlanScreen(
                              onBack: () {
                                Navigator.pop(context, true);
                              },
                            ),
                          ),
                        );

                        if (!mounted) return;

                        // Tell the parent navigation that the plan may have changed.
                        widget.onBack();
                      },
                    ),
                    const SizedBox(height: 24),

                    // ======================================================
                    // SUPPORT
                    // ======================================================
                    const Text(
                      'SUPPORT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with PeakSaver NS',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HelpSupportScreen(
                              onBack: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About PeakSaver NS',
                      subtitle: 'Learn more about the app',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AboutPeakSaverScreen(
                              onBack: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // ======================================================
                    // SIGN OUT
                    // ======================================================
                    GestureDetector(
                      onTap: () {
                        _showSignOutDialog();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.redAccent,
                              size: 20,
                            ),

                            SizedBox(width: 10),

                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // APP VERSION
                    // ======================================================
                    const Center(
                      child: Text(
                        'PeakSaver NS',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.white24, fontSize: 10),
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
  // MENU ITEM
  // ==============================================================

  // ==============================================================
  // MENU ITEM
  // ==============================================================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: AppColors.secondaryNavy.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),

      child: GestureDetector(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          child: Row(
            children: [
              // ==========================================================
              // ICON
              // ==========================================================
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icon, color: Colors.white, size: 21),
              ),

              const SizedBox(width: 14),

              // ==========================================================
              // TEXT
              // ==========================================================
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

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // ARROW
              // ==========================================================
              const Icon(Icons.chevron_right, color: Colors.white38, size: 21),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SIGN OUT DIALOG
  // ==============================================================

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sign Out?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to sign out of PeakSaver NS?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Authentication logout will go here.
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
