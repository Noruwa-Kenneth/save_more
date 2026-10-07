import 'package:flutter/material.dart';
import '/theme.dart';

import 'home_screen.dart';
import 'alert_screen.dart';
import 'savings_screen.dart';
import 'energy_tips.dart';
import 'menu_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  // Used to force HomeScreen to reload when needed.
  int _homeRefreshKey = 0;

  @override
  void initState() {
    super.initState();

    _buildPages();
  }

  void _buildPages() {
    _pages = [
      HomeScreen(
        key: ValueKey(_homeRefreshKey),
      ),

      // Alerts
      AlertScreen(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),

      // Savings
      SavingsScreen(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),

      // Tips
      EnergyTipsScreen(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),

      // Menu
      MenuScreen(
  onBack: () {
    setState(() {
      _selectedIndex = 0;
    });
  },

  onPlanChanged: () {
    setState(() {
      _homeRefreshKey++;
      _buildPages();
      _selectedIndex = 0;
    });
  },
),
    ];
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     // If returning to Home, refresh it.
  //     if (index == 0) {
  //       _homeRefreshKey++;
  //       _buildPages();
  //     }

  //     _selectedIndex = index;
  //   });
  // }
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,

        selectedItemColor: AppColors.primaryNavy,
        unselectedItemColor: Colors.grey,

        selectedFontSize: 12,
        unselectedFontSize: 11,

        elevation: 8,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Savings',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            activeIcon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}