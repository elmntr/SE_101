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
        const SizedBox(height: 20),
        const Text(
          'Inventory System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontAll,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
