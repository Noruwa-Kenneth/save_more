import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../register/register_screen.dart';
import '../../home/screens/main_navigation.dart';
import '../../widgets/auth_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  static const Color purple = Color(0xFF5146B9);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigation(),
      ),
    );
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
      title: 'Hello',
      subtitle:
          'Welcome to PeakSaver NS, where you can\n'
          'manage your energy and save money.',
      illustrationPath: 'assets/images/login.png',
      bottomText: 'Don\'t have an account?',
      bottomAction: 'Sign Up',

      onBottomAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterScreen(),
          ),
        );
      },

      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          const SizedBox(height: 14),

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

          // ------------------------------------------------------------
          // FORGOT PASSWORD
          // ------------------------------------------------------------

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 0,
                ),
                minimumSize: Size.zero,
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 9,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------------
          // LOGIN BUTTON
          // ------------------------------------------------------------

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

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