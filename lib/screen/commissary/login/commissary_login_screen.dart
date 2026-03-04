// lib/screen/commissary/login/commissary_login_screen.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

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
      // Use Supabase Auth for authentication
      // This establishes a Supabase session with auth.uid() for RLS
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

      print('🔐 [LOGIN] Login successful! Navigating to home...');
      // Navigate to home with authenticated user data
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
    final fieldPadding = AppLayout.fieldPadding(context);
    final loginButtonWidth = AppLayout.loginButtonWidth(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEF4848), Color(0xFFD32F2F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: fieldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  _buildHeader(),
                  const SizedBox(height: 40),
                  // Login Form
                  _buildLoginForm(loginButtonWidth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(
          width: 300,
          child: Image.asset(imageAll, height: 80, fit: BoxFit.contain),
        ),
        const SizedBox(height: 32),
        const Text(
          'COMMISSARY',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 4,
            fontFamily: fontAll,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(double buttonWidth) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to continue',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: fontAll,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Email Field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Password Field
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 32),
          
          // Login Button
          SizedBox(
            width: buttonWidth,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4848),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: fontAll,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
