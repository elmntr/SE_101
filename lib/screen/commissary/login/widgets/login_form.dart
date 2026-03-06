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
          decoration: AppDecorations.inputField,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.input,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              border: InputBorder.none,
              contentPadding: paddingInput,
            ),
          ),
        ),
        const SizedBox(height: spacing20),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(radiusPill),
            boxShadow: [
              BoxShadow(color: shadowColor.withValues(alpha: shadowOpacity), blurRadius: shadowBlurMedium),
            ],
          ),
          child: TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            style: AppTextStyles.input,
            decoration: InputDecoration(
              hintText: 'Password',
              border: InputBorder.none,
              contentPadding: paddingInput,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: textMuted,
                ),
                onPressed: onPasswordVisibilityToggle,
              ),
            ),
          ),
        ),
        const SizedBox(height: spacing30),
        SizedBox(
          width: loginButtonWidth,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: loginButtonRed,
              foregroundColor: Colors.white,
              padding: paddingVerticalXl,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusLg),
              ),
              elevation: elevationHigh,
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: progressIndicatorSize,
                    width: progressIndicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: progressIndicatorStrokeWidth,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'LOGIN',
                    style: AppTextStyles.button.copyWith(
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
