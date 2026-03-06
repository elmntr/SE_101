// lib/screen/commissary/login/commissary_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'widgets/login_form.dart';
import 'widgets/login_scaffold_mobile.dart';
import 'widgets/login_scaffold_desktop.dart';

/// Login screen focused only on explicit sign-in attempts.
/// 
/// Session restoration is handled by AuthGateScreen before this screen is shown.
/// This screen only handles:
/// 1. Displaying the login form
/// 2. Processing explicit sign-in attempts
/// 3. Showing login errors
class CommissaryLoginScreen extends StatefulWidget {
  const CommissaryLoginScreen({super.key});

  @override
  State<CommissaryLoginScreen> createState() => _CommissaryLoginScreenState();
}

class _CommissaryLoginScreenState extends State<CommissaryLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  late final SupabaseAuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = authService;
    // Session restoration is handled by AuthGateScreen - no need to check here
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    print('🔐 [LOGIN] Attempting login with email: $email');

    if (email.isEmpty || password.isEmpty) {
      print('🔐 [LOGIN] Empty email or password');
      _showSnackBar('Please enter both email and password.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print('🔐 [LOGIN] Calling authService.signIn...');
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      print('🔐 [LOGIN] signIn result: success=${result.success}, message=${result.message}, localUser=${result.localUser != null}');

      if (!mounted) return;

      if (!result.success || result.localUser == null) {
        print('🔐 [LOGIN] Login failed: ${result.message}');
        _showSnackBar(result.message ?? 'Invalid email or password.');
        setState(() => _isSubmitting = false);
        return;
      }

      print('🔐 [LOGIN] Login successful! Navigating to commissary home...');
      Navigator.pushReplacementNamed(context, '/commissary-home', arguments: result.localUser);
    } catch (e, stackTrace) {
      print('🔐 [LOGIN] Exception: $e');
      print('🔐 [LOGIN] StackTrace: $stackTrace');
      if (!mounted) return;
      _showSnackBar('An error occurred. Please try again.');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginButtonWidth = AppLayout.loginButtonWidth(context);

    // Determine if we're on mobile based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600 && !kIsWeb;

    final loginForm = Focus(
      onKey: (node, event) {
        if (event.logicalKey.keyLabel == 'Enter') {
          _handleLogin();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: LoginForm(
        emailController: _emailController,
        passwordController: _passwordController,
        isPasswordVisible: _isPasswordVisible,
        isSubmitting: _isSubmitting,
        onPasswordVisibilityToggle: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
        onLogin: _handleLogin,
        loginButtonWidth: loginButtonWidth,
      ),
    );

    if (isMobile) {
      return LoginScaffoldMobile(
        loginForm: loginForm,
      );
    } else {
      return LoginScaffoldDesktop(
        loginForm: loginForm,
      );
    }
  }
}
