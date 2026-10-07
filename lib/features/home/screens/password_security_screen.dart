import 'package:flutter/material.dart';
import '/theme.dart';

class PasswordSecurityScreen extends StatefulWidget {
  final VoidCallback onBack;

  const PasswordSecurityScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends State<PasswordSecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  int _passwordStrength = 0;

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;

    int strength = 0;

    if (password.length >= 8) {
      strength++;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength++;
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    }

    setState(() {
      _passwordStrength = strength;
    });
  }

  String get _strengthText {
    switch (_passwordStrength) {
      case 0:
        return 'Enter a new password';
      case 1:
        return 'Weak password';
      case 2:
        return 'Fair password';
      case 3:
        return 'Good password';
      case 4:
        return 'Strong password';
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return AppColors.highDemand;
      case 2:
        return AppColors.moderateDemand;
      case 3:
      case 4:
        return AppColors.lowDemand;
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                    'Password & Security',
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),

                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F6F8),

                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(
                      20,
                      26,
                      20,
                      35,
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // SECURITY INTRO
                          // ==================================================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Keep your account secure',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(height: 4),

                                      Text(
                                        'Use a strong password that you do not reuse elsewhere.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // CHANGE PASSWORD
                          // ==================================================

                          const Text(
                            'CHANGE PASSWORD',
                            style: TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildPasswordField(
                            label: 'Current Password',
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            onToggle: () {
                              setState(() {
                                _obscureCurrent =
                                    !_obscureCurrent;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildPasswordField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            onToggle: () {
                              setState(() {
                                _obscureNew = !_obscureNew;
                              });
                            },
                          ),

                          const SizedBox(height: 10),

                          // Password strength
                          if (_newPasswordController
                              .text
                              .isNotEmpty)
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    4,
                                    (index) {
                                      return Expanded(
                                        child: Container(
                                          height: 5,
                                          margin:
                                              EdgeInsets.only(
                                            right:
                                                index == 3
                                                    ? 0
                                                    : 5,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color: index <
                                                    _passwordStrength
                                                ? _strengthColor
                                                : Colors
                                                    .grey
                                                    .shade300,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  _strengthText,
                                  style: TextStyle(
                                    color: _strengthColor,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          _buildPasswordField(
                            label: 'Confirm New Password',
                            controller:
                                _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            onToggle: () {
                              setState(() {
                                _obscureConfirm =
                                    !_obscureConfirm;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // PASSWORD REQUIREMENTS
                          // ==================================================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password requirements',
                                  style: TextStyle(
                                    color:
                                        AppColors.primaryNavy,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                _buildRequirement(
                                  'At least 8 characters',
                                  _newPasswordController
                                          .text
                                          .length >=
                                      8,
                                ),

                                _buildRequirement(
                                  'One uppercase letter',
                                  RegExp(r'[A-Z]').hasMatch(
                                    _newPasswordController.text,
                                  ),
                                ),

                                _buildRequirement(
                                  'One number',
                                  RegExp(r'[0-9]').hasMatch(
                                    _newPasswordController.text,
                                  ),
                                ),

                                _buildRequirement(
                                  'One special character',
                                  RegExp(
                                    r'[!@#$%^&*(),.?":{}|<>]',
                                  ).hasMatch(
                                    _newPasswordController.text,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // SAVE BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primaryNavy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ==================================================
                          // OTHER SECURITY
                          // ==================================================

                          const Text(
                            'OTHER SECURITY',
                            style: TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildSecurityOption(
                            icon: Icons.devices_outlined,
                            title: 'Active Devices',
                            subtitle:
                                'Manage devices signed into your account',
                            onTap: () {},
                          ),

                          const SizedBox(height: 10),

                          _buildSecurityOption(
                            icon: Icons.fingerprint,
                            title: 'Biometric Login',
                            subtitle:
                                'Use fingerprint or face recognition',
                            onTap: () {},
                            showSwitch: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: obscureText,

          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }

            return null;
          },

          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 14,
          ),

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.primaryNavy,
              size: 21,
            ),

            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade500,
                size: 21,
              ),
            ),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryNavy,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REQUIREMENT
  // ============================================================

  Widget _buildRequirement(
    String text,
    bool completed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 17,
            color: completed
                ? AppColors.lowDemand
                : Colors.grey.shade400,
          ),

          const SizedBox(width: 9),

          Text(
            text,
            style: TextStyle(
              color: completed
                  ? AppColors.lowDemand
                  : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY OPTION
  // ============================================================

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showSwitch = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy.withValues(
                      alpha: 0.07,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryNavy,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                if (showSwitch)
                  Switch(
                    value: false,
                    onChanged: (_) {},
                    activeThumbColor:
                        AppColors.primaryNavy,
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  void _changePassword() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.highDemand,
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'New passwords do not match.',
          ),
        ),
      );

      return;
    }

    if (_passwordStrength < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.moderateDemand,
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'Please choose a stronger password.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),

            SizedBox(width: 10),

            Text(
              'Password updated successfully',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }
}