import 'package:flutter/material.dart';
import '/theme.dart';

class HelpSupportScreen extends StatefulWidget {
  final VoidCallback onBack;

  const HelpSupportScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'question': 'What is Peak Demand?',
      'answer':
          'Peak demand is the period when electricity usage across the grid is at its highest. PeakSaver NS helps you identify these periods so you can shift some electricity usage to lower-demand times.',
    },
    {
      'question': 'How does PeakSaver NS help me save money?',
      'answer':
          'PeakSaver NS provides energy insights, savings opportunities, alerts and practical tips that can help you shift electricity usage and develop more efficient energy habits.',
    },
    {
      'question': 'What are Peak Demand Alerts?',
      'answer':
          'Peak Demand Alerts notify you when a period of high electricity demand is expected. This gives you an opportunity to postpone flexible activities such as laundry or dishwashing.',
    },
    {
      'question': 'How do Energy Tips work?',
      'answer':
          'Energy Tips provide practical recommendations based on common household energy habits. Over time, these recommendations can become more personalized to your preferences.',
    },
    {
      'question': 'How are my savings calculated?',
      'answer':
          'Your estimated savings are based on energy-use patterns and the opportunities you take to shift usage away from higher-demand periods. Actual savings may vary depending on your electricity plan and usage.',
    },
    {
      'question': 'Can I change my preferences?',
      'answer':
          'Yes. You can change your notification, location, energy and appliance preferences at any time from the Menu section.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    'Help & Support',
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
                    // INTRO CARD
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryNavy,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.support_agent_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'How can we help?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Find answers to common questions or get help '
                            'with PeakSaver NS.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ======================================================
                    // SEARCH
                    // ======================================================

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryNavy.withValues(
                          alpha: 0.80,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search for help...',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white54,
                            size: 21,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // FAQ
                    // ======================================================

                    _sectionTitle('FREQUENTLY ASKED QUESTIONS'),

                    const SizedBox(height: 10),

                    ..._buildFilteredFaqs(),

                    const SizedBox(height: 20),

                    // ======================================================
                    // CONTACT SUPPORT
                    // ======================================================

                    _sectionTitle('STILL NEED HELP?'),

                    const SizedBox(height: 10),

                    _buildSupportAction(
                      icon: Icons.chat_bubble_outline,
                      title: 'Contact Support',
                      subtitle: 'Get help from the PeakSaver NS team',
                      onTap: () {
                        _showContactSupport(context);
                      },
                    ),

                    _buildSupportAction(
                      icon: Icons.bug_report_outlined,
                      title: 'Report a Problem',
                      subtitle: 'Tell us about an issue with the app',
                      onTap: () {
                        _showReportProblem(context);
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
                              color: Colors.white.withValues(alpha: 0.30),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'We are here to help.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.20),
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
  // FILTER FAQS
  // ==============================================================

  List<Widget> _buildFilteredFaqs() {
    final search = _searchController.text.trim().toLowerCase();

    final filtered = _faqs.where((faq) {
      if (search.isEmpty) {
        return true;
      }

      return faq['question']!.toLowerCase().contains(search) ||
          faq['answer']!.toLowerCase().contains(search);
    }).toList();

    if (filtered.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: AppColors.secondaryNavy.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.search_off_outlined,
                color: Colors.white38,
                size: 30,
              ),
              SizedBox(height: 10),
              Text(
                'No matching help articles found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return filtered.map((faq) {
      return _buildFaqItem(
        question: faq['question']!,
        answer: faq['answer']!,
      );
    }).toList();
  }

  // ==============================================================
  // FAQ ITEM
  // ==============================================================

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            15,
            0,
            15,
            16,
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white38,
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SUPPORT ACTION
  // ==============================================================

  Widget _buildSupportAction({
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
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
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
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
  // CONTACT SUPPORT
  // ==============================================================

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Contact Support',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Support contact options will be available here once '
            'the PeakSaver NS support system is connected.',
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

  // ==============================================================
  // REPORT PROBLEM
  // ==============================================================

  void _showReportProblem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          backgroundColor: AppColors.secondaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Report a Problem',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Describe the problem...',
              hintStyle: const TextStyle(
                color: Colors.white38,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Thanks. Your report has been recorded.',
                    ),
                    backgroundColor: AppColors.secondaryNavy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
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