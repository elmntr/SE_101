// lib/screens/login/widgets/login_header.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          child: Image.asset(imageAll, height: 80, fit: BoxFit.contain),
        ),
        const SizedBox(height: spacing20),
        Text(
          'COMMISSARY',
          textAlign: TextAlign.center,
          style: AppTextStyles.header.copyWith(
            letterSpacing: 4,
            color: Colors.white70,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: spacing40),
      ],
    );
  }
}
