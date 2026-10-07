import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../home/screens/main_navigation.dart';
import '../../widgets/auth_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  static const Color purple = Color(0xFF5146B9);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF777777),
        fontSize: 11,
      ),
      floatingLabelStyle: const TextStyle(
        color: purple,
        fontSize: 11,
      ),
      prefixIcon: Icon(
        icon,
        color: Color(0xFF777777),
        size: 18,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFBDBDBD),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: purple,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _socialButton({
    required FaIconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      title: 'Create Account',
      subtitle:
          'Create your PeakSaver NS account and start\n'
          'saving energy and reducing costs.',
      illustrationPath: 'assets/images/register.png',
      bottomText: 'Already have an account?',
      bottomAction: 'Login',

      onBottomAction: () {
        Navigator.pop(context);
      },

      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ------------------------------------------------------------
          // FULL NAME
          // ------------------------------------------------------------

          TextField(
            controller: _fullNameController,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
            ),
            decoration: _inputDecoration(
              label: 'Name',
              icon: Icons.person_outline,
            ),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------------
          // EMAIL
          // ------------------------------------------------------------

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
            ),
            decoration: _inputDecoration(
              label: 'Email',
              icon: Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------------
          // PASSWORD
          // ------------------------------------------------------------

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
            ),
            decoration: _inputDecoration(
              label: 'Password',
              icon: Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF777777),
                  size: 18,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------------
          // CONFIRM PASSWORD
          // ------------------------------------------------------------

          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
            ),
            decoration: _inputDecoration(
              label: 'Confirm Password',
              icon: Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF777777),
                  size: 18,
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------
          // TERMS
          // ------------------------------------------------------------

          Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Checkbox(
                  value: _acceptTerms,
                  activeColor: purple,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),
              ),

              const SizedBox(width: 4),

              const Expanded(
                child: Text(
                  'I agree to the Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------------
          // SIGN UP
          // ------------------------------------------------------------

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                if (!_acceptTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please accept the Terms & Conditions',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainNavigation(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------------------
          // SOCIAL
          // ------------------------------------------------------------

          const Text(
            'Sign up using',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialButton(
                icon: FontAwesomeIcons.facebookF,
                color: const Color(0xFF4267B2),
                onPressed: () {},
              ),

              const SizedBox(width: 10),

              _socialButton(
                icon: FontAwesomeIcons.google,
                color: const Color(0xFFDB4437),
                onPressed: () {},
              ),

              const SizedBox(width: 10),

              _socialButton(
                icon: FontAwesomeIcons.linkedinIn,
                color: const Color(0xFF0077B5),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}