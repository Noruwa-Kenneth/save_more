import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Demand levels
  static const Color lowDemand = Color(0xFF2ECC71); // Clean Green
  static const Color moderateDemand = Color(0xFFFFB300); // Warm Amber/Orange
  static const Color highDemand = Color(0xFFE74C3C); // Solid Red

  // Dark and Accent Navy tones from the design
  static const Color primaryNavy = Color(0xFF0F2038); // Deep Navy
  static const Color secondaryNavy = Color(0xFF1E3A5F); // Lighter slate Navy
  
  // Backgrounds
  static const Color backgroundLight = Color(0xFFF4F7F6); // Soft gray-blue background
  static const Color cardShadow = Color(0x0A000000); // Subtle shadow
  
  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF7F8C8D);
  static const Color textSecondary = Color(0xFF2C3E50);
  static const Color softblue = Color.fromARGB(255, 234, 240, 248); // Soft Blue
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      splashFactory: InkRipple.splashFactory,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryNavy,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.primaryNavy,
        secondary: AppColors.secondaryNavy,
        surface: AppColors.backgroundLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
