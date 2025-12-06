// lib/database/models/user_with_role.dart
import '../app_database.dart';

/// Helper class for JOIN queries combining User and Role data
class UserWithRole {
  final User user;
  final Role? role;

  UserWithRole({required this.user, required this.role});

  String get displayName => user.username;
}