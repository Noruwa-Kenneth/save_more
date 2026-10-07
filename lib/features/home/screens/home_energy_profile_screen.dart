import 'package:flutter/material.dart';
import '/theme.dart';

class HomeEnergyProfileScreen extends StatefulWidget {
  final VoidCallback onBack;

  const HomeEnergyProfileScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<HomeEnergyProfileScreen> createState() =>
      _HomeEnergyProfileScreenState();
}

class _HomeEnergyProfileScreenState
    extends State<HomeEnergyProfileScreen> {
  String _homeType = 'Detached House';
  String _occupants = '2';
  String _homeSize = '1,000 - 1,500 sq ft';
  String _heatingSource = 'Heat Pump';

  bool _waterHeater = true;
  bool _dryer = false;
  bool _dishwasher = true;
  bool _electricStove = true;
  bool _evCharger = false;

  String _energyGoal = 'Reduce Electricity Bill';

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

                  const Text(
                    'Home & Energy Profile',
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
                    // INTRO
                    // ======================================================

                    Text(
                      'Personalize your energy profile',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Tell PeakSaver NS about your home and energy usage so we can provide more personalized savings recommendations.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // HOME
                    // ======================================================

                    _sectionTitle('HOME'),

                    _buildDropdownCard(
                      icon: Icons.home_outlined,
                      title: 'Home Type',
                      value: _homeType,
                      items: const [
                        'Detached House',
                        'Semi-Detached',
                        'Townhouse',
                        'Apartment',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _homeType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildDropdownCard(
                      icon: Icons.people_outline,
                      title: 'People in Home',
                      value: _occupants,
                      items: const [
                        '1',
                        '2',
                        '3',
                        '4',
                        '5+',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _occupants = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildDropdownCard(
                      icon: Icons.square_foot_outlined,
                      title: 'Home Size',
                      value: _homeSize,
                      items: const [
                        'Under 1,000 sq ft',
                        '1,000 - 1,500 sq ft',
                        '1,500 - 2,000 sq ft',
                        '2,000 - 2,500 sq ft',
                        'Over 2,500 sq ft',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _homeSize = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // HEATING
                    // ======================================================

                    _sectionTitle('HEATING'),

                    _buildDropdownCard(
                      icon: Icons.thermostat_outlined,
                      title: 'Primary Heating',
                      value: _heatingSource,
                      items: const [
                        'Heat Pump',
                        'Electric Baseboard',
                        'Oil',
                        'Natural Gas',
                        'Wood',
                        'Other',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _heatingSource = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // APPLIANCES
                    // ======================================================

                    _sectionTitle('APPLIANCES'),

                    _buildSwitchCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Electric Water Heater',
                      subtitle: 'Uses electricity to heat water',
                      value: _waterHeater,
                      onChanged: (value) {
                        setState(() {
                          _waterHeater = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildSwitchCard(
                      icon: Icons.local_laundry_service_outlined,
                      title: 'Electric Dryer',
                      subtitle: 'Clothes dryer powered by electricity',
                      value: _dryer,
                      onChanged: (value) {
                        setState(() {
                          _dryer = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildSwitchCard(
                      icon: Icons.kitchen_outlined,
                      title: 'Dishwasher',
                      subtitle: 'Electric dishwasher',
                      value: _dishwasher,
                      onChanged: (value) {
                        setState(() {
                          _dishwasher = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildSwitchCard(
                      icon: Icons.restaurant_outlined,
                      title: 'Electric Stove / Oven',
                      subtitle: 'Electric cooking appliances',
                      value: _electricStove,
                      onChanged: (value) {
                        setState(() {
                          _electricStove = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildSwitchCard(
                      icon: Icons.ev_station_outlined,
                      title: 'EV Charger',
                      subtitle: 'Electric vehicle charging at home',
                      value: _evCharger,
                      onChanged: (value) {
                        setState(() {
                          _evCharger = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // ENERGY GOAL
                    // ======================================================

                    _sectionTitle('ENERGY GOAL'),

                    _buildGoalCard(
                      title: 'Reduce Electricity Bill',
                      icon: Icons.savings_outlined,
                      selected:
                          _energyGoal == 'Reduce Electricity Bill',
                      onTap: () {
                        setState(() {
                          _energyGoal = 'Reduce Electricity Bill';
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildGoalCard(
                      title: 'Avoid Peak Demand',
                      icon: Icons.bolt_outlined,
                      selected:
                          _energyGoal == 'Avoid Peak Demand',
                      onTap: () {
                        setState(() {
                          _energyGoal = 'Avoid Peak Demand';
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildGoalCard(
                      title: 'Reduce Overall Usage',
                      icon: Icons.eco_outlined,
                      selected:
                          _energyGoal == 'Reduce Overall Usage',
                      onTap: () {
                        setState(() {
                          _energyGoal = 'Reduce Overall Usage';
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    _buildGoalCard(
                      title: 'All of the Above',
                      icon: Icons.auto_awesome_outlined,
                      selected:
                          _energyGoal == 'All of the Above',
                      onTap: () {
                        setState(() {
                          _energyGoal = 'All of the Above';
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // ======================================================
                    // SAVE BUTTON
                    // ======================================================

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lowDemand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save Energy Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'You can update these preferences anytime.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
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
  // DROPDOWN CARD
  // ==============================================================

  Widget _buildDropdownCard({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF182D49),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: AppColors.secondaryNavy,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 20,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    },
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
  // SWITCH CARD
  // ==============================================================

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF182D49),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

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
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            activeThumbColor: AppColors.lowDemand,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ENERGY GOAL CARD
  // ==============================================================

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lowDemand.withValues(alpha: 0.12)
              : const Color(0xFF182D49),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.lowDemand
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.lowDemand
                  : Colors.white70,
              size: 22,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.lowDemand,
                size: 21,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.white.withValues(alpha: 0.25),
                size: 21,
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SAVE PROFILE
  // ==============================================================

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your energy profile has been saved.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}