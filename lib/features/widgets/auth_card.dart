import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String illustrationPath;
  final Widget form;
  final String bottomText;
  final String bottomAction;
  final VoidCallback onBottomAction;

  const AuthCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustrationPath,
    required this.form,
    required this.bottomText,
    required this.bottomAction,
    required this.onBottomAction,
  });

  static const Color purple = Color(0xFF5146B9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(
              28,
              28,
              28,
              20,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              children: [
                // ==========================================================
                // ILLUSTRATION
                // ==========================================================

                SizedBox(
                  height: 185,
                  width: double.infinity,

                  child: Image.asset(
                    illustrationPath,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 12),

                // ==========================================================
                // TITLE
                // ==========================================================

                Text(
                  title,
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                // ==========================================================
                // SUBTITLE
                // ==========================================================

                Text(
                  subtitle,
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(0xFF858585),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================================
                // FORM
                // ==========================================================

                form,

                const SizedBox(height: 22),

                // ==========================================================
                // BOTTOM NAVIGATION
                // ==========================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Flexible(
                      child: Text(
                        bottomText,
                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 11,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: onBottomAction,

                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),

                        minimumSize: Size.zero,

                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),

                      child: Text(
                        bottomAction,

                        style: const TextStyle(
                          color: purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}