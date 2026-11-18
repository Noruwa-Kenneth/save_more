import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/home_appliance_preferences.dart';
import '../../../core/providers/home_appliance_preferences_provider.dart';
import '../../../core/services/home_appliance_preferences_storage.dart';
import '/theme.dart';

class AppliancePreferencesScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const AppliancePreferencesScreen({
    super.key,
    required this.onBack,
  });

  @override
  ConsumerState<AppliancePreferencesScreen> createState() =>
      _AppliancePreferencesScreenState();
}

class _AppliancePreferencesScreenState
    extends ConsumerState<AppliancePreferencesScreen> {
  // ============================================================
  // APPLIANCE SELECTIONS
  // ============================================================

  bool _electricHeater = true;
  bool _heatPump = false;
  bool _waterHeater = true;
  bool _refrigerator = true;
  bool _dishwasher = false;
  bool _washingMachine = true;
  bool _dryer = false;
  bool _electricStove = true;
  bool _evCharger = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await ref.read(
        homeAppliancePreferencesProvider.future,
      );
      if (!mounted) return;
      setState(() {
        _electricHeater = preferences.electricHeater;
        _heatPump = preferences.heatPump;
        _waterHeater = preferences.waterHeater;
        _refrigerator = preferences.refrigerator;
        _dishwasher = preferences.dishwasher;
        _washingMachine = preferences.washingMachine;
        _dryer = preferences.dryer;
        _electricStove = preferences.electricStove;
        _evCharger = preferences.evCharger;
      });
    } catch (_) {
      // Keep the default selections visible if stored preferences cannot load.
    }
  }

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
                    'Appliance Preferences',
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
                  18,
                  20,
                  35,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======================================================
                    // INTRODUCTION
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryNavy,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bolt_outlined,
                              color: Colors.amber,
                              size: 23,
                            ),
                          ),

                          const SizedBox(width: 13),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Appliances',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Select the appliances you use at home. '
                                  'PeakSaver NS can use this information to '
                                  'provide more personalized energy-saving tips.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // APPLIANCES SECTION
                    // ======================================================

                    _sectionTitle('YOUR APPLIANCES'),

                    const SizedBox(height: 10),

                    // Electric Heater
                    _buildApplianceItem(
                      icon: Icons.thermostat_outlined,
                      title: 'Electric Heater',
                      subtitle: 'Electric heating system',
                      value: _electricHeater,
                      onChanged: (value) {
                        setState(() {
                          _electricHeater = value;
                        });
                      },
                    ),

                    // Heat Pump
                    _buildApplianceItem(
                      icon: Icons.ac_unit_outlined,
                      title: 'Heat Pump',
                      subtitle: 'Heat pump heating and cooling',
                      value: _heatPump,
                      onChanged: (value) {
                        setState(() {
                          _heatPump = value;
                        });
                      },
                    ),

                    // Water Heater
                    _buildApplianceItem(
                      icon: Icons.water_drop_outlined,
                      title: 'Water Heater',
                      subtitle: 'Electric hot water system',
                      value: _waterHeater,
                      onChanged: (value) {
                        setState(() {
                          _waterHeater = value;
                        });
                      },
                    ),

                    // Refrigerator
                    _buildApplianceItem(
                      icon: Icons.kitchen_outlined,
                      title: 'Refrigerator',
                      subtitle: 'Refrigerator or freezer',
                      value: _refrigerator,
                      onChanged: (value) {
                        setState(() {
                          _refrigerator = value;
                        });
                      },
                    ),

                    // Dishwasher
                    _buildApplianceItem(
                      icon: Icons.local_dining_outlined,
                      title: 'Dishwasher',
                      subtitle: 'Electric dishwasher',
                      value: _dishwasher,
                      onChanged: (value) {
                        setState(() {
                          _dishwasher = value;
                        });
                      },
                    ),

                    // Washing Machine
                    _buildApplianceItem(
                      icon: Icons.local_laundry_service_outlined,
                      title: 'Washing Machine',
                      subtitle: 'Clothes washer',
                      value: _washingMachine,
                      onChanged: (value) {
                        setState(() {
                          _washingMachine = value;
                        });
                      },
                    ),

                    // Dryer
                    _buildApplianceItem(
                      icon: Icons.local_laundry_service,
                      title: 'Clothes Dryer',
                      subtitle: 'Electric clothes dryer',
                      value: _dryer,
                      onChanged: (value) {
                        setState(() {
                          _dryer = value;
                        });
                      },
                    ),

                    // Electric Stove
                    _buildApplianceItem(
                      icon: Icons.restaurant_outlined,
                      title: 'Electric Stove',
                      subtitle: 'Electric cooking appliance',
                      value: _electricStove,
                      onChanged: (value) {
                        setState(() {
                          _electricStove = value;
                        });
                      },
                    ),

                    // EV Charger
                    _buildApplianceItem(
                      icon: Icons.ev_station_outlined,
                      title: 'EV Charger',
                      subtitle: 'Electric vehicle charging',
                      value: _evCharger,
                      onChanged: (value) {
                        setState(() {
                          _evCharger = value;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // ======================================================
                    // SAVE BUTTON
                    // ======================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _savePreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Save Preferences',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ======================================================
                    // FOOTNOTE
                    // ======================================================

                    const Center(
                      child: Text(
                        'You can change these preferences anytime.',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
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
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ==============================================================
  // APPLIANCE ITEM
  // ==============================================================

  Widget _buildApplianceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: AppColors.secondaryNavy.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
                color: value
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value
                    ? Colors.white
                    : Colors.white54,
                size: 22,
              ),
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
                    style: TextStyle(
                      color: value
                          ? Colors.white
                          : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ==========================================================
            // SWITCH
            // ==========================================================

            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primaryNavy,
              activeTrackColor: Colors.white,
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SAVE PREFERENCES
  // ==============================================================

  Future<void> _savePreferences() async {
    final preferences = HomeAppliancePreferences(
      electricHeater: _electricHeater,
      heatPump: _heatPump,
      waterHeater: _waterHeater,
      refrigerator: _refrigerator,
      dishwasher: _dishwasher,
      washingMachine: _washingMachine,
      dryer: _dryer,
      electricStove: _electricStove,
      evCharger: _evCharger,
    );
    try {
      await HomeAppliancePreferencesStorage().save(preferences);
      ref.invalidate(homeAppliancePreferencesProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save preferences: $error')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Appliance preferences saved.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.secondaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
