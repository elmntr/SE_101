// lib/screen/login/widgets/login_scaffold_mobile.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/screen/commissary/login/hq_access_gate.dart';

/// Mobile-specific login scaffold without the login header.
/// This is optimized for smaller screens where the header would take too much space.
class LoginScaffoldMobile extends StatelessWidget {
  final Widget branchSelector;
  final Widget loginForm;

  const LoginScaffoldMobile({
    super.key,
    required this.branchSelector,
    required this.loginForm,
  });

  @override
  Widget build(BuildContext context) {
    final fieldPadding = AppLayout.fieldPadding(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: AppDecorations.primaryBackground,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: fieldPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // No LoginHeader for mobile
                      branchSelector,
                      const SizedBox(height: 20),
                      loginForm,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 12,
            right: 12,
            child: HqAccessGate(),
          ),
        ],
      ),
    );
  }
}
