import 'package:flutter/material.dart';
import '/theme.dart';

class DeleteAccountScreen extends StatefulWidget {
  final VoidCallback onBack;

  const DeleteAccountScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState
    extends State<DeleteAccountScreen> {
  bool _confirmed = false;

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
                    'Delete Account',
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
                padding: const EdgeInsets.fromLTRB(
                  20,
                  25,
                  20,
                  35,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======================================================
                    // WARNING ICON
                    // ======================================================

                    Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: AppColors.highDemand
                              .withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.highDemand
                                .withValues(alpha: 0.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.highDemand,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ======================================================
                    // TITLE
                    // ======================================================

                    const Center(
                      child: Text(
                        'Delete your account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        'This action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.highDemand,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // WARNING CARD
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF182D49),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'What will happen?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildWarningItem(
                            icon: Icons.person_outline,
                            text:
                                'Your PeakSaver NS account will be permanently deleted.',
                          ),

                          const SizedBox(height: 13),

                          _buildWarningItem(
                            icon: Icons.bar_chart_outlined,
                            text:
                                'Your savings history and energy data will be removed.',
                          ),

                          const SizedBox(height: 13),

                          _buildWarningItem(
                            icon: Icons.notifications_none,
                            text:
                                'You will no longer receive PeakSaver NS alerts and notifications.',
                          ),

                          const SizedBox(height: 13),

                          _buildWarningItem(
                            icon: Icons.settings_outlined,
                            text:
                                'Your preferences and personalized settings will be deleted.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    // CONFIRMATION
                    // ======================================================

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _confirmed = !_confirmed;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _confirmed
                              ? AppColors.highDemand
                                  .withValues(alpha: 0.08)
                              : const Color(0xFF182D49),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _confirmed
                                ? AppColors.highDemand
                                : Colors.white
                                    .withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _confirmed
                                  ? Icons.check_box
                                  : Icons
                                      .check_box_outline_blank,
                              color: _confirmed
                                  ? AppColors.highDemand
                                  : Colors.white54,
                              size: 23,
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Text(
                                'I understand that deleting my account is permanent and my data cannot be recovered.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    // DELETE BUTTON
                    // ======================================================

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            _confirmed ? _showDeleteDialog : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.highDemand,
                          disabledBackgroundColor:
                              Colors.white
                                  .withValues(alpha: 0.08),
                          foregroundColor: Colors.white,
                          disabledForegroundColor:
                              Colors.white30,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Delete My Account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ======================================================
                    // CANCEL
                    // ======================================================

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: widget.onBack,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'PeakSaver NS',
                        style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: 0.30),
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
  // WARNING ITEM
  // ==============================================================

  Widget _buildWarningItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white54,
          size: 19,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: 0.62),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // DELETE CONFIRMATION DIALOG
  // ==============================================================

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.highDemand,
            size: 38,
          ),

          title: const Text(
            'Are you absolutely sure?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Your account and associated data will be permanently deleted. This action cannot be reversed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          actionsAlignment:
              MainAxisAlignment.spaceEvenly,

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _deleteAccount();
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: AppColors.highDemand,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // DELETE ACCOUNT
  // ==============================================================

  void _deleteAccount() {
    // ============================================================
    // TODO:
    // Connect this to Firebase Authentication / backend later.
    // ============================================================

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account deletion will be connected when authentication is added.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}