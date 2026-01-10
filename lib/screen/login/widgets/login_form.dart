// lib/screens/login/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool isSubmitting;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onLogin;
  final double loginButtonWidth;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.isSubmitting,
    required this.onPasswordVisibilityToggle,
    required this.onLogin,
    required this.loginButtonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontFamily: fontAll,
              fontSize: 18,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Email Address',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
            ],
          ),
          child: TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            style: const TextStyle(
              fontFamily: fontAll,
              fontSize: 18,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Password',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 18,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: onPasswordVisibilityToggle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: loginButtonWidth,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD62828),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 10,
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
