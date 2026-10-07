
import 'dart:async';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds:6),
      () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      },
    );
  }
@override
  Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Colors.transparent,
  body: Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000428), // Top
          Color(0xFF004E92), // Bottom
        ],
      ),
    ),
    child: SafeArea(
      child: Center( 
         child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 180,
            ),
            SizedBox(height: 20),
            SizedBox(height: 8),
           CircularProgressIndicator(
        color: Colors.white,
      ),
          ],
        ),
      ),
    ),
  ),
);
}
}
