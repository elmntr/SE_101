// lib/screen/login/widgets/login_scaffold_desktop.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/screen/login/widgets/login_header.dart';
import 'package:chickenjoo_inventory/screen/commissary/login/hq_access_gate.dart';

/// Desktop/Web-specific login scaffold with the full login header.
/// This is optimized for larger screens where the header can be displayed.
class LoginScaffoldDesktop extends StatelessWidget {
  final Widget branchSelector;
  final Widget loginForm;

  const LoginScaffoldDesktop({
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
                      const LoginHeader(),
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
