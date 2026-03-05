// lib/screen/auth/auth_gate_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';

/// Auth gate screen that waits for auth bootstrap completion
/// before routing to the appropriate screen.
/// 
/// This screen:
/// 1. Waits for auth bootstrap to complete
/// 2. Routes to /home if authenticated, /login if not
/// 3. Subscribes to auth state changes to handle post-startup auth events
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  late final SupabaseAuthService _authService;
  StreamSubscription<AuthLifecycleState>? _lifecycleSubscription;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _authService = authService;
    _initAuthGate();
  }

  Future<void> _initAuthGate() async {
    // Wait for bootstrap to complete
    final state = await _authService.bootstrap();
    
    if (!mounted) return;
    
    // Navigate based on final auth state
    _navigateBasedOnState(state);
    
    // Subscribe to lifecycle changes for post-startup auth events
    _lifecycleSubscription = _authService.lifecycleStateChanges.listen((state) {
      if (!mounted || _hasNavigated) return;
      
      // Only react to state changes after initial navigation
      if (state == AuthLifecycleState.unauthenticated) {
        _navigateToLogin();
      }
    });
  }

  void _navigateBasedOnState(AuthLifecycleState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    
    if (state == AuthLifecycleState.authenticated && _authService.currentUser != null) {
      _navigateToHome(_authService.currentUser!);
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToHome(UserData user) {
    if (user.isCommissary) {
      Navigator.pushReplacementNamed(context, '/commissary-home', arguments: user);
    } else {
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _lifecycleSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.primaryGradient,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: spacing24),
              Text(
                'Loading...',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
