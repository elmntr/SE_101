// lib/services/supabase_auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import '../database/app_database.dart';

/// Result type for authentication operations
class AuthResult {
  final bool success;
  final String? message;
  final supabase.User? user;
  final UserData? localUser;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
    this.localUser,
  });

  factory AuthResult.success({supabase.User? user, UserData? localUser, String? message}) {
    return AuthResult(
      success: true,
      user: user,
      localUser: localUser,
      message: message,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

/// Local user data with role and organization info
class UserData {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? phone;
  final int organizationId;
  final String? organizationCloudId;
  final String organizationType;
  final String organizationName;
  final int roleId;
  final String roleName;
  final RolePermissions permissions;
  final String? cloudId;
  final String? authUserId;

  const UserData({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    required this.organizationId,
    this.organizationCloudId,
    required this.organizationType,
    required this.organizationName,
    required this.roleId,
    required this.roleName,
    required this.permissions,
    this.cloudId,
    this.authUserId,
  });

  bool get isCommissary => organizationType == 'commissary';
  bool get isFranchisee => organizationType == 'franchisee';
}

/// Role permissions for easy access
class RolePermissions {
  final bool canViewInventory;
  final bool canAddInventory;
  final bool canEditInventory;
  final bool canDeleteInventory;
  final bool canViewReports;
  final bool canExportData;
  final bool canAccessSettings;
  final bool canManageEmployees;
  final bool canManageRoles;

  const RolePermissions({
    this.canViewInventory = false,
    this.canAddInventory = false,
    this.canEditInventory = false,
    this.canDeleteInventory = false,
    this.canViewReports = false,
    this.canExportData = false,
    this.canAccessSettings = false,
    this.canManageEmployees = false,
    this.canManageRoles = false,
  });

  factory RolePermissions.fromRole(Role role) {
    return RolePermissions(
      canViewInventory: role.canViewInventory,
      canAddInventory: role.canAddInventory,
      canEditInventory: role.canEditInventory,
      canDeleteInventory: role.canDeleteInventory,
      canViewReports: role.canViewReports,
      canExportData: role.canExportData,
      canAccessSettings: role.canAccessSettings,
      canManageEmployees: role.canManageEmployees,
      canManageRoles: role.canManageRoles,
    );
  }
}

/// Supabase Auth Service with Star Topology Support
///
/// Features:
/// - Email/Password authentication via Supabase Auth
/// - Links Supabase Auth users to local users table
/// - Maintains session state
/// - Handles organization context for RLS
class SupabaseAuthService {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  // Current session state
  UserData? _currentUser;
  StreamController<UserData?>? _authStateController;

  SupabaseAuthService({
    required SupabaseClient supabase,
    required AppDatabase database,
  })  : _supabase = supabase,
        _db = database {
    _authStateController = StreamController<UserData?>.broadcast();
    _initAuthListener();
  }

  // Getters
  UserData? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isCommissary => _currentUser?.isCommissary ?? false;
  bool get isFranchisee => _currentUser?.isFranchisee ?? false;
  Stream<UserData?> get authStateChanges => _authStateController!.stream;
  supabase.User? get supabaseUser => _supabase.auth.currentUser;

  /// Initialize auth state listener
  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (kDebugMode) {
        print('🔐 Auth state changed: $event');
      }

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _loadCurrentUser(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _authStateController?.add(null);
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        // Session refreshed, user data should still be valid
        if (_currentUser == null) {
          await _loadCurrentUser(session.user);
        }
      }
    });
  }

  /// Load current user data from local database
  Future<void> _loadCurrentUser(supabase.User authUser) async {
    try {
      // Find local user by auth_user_id or email
      final localUser = await _findLocalUser(authUser);
      
      if (localUser != null) {
        _currentUser = localUser;
        _authStateController?.add(localUser);
        
        if (kDebugMode) {
          print('✅ User loaded: ${localUser.username} (${localUser.organizationType})');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No local user found for auth user: ${authUser.email}');
        }
        _currentUser = null;
        _authStateController?.add(null);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user: $e');
      }
      _currentUser = null;
      _authStateController?.add(null);
    }
  }

  /// Find local user by Supabase auth user
  Future<UserData?> _findLocalUser(supabase.User authUser) async {
    try {
      // First try by auth_user_id if linked
      // Then fallback to email match
      final users = await _db.usersDao.getAllUsers();
      
      for (final user in users) {
        if (!user.isActive) continue;
        
        // Match by email (case insensitive)
        if (user.email.toLowerCase() == authUser.email?.toLowerCase()) {
          // Load organization and role
          final org = await _db.organizationsDao.getOrganizationById(user.organizationId);
          final role = await _db.rolesDao.getRoleById(user.roleId);
          
          if (org == null || role == null) continue;
          
          return UserData(
            id: user.id,
            username: user.username,
            email: user.email,
            fullName: user.fullName,
            phone: user.phone,
            organizationId: user.organizationId,
            organizationCloudId: org.cloudId,
            organizationType: org.type,
            organizationName: org.name,
            roleId: user.roleId,
            roleName: role.name,
            permissions: RolePermissions.fromRole(role),
            cloudId: user.cloudId,
            authUserId: authUser.id,
          );
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding local user: $e');
      }
      return null;
    }
  }

  /// Sign up a new user
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required int organizationId,
    required int roleId,
    String? phone,
  }) async {
    try {
      // 1. Check if email already exists locally
      final existingUser = await _db.usersDao.getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.failure('Email already registered');
      }

      // 2. Check if username already exists
      final existingUsername = await _db.usersDao.getUserByUsername(username);
      if (existingUsername != null) {
        return AuthResult.failure('Username already taken');
      }

      // 3. Sign up with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
        },
      );

      if (authResponse.user == null) {
        return AuthResult.failure('Failed to create account');
      }

      // 4. Create local user record
      final userId = await _db.usersDao.insertUser(
        UsersCompanion.insert(
          email: email,
          username: username,
          password: _hashPassword(password), // Store hashed password for offline login
          fullName: Value(fullName),
          phone: Value(phone),
          organizationId: organizationId,
          roleId: roleId,
        ),
      );

      // 5. Link Supabase auth user ID to local user
      // This will be synced to cloud and used for RLS
      await _linkAuthUserToLocal(userId, authResponse.user!.id);

      // 6. Load user data
      await _loadCurrentUser(authResponse.user!);

      return AuthResult.success(
        user: authResponse.user,
        localUser: _currentUser,
        message: 'Account created successfully',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Try Supabase Auth first (for online mode)
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return AuthResult.failure('Invalid credentials');
      }

      // 2. Load local user data
      await _loadCurrentUser(authResponse.user!);

      if (_currentUser == null) {
        // User authenticated but no local record found
        // This might happen if user was created in Supabase but not synced locally
        return AuthResult.failure('User not found in local database. Please sync first.');
      }

      return AuthResult.success(
        user: authResponse.user,
        localUser: _currentUser,
        message: 'Signed in successfully',
      );
    } on AuthException catch (e) {
      // If network fails, try offline login
      if (e.message.contains('network') || e.message.contains('connection')) {
        return _offlineSignIn(email, password);
      }
      return AuthResult.failure(e.message);
    } catch (e) {
      // Try offline login on any error
      return _offlineSignIn(email, password);
    }
  }

  /// Offline sign in using local database
  Future<AuthResult> _offlineSignIn(String email, String password) async {
    try {
      final user = await _db.usersDao.getUserByEmail(email);
      
      if (user == null || !user.isActive) {
        return AuthResult.failure('Invalid credentials');
      }

      // Verify password hash
      if (!_verifyPassword(password, user.password)) {
        return AuthResult.failure('Invalid credentials');
      }

      // Load organization and role
      final org = await _db.organizationsDao.getOrganizationById(user.organizationId);
      final role = await _db.rolesDao.getRoleById(user.roleId);

      if (org == null || role == null) {
        return AuthResult.failure('User configuration error');
      }

      _currentUser = UserData(
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        organizationId: user.organizationId,
        organizationCloudId: org.cloudId,
        organizationType: org.type,
        organizationName: org.name,
        roleId: user.roleId,
        roleName: role.name,
        permissions: RolePermissions.fromRole(role),
        cloudId: user.cloudId,
      );

      _authStateController?.add(_currentUser);

      return AuthResult.success(
        localUser: _currentUser,
        message: 'Signed in offline',
      );
    } catch (e) {
      return AuthResult.failure('Offline sign in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error signing out from Supabase: $e');
      }
    }
    
    _currentUser = null;
    _authStateController?.add(null);
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return AuthResult.success(message: 'Password reset email sent');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Password reset failed: $e');
    }
  }

  /// Update password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Also update local password hash
      if (_currentUser != null) {
        await _db.usersDao.updateUserPassword(
          _currentUser!.id,
          _hashPassword(newPassword),
        );
      }

      return AuthResult.success(message: 'Password updated');
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Password update failed: $e');
    }
  }

  /// Link Supabase auth user to local user
  Future<void> _linkAuthUserToLocal(int localUserId, String authUserId) async {
    try {
      // Update local user with auth_user_id
      // This needs a corresponding method in UsersDao
      await _db.customStatement(
        'UPDATE users SET cloud_id = ? WHERE id = ?',
        [authUserId, localUserId],
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to link auth user: $e');
      }
    }
  }

  /// Generate a cryptographically secure random salt
  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hash password using PBKDF2 with per-user random salt
  /// Returns format: "salt$hash" where salt is 32-char hex, hash is 64-char hex
  String _hashPassword(String password) {
    final salt = _generateSalt();
    return _hashPasswordWithSalt(password, salt);
  }

  /// Hash password with a specific salt (used for verification)
  String _hashPasswordWithSalt(String password, String salt) {
    const int iterations = 100000; // Work factor
    const int keyLength = 32; // 32 bytes = 256-bit derived key

    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = utf8.encode(salt);

    // PBKDF2 block 1
    List<int> int32ToBytes(int i) {
      return <int>[
        (i >> 24) & 0xff,
        (i >> 16) & 0xff,
        (i >> 8) & 0xff,
        i & 0xff,
      ];
    }

    final blockIndexBytes = int32ToBytes(1);
    var u = hmac.convert([...saltBytes, ...blockIndexBytes]).bytes;
    final List<int> derivedBlock = List<int>.from(u);

    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < derivedBlock.length; j++) {
        derivedBlock[j] ^= u[j];
      }
    }

    final dk = derivedBlock.sublist(0, keyLength);
    final hashHex = dk.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '$salt\$$hashHex'; // Format: salt$hash
  }

  /// Verify a password against a stored hash
  /// Handles format: "salt$hash"
  bool _verifyPassword(String password, String storedHash) {
    final parts = storedHash.split('\$');
    if (parts.length != 2) {
      if (kDebugMode) {
        print('⚠️ Invalid hash format (expected salt\$hash)');
      }
      return false;
    }

    final salt = parts[0];
    final expectedFullHash = _hashPasswordWithSalt(password, salt);

    // Constant-time comparison to prevent timing attacks
    if (storedHash.length != expectedFullHash.length) return false;
    
    int result = 0;
    for (int i = 0; i < storedHash.length; i++) {
      result |= storedHash.codeUnitAt(i) ^ expectedFullHash.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;
    
    // Check if token is expired
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isBefore(expiryDate);
  }

  /// Restore session on app start
  Future<AuthResult> restoreSession() async {
    try {
      final session = _supabase.auth.currentSession;
      
      if (session != null && await isSessionValid()) {
        await _loadCurrentUser(session.user);
        
        if (_currentUser != null) {
          return AuthResult.success(
            user: session.user,
            localUser: _currentUser,
          );
        }
      }
      
      // No valid session, check for offline user
      // Could restore last logged in user from SharedPreferences
      return AuthResult.failure('No active session');
    } catch (e) {
      return AuthResult.failure('Session restore failed: $e');
    }
  }

  /// Get access token for API calls
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  /// Refresh the current session
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to refresh session: $e');
      }
    }
  }

  // ============================================================================
  // BRANCH SELECTION (for Branch/Franchisee App)
  // ============================================================================

  /// Simple branch data for selection dropdown
  static const String branchTypeFranchisee = 'franchisee';

  /// Fetch available branches (franchisees) from Supabase
  /// Returns a list of organization records that are franchisees
  Future<List<Map<String, dynamic>>> fetchAvailableBranches() async {
    try {
      if (kDebugMode) {
        print('📥 Fetching available branches from Supabase...');
      }

      final response = await _supabase
          .from('organizations')
          .select('cloud_id, name, address, phone, email, type, is_active')
          .eq('type', branchTypeFranchisee)
          .eq('is_active', true)
          .order('name');

      if (kDebugMode) {
        print('   Found ${response.length} branches');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching branches: $e');
      }
      return [];
    }
  }

  /// Sign in with email/password for a specific branch
  /// Validates that the user belongs to the selected branch
  Future<AuthResult> signInToBranch({
    required String email,
    required String password,
    required String branchCloudId,
  }) async {
    try {
      if (kDebugMode) {
        print('🔑 Signing in to branch: $branchCloudId');
        print('   Email: $email');
      }

      // 1. Try Supabase Auth first
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        if (kDebugMode) {
          print('❌ Auth failed: No user returned');
        }
        return AuthResult.failure('Invalid credentials');
      }

      if (kDebugMode) {
        print('✅ Auth successful: ${authResponse.user!.id}');
        print('   Auth email: ${authResponse.user!.email}');
      }

      // 2. Fetch user record from Supabase with organization check
      if (kDebugMode) {
        print('📥 Fetching user record...');
        print('   Query: email=$email, organization_id=$branchCloudId, is_active=true');
      }

      final userRecords = await _supabase
          .from('users')
          .select('*, organizations!inner(*), roles!inner(*)')
          .eq('email', email)
          .eq('organization_id', branchCloudId)
          .eq('is_active', true)
          .limit(1);

      if (kDebugMode) {
        print('   Result: ${userRecords.length} records found');
        if (userRecords.isNotEmpty) {
          print('   User: ${userRecords.first}');
        }
      }

      if (userRecords.isEmpty) {
        // Sign out since user doesn't belong to this branch
        await _supabase.auth.signOut();
        if (kDebugMode) {
          print('❌ No user record found for this email in branch $branchCloudId');
        }
        return AuthResult.failure('You do not have access to this branch');
      }

      final userRecord = userRecords.first;
      final orgRecord = userRecord['organizations'] as Map<String, dynamic>;
      final roleRecord = userRecord['roles'] as Map<String, dynamic>;

      // 3. Build UserData from Supabase response
      _currentUser = UserData(
        id: userRecord['local_id'] ?? 0,
        username: userRecord['username'] ?? email.split('@').first,
        email: email,
        fullName: userRecord['full_name'],
        phone: userRecord['phone'],
        organizationId: orgRecord['local_id'] ?? 0,
        organizationCloudId: branchCloudId,
        organizationType: orgRecord['type'] ?? 'franchisee',
        organizationName: orgRecord['name'] ?? 'Unknown Branch',
        roleId: roleRecord['local_id'] ?? 0,
        roleName: roleRecord['name'] ?? 'Employee',
        permissions: RolePermissions(
          canViewInventory: roleRecord['can_view_inventory'] ?? false,
          canAddInventory: roleRecord['can_add_inventory'] ?? false,
          canEditInventory: roleRecord['can_edit_inventory'] ?? false,
          canDeleteInventory: roleRecord['can_delete_inventory'] ?? false,
          canViewReports: roleRecord['can_view_reports'] ?? false,
          canExportData: roleRecord['can_export_data'] ?? false,
          canAccessSettings: roleRecord['can_access_settings'] ?? false,
          canManageEmployees: roleRecord['can_manage_employees'] ?? false,
          canManageRoles: roleRecord['can_manage_roles'] ?? false,
        ),
        cloudId: userRecord['cloud_id'],
        authUserId: authResponse.user!.id,
      );

      _authStateController?.add(_currentUser);

      return AuthResult.success(
        user: authResponse.user,
        localUser: _currentUser,
        message: 'Signed in to ${_currentUser!.organizationName}',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in to branch error: $e');
      }
      return AuthResult.failure('Sign in failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController?.close();
  }
}
