import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Commissary Account Page - Allows commissary users to view and edit their account details
/// 
/// Features:
/// - Display account information (username, email, phone, full name)
/// - Edit account details
/// - Save changes to local database
/// - Responsive mobile/desktop layouts
/// - Memory efficient: Reuses controllers and database instance
class SettingsEditAccountPage extends StatefulWidget {
  final UserData userData;

  const SettingsEditAccountPage({
    super.key,
    required this.userData,
  });

  @override
  State<SettingsEditAccountPage> createState() => _SettingsEditAccountPageState();
}

class _SettingsEditAccountPageState extends State<SettingsEditAccountPage> {
  // Reuse database instance from AppGlobals (memory efficient)
  late AppDatabase _db;
  
  // Text controllers for form fields (initialized once in initState)
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _fullNameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  
  // Editing state
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Scroll controller and key for auto-scrolling to password section
  final ScrollController _scrollController = ScrollController();
  final ScrollController _desktopScrollController = ScrollController();
  final GlobalKey _passwordFieldsKey = GlobalKey();

  // Snackbar deduplication
  String? _lastSnackBarMessage;

  // Store original values for cancel operation
  late String _originalUsername;
  late String _originalEmail;
  late String _originalPhone;
  late String _originalFullName;

  @override
  void initState() {
    super.initState();
    // Reuse existing database instance from AppGlobals
    _db = database;

    // Initialize controllers with current user data
    _originalUsername = widget.userData.username;
    _originalEmail = widget.userData.email;
    _originalPhone = widget.userData.phone ?? '';
    _originalFullName = widget.userData.fullName ?? '';

    _usernameController = TextEditingController(text: _originalUsername);
    _emailController = TextEditingController(text: _originalEmail);
    _phoneController = TextEditingController(text: _originalPhone);
    _fullNameController = TextEditingController(text: _originalFullName);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    _desktopScrollController.dispose();
    super.dispose();
  }

  /// Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Cancel editing - restore original values
        _usernameController.text = _originalUsername;
        _emailController.text = _originalEmail;
        _phoneController.text = _originalPhone;
        _fullNameController.text = _originalFullName;
      }
      _isEditing = !_isEditing;
    });
  }

  /// Toggle password change mode
  void _togglePasswordChange() {
    setState(() {
      if (_isChangingPassword) {
        // Cancel password change - clear fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
      _isChangingPassword = !_isChangingPassword;
    });

    // Auto-scroll to password fields when opening
    if (_isChangingPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final keyContext = _passwordFieldsKey.currentContext;
        if (keyContext != null) {
          Scrollable.ensureVisible(
            keyContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.0,
          );
        }
      });
    }
  }

  /// Save account changes to database
  Future<void> _saveChanges() async {
    // Validate inputs
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty', isError: true);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Email cannot be empty', isError: true);
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showSnackBar('Please enter a valid email', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get current user from database
      final currentUser = await _db.usersDao.getUserById(widget.userData.id);
      
      if (currentUser == null) {
        _showSnackBar('User not found', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Check if username is being changed and if it already exists
      if (_usernameController.text.trim() != currentUser.username) {
        final existingUser = await _db.usersDao.getUserByUsername(_usernameController.text.trim());
        if (existingUser != null && existingUser.id != widget.userData.id) {
          _showSnackBar('Username already exists. Please choose a different one.', isError: true);
          setState(() => _isSaving = false);
          return;
        }
      }

      // Check if email is being changed and if it already exists
      final emailChanged = _emailController.text.trim() != currentUser.email;
      if (emailChanged) {
        final existingUser = await _db.usersDao.getUserByEmail(_emailController.text.trim());
        if (existingUser != null && existingUser.id != widget.userData.id) {
          _showSnackBar('Email already exists. Please choose a different one.', isError: true);
          setState(() => _isSaving = false);
          return;
        }
        
        // UPDATE SUPABASE AUTH EMAIL USING EDGE FUNCTION (bypasses validation restrictions)
        // This must succeed or we abort the entire operation to prevent lockouts
        try {
          final supabaseUser = Supabase.instance.client.auth.currentUser;
          
          if (supabaseUser == null) {
            _showSnackBar(
              'Cannot change email: Not logged in to Supabase. Please restart the app and try again.',
              isError: true,
            );
            setState(() => _isSaving = false);
            return;
          }
          
          // Use Edge Function to update email (bypasses "admin@" restrictions)
          debugPrint('🔄 Updating Supabase Auth email via Edge Function...');
          final result = await authService.updateAuthUserEmail(
            supabaseUser.id,
            _emailController.text.trim(),
          );
          
          if (result['success'] == true) {
            debugPrint('✅ Supabase Auth email updated to: ${result['email']}');
          } else {
            // CRITICAL: Do NOT update local DB if Supabase Auth fails
            final errorMsg = result['error'] ?? 'Unknown error';
            debugPrint('❌ Supabase Auth update failed: $errorMsg');
            
            String userMessage = 'Failed to update login email. ';
            if (errorMsg.contains('Email already registered')) {
              userMessage += 'This email is already registered in the system.';
            } else if (errorMsg.contains('network') || errorMsg.contains('connection')) {
              userMessage += 'Network connection error. Please check your internet and try again.';
            } else if (errorMsg.contains('Edge Function')) {
              userMessage += 'Server function not deployed. Please contact support.';
            } else {
              userMessage += 'Error: $errorMsg';
            }
            
            _showSnackBar(userMessage, isError: true);
            setState(() => _isSaving = false);
            return; // ABORT - do not update local DB
          }
        } catch (e) {
          // Unexpected error
          debugPrint('❌ Unexpected error updating Supabase Auth: $e');
          _showSnackBar(
            'An unexpected error occurred while updating your email. Please try again.',
            isError: true,
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      // Create updated user object with current timestamp
      final updatedUser = currentUser.copyWith(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: Value(_phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim()),
        fullName: Value(_fullNameController.text.trim().isEmpty 
            ? null 
            : _fullNameController.text.trim()),
        lastUpdated: DateTime.now(),
        isSynced: false,
      );

      // Update in database using existing DAO method
      final success = await _db.usersDao.updateUser(updatedUser);

      if (!success) {
        _showSnackBar('Failed to update account. Please try again.', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // CRITICAL: Verify the update by re-querying the database
      final verifiedUser = await _db.usersDao.getUserById(widget.userData.id);
      
      if (verifiedUser == null) {
        _showSnackBar('Update verification failed. Changes may not have been saved.', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Verify each field was actually updated
      if (verifiedUser.username != _usernameController.text.trim() ||
          verifiedUser.email != _emailController.text.trim() ||
          verifiedUser.phone != (_phoneController.text.trim().isEmpty ? null : _phoneController.text.trim()) ||
          verifiedUser.fullName != (_fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim())) {
        _showSnackBar(
          'Database update incomplete. Your changes may not have been saved. Please try again.',
          isError: true,
        );
        // Restore original values
        _usernameController.text = _originalUsername;
        _emailController.text = _originalEmail;
        _phoneController.text = _originalPhone;
        _fullNameController.text = _originalFullName;
        setState(() => _isSaving = false);
        return;
      }

      // SUCCESS: Database confirmed updated
      _originalUsername = verifiedUser.username;
      _originalEmail = verifiedUser.email;
      _originalPhone = verifiedUser.phone ?? '';
      _originalFullName = verifiedUser.fullName ?? '';

      // IMPORTANT: Reload user profile in auth service so changes reflect throughout app
      await _reloadUserProfile();

      // Immediately sync all changes to Supabase users table
      await _upsertSupabaseUsersTable();

      _showSnackBar('✓ Account updated successfully. Changes will reflect throughout the app.');
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      
      // Trigger sync to update cloud
      _triggerBackgroundSync();
      
    } on Exception catch (e) {
      // Handle specific database errors
      String errorMsg = 'Error: $e';
      if (e.toString().contains('UNIQUE constraint')) {
        if (e.toString().contains('username')) {
          errorMsg = 'Username already exists. Please choose a different one.';
        } else if (e.toString().contains('email')) {
          errorMsg = 'Email already exists. Please choose a different one.';
        } else {
          errorMsg = 'This value already exists. Please use a different one.';
        }
      } else if (e.toString().contains('network') || e.toString().contains('internet')) {
        errorMsg = 'Network error. Changes not saved. Please check your connection and try again.';
      }
      
      _showSnackBar(errorMsg, isError: true);
      setState(() => _isSaving = false);
    } catch (e) {
      _showSnackBar('Unexpected error: $e', isError: true);
      setState(() => _isSaving = false);
    }
  }

  /// Change password
  Future<void> _changePassword() async {
    // Validate password fields
    if (_currentPasswordController.text.isEmpty) {
      _showSnackBar('Please enter your current password', isError: true);
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Please enter a new password', isError: true);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      _showSnackBar('New password must be different from current password', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get current user from database
      final currentUser = await _db.usersDao.getUserById(widget.userData.id);
      
      if (currentUser == null) {
        _showSnackBar('User not found', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Verify current password using proper salt-aware comparison
      if (!verifyPassword(_currentPasswordController.text, currentUser.password)) {
        _showSnackBar('Current password is incorrect', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // Update Supabase Auth password first (used for online login)
      final authResult = await authService.updatePassword(_newPasswordController.text);
      
      if (!authResult.success) {
        _showSnackBar('Failed to update password: ${authResult.message}', isError: true);
        setState(() => _isSaving = false);
        return;
      }

      // SUCCESS: Both Supabase Auth and local DB updated by authService.updatePassword
      // Also update Supabase users table immediately
      await _upsertSupabaseUsersTable();

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSnackBar('✓ Password changed successfully. Use your new password on next login.');
      setState(() {
        _isChangingPassword = false;
        _isSaving = false;
      });
      
      // Trigger sync
      _triggerBackgroundSync();
      
    } on Exception catch (e) {
      String errorMsg = 'Error: $e';
      if (e.toString().contains('network') || e.toString().contains('internet')) {
        errorMsg = 'Network error. Password not changed. Please check your connection and try again.';
      }
      
      _showSnackBar(errorMsg, isError: true);
      setState(() => _isSaving = false);
    } catch (e) {
      _showSnackBar('Unexpected error: $e', isError: true);
      setState(() => _isSaving = false);
    }
  }

  /// Update the current user's data in the Supabase users table.
  /// Uses UPDATE (not upsert) to work with RLS self-link and star policies.
  Future<void> _upsertSupabaseUsersTable() async {
    try {
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser == null) {
        debugPrint('⚠️ Users table sync: No authenticated Supabase user');
        return;
      }

      final localUser = await _db.usersDao.getUserById(widget.userData.id);
      if (localUser == null) {
        debugPrint('⚠️ Users table sync: Local user ${widget.userData.id} not found');
        return;
      }

      final role = await _db.rolesDao.getRoleById(widget.userData.roleId);
      final roleCloudId = role?.cloudId;
      final orgCloudId = widget.userData.organizationCloudId;
      final userCloudId = widget.userData.cloudId ?? supabaseUser.id;
      final now = DateTime.now().toUtc().toIso8601String();

      debugPrint('📤 Supabase users table update:');
      debugPrint('   cloud_id=$userCloudId');
      debugPrint('   auth.uid=${supabaseUser.id}');
      debugPrint('   auth.email=${supabaseUser.email}');
      debugPrint('   local email=${localUser.email}');
      debugPrint('   username=${localUser.username}');
      debugPrint('   org_cloud_id=$orgCloudId');
      debugPrint('   role_cloud_id=$roleCloudId');

      if (orgCloudId == null) {
        debugPrint('⚠️ Users table sync: organization cloud_id is null, aborting');
        return;
      }
      if (roleCloudId == null) {
        debugPrint('⚠️ Users table sync: role cloud_id is null, aborting');
        return;
      }

      final updateData = {
        'auth_user_id': supabaseUser.id,
        'email': localUser.email,
        'username': localUser.username,
        'password': localUser.password,
        'phone': localUser.phone,
        'full_name': localUser.fullName,
        'organization_id': orgCloudId,
        'role_id': roleCloudId,
        'is_active': localUser.isActive,
        'last_updated': now,
      };

      // Primary: update by auth_user_id (most reliable — links local to cloud)
      // Local cloud_id may differ from Supabase cloud_id, but auth_user_id
      // always matches supabaseUser.id
      final result = await Supabase.instance.client
          .from('users')
          .update(updateData)
          .eq('auth_user_id', supabaseUser.id)
          .select();

      if (result.isNotEmpty) {
        debugPrint('✅ Supabase users table updated (by auth_user_id)');
        // Sync the real cloud_id back to local DB if they differ
        final realCloudId = result.first['cloud_id'] as String?;
        if (realCloudId != null && realCloudId != userCloudId) {
          debugPrint('   Fixing local cloud_id: $userCloudId → $realCloudId');
          await (_db.update(_db.users)
                ..where((t) => t.id.equals(widget.userData.id)))
              .write(UsersCompanion(cloudId: Value(realCloudId)));
        }
        return;
      }

      // Fallback: update by email match (self-link policy)
      debugPrint('   auth_user_id update matched 0 rows, trying email match...');
      final emailResult = await Supabase.instance.client
          .from('users')
          .update(updateData)
          .eq('email', supabaseUser.email ?? '')
          .select();

      if (emailResult.isNotEmpty) {
        debugPrint('✅ Supabase users table updated (by email)');
        final realCloudId = emailResult.first['cloud_id'] as String?;
        if (realCloudId != null && realCloudId != userCloudId) {
          debugPrint('   Fixing local cloud_id: $userCloudId → $realCloudId');
          await (_db.update(_db.users)
                ..where((t) => t.id.equals(widget.userData.id)))
              .write(UsersCompanion(cloudId: Value(realCloudId)));
        }
        return;
      }

      // Both failed
      debugPrint('⚠️ Supabase users table: no row matched auth_user_id or email');
      debugPrint('   auth_user_id=${supabaseUser.id}, email=${supabaseUser.email}');
    } catch (e) {
      debugPrint('⚠️ Supabase users table update failed: $e');
    }
  }

  /// Trigger background sync (non-blocking)
  void _triggerBackgroundSync() {
    // Don't await - let it sync in background
    syncService.syncAll().catchError((e) {
      // Silent fail - sync will retry later
      debugPrint('Background sync failed: $e');
    });
  }

  /// Reload user profile so changes reflect throughout the app
  Future<void> _reloadUserProfile() async {
    try {
      // Use the auth service's reload method to refresh the cached user
      final success = await authService.reloadCurrentUser();
      if (success) {
        debugPrint('✅ User profile reloaded successfully');
      } else {
        debugPrint('⚠️ User profile reload failed');
      }
    } catch (e) {
      debugPrint('⚠️ Error reloading user profile: $e');
    }
  }

  /// Show snackbar message (reusable helper)
  /// Only shows one at a time; suppresses duplicate messages within duration.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    // Suppress duplicate messages — only allow if message changed
    if (message == _lastSnackBarMessage) return;
    _lastSnackBarMessage = message;

    // Clear any existing snackbar before showing new one
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reset dedup after snackbar duration expires
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastSnackBarMessage == message) {
        _lastSnackBarMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout: mobile vs desktop
    if (AppLayout.isDesktop(context) == false) {
      return _buildMobileLayout();
    }
    return _buildDesktopLayout();
  }

  /// Mobile layout for small screens
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      appBar: AppBar(
        title: const Text('Edit Account', style: TextStyle(fontFamily: fontAll)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Role and Organization Info (read-only)
              _buildInfoCard(
                title: 'Role',
                value: widget.userData.roleName,
                icon: Icons.badge,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                title: 'Organization',
                value: widget.userData.organizationName,
                icon: Icons.business,
              ),
              const SizedBox(height: 24),

              // Editable Fields
              _buildEditableField(
                label: 'Username',
                controller: _usernameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Full Name',
                controller: _fullNameController,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Phone',
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                maxLength: 15,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (_isEditing)
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _toggleEditMode,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              
              // Password Change Section
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontAll,
                    ),
                  ),
                  if (!_isChangingPassword)
                    TextButton.icon(
                      onPressed: _togglePasswordChange,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Change Password'),
                    ),
                ],
              ),
              
              if (_isChangingPassword) ...[
                const SizedBox(height: 16),
                _buildPasswordField(
                  key: _passwordFieldsKey,
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  onToggleObscure: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  onToggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _changePassword,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_isSaving ? 'Saving...' : 'Update Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _togglePasswordChange,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Desktop layout for large screens
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Account Details
            Expanded(
              flex: 2,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    controller: _desktopScrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontAll,
                              ),
                            ),
                            if (_isEditing)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _toggleEditMode,
                                tooltip: 'Cancel',
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Role and Organization (Read-only)
                        _buildDesktopReadOnlySection(),
                        const SizedBox(height: 32),

                        const Divider(),
                        const SizedBox(height: 32),

                        // Editable Fields
                        _buildEditableField(
                          label: 'Username',
                          controller: _usernameController,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 24),
                        _buildEditableField(
                          label: 'Email',
                          controller: _emailController,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        _buildEditableField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 24),
                        _buildEditableField(
                          label: 'Phone',
                          controller: _phoneController,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                        ),
                        const SizedBox(height: 40),

                        // Action Buttons
                        if (_isEditing)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(
                                    _isSaving ? 'Saving...' : 'Save Changes',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isSaving ? null : _toggleEditMode,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _toggleEditMode,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Account'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        
                        // Password Change Section
                        const SizedBox(height: 40),
                        const Divider(),
                        const SizedBox(height: 32),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Security',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontAll,
                              ),
                            ),
                            if (!_isChangingPassword)
                              TextButton.icon(
                                onPressed: _togglePasswordChange,
                                icon: const Icon(Icons.lock_outline),
                                label: const Text('Change Password'),
                              ),
                          ],
                        ),
                        
                        if (_isChangingPassword) ...[                          const SizedBox(height: 24),
                          _buildPasswordField(
                            key: _passwordFieldsKey,
                            label: 'Current Password',
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrentPassword,
                            onToggleObscure: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            onToggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _changePassword,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check),
                                  label: Text(_isSaving ? 'Saving...' : 'Update Password'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isSaving ? null : _togglePasswordChange,
                                  icon: const Icon(Icons.close),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            
            // Right Panel - Placeholder for future features
            Expanded(
              flex: 1,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontAll,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatItem(
                        icon: Icons.badge,
                        label: 'Role',
                        value: widget.userData.roleName,
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem(
                        icon: Icons.business,
                        label: 'Organization',
                        value: widget.userData.organizationName,
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem(
                        icon: Icons.account_tree,
                        label: 'Type',
                        value: widget.userData.organizationType.toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build read-only info card (mobile)
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: fontAll,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build editable field (reusable for both mobile and desktop)
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontAll,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: !_isEditing,
          enabled: _isEditing,
          keyboardType: keyboardType,
          maxLength: maxLength,
          autocorrect: false,
          enableSuggestions: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
            prefixIcon: Icon(icon, color: Colors.blue),
            suffixIcon: _isEditing 
                ? Icon(Icons.edit, color: Colors.blue.shade300, size: 18)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isEditing ? Colors.blue.shade200 : Colors.grey.shade300,
                width: _isEditing ? 1.5 : 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Build read-only section for desktop layout
  Widget _buildDesktopReadOnlySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Organization Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: fontAll,
          ),
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField('Role', widget.userData.roleName, Icons.badge),
        const SizedBox(height: 16),
        _buildReadOnlyField('Organization', widget.userData.organizationName,
            Icons.business),
        const SizedBox(height: 16),
        _buildReadOnlyField('Type',
            widget.userData.organizationType.toUpperCase(), Icons.account_tree),
      ],
    );
  }

  /// Build read-only field for desktop
  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: fontAll,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: fontAll,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build stat item for desktop right panel
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: fontAll,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontAll,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build password field with show/hide toggle
  Widget _buildPasswordField({
    Key? key,
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontAll,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock, color: Colors.blue),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggleObscure,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
