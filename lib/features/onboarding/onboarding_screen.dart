
import 'package:flutter/material.dart';
import '../auth/login/login_screen.dart';

class OnboardingPageData {
  final String? imagePath;
  final IconData? icon;
  final String title;
  final String description;

  const OnboardingPageData({
    this.imagePath,
    this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      imagePath: 'assets/images/save.png',
      title: 'Save Money',
      description:
          'Reduce electricity costs by avoiding peak demand hours.',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/notification.png',
      title: 'Smart Notifications',
      description:
          'Receive alerts before electricity demand increases.',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/globe.png',
      title: 'Help Nova Scotia',
      description:
          'Support a cleaner and more reliable energy grid.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _openLogin();
    }
  }

  void _skip() {
    _openLogin();
  }

  void _openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, screenConstraints) {
            final isShortScreen = screenConstraints.maxHeight < 600;

            return Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    right: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _skip,
                      child: const Text('Skip'),
                    ),
                  ),
                ),

                // Onboarding pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      return LayoutBuilder(
                        builder: (context, pageConstraints) {
                          final imageHeight =
                              (pageConstraints.maxHeight * 0.28)
                                  .clamp(90.0, 220.0);

                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: pageConstraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (page.imagePath != null)
                                      Image.asset(
                                        page.imagePath!,
                                        height: imageHeight,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return SizedBox(
                                            height: imageHeight,
                                            child: const Icon(
                                              Icons.broken_image_outlined,
                                              size: 80,
                                              color: Color(0xFF004E92),
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      Icon(
                                        page.icon ?? Icons.bolt,
                                        size: 120,
                                        color: const Color(0xFF004E92),
                                      ),

                                    SizedBox(
                                      height: isShortScreen ? 16 : 24,
                                    ),

                                    Text(
                                      page.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      page.description,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        height: 1.5,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Responsive page indicators
                Padding(
                  padding: EdgeInsets.only(
                    top: isShortScreen ? 8 : 16,
                    bottom: isShortScreen ? 12 : 20,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _pages.length,
                      (index) {
                        final isActive = _currentPage == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF0476C2)
                                : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Next / Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004E92),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isShortScreen ? 12 : 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
