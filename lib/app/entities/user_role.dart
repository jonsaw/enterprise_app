import 'package:enterprise/l10n.dart';

/// Sealed class hierarchy for user roles with compile-time
/// exhaustiveness checking.
sealed class UserRole {
  /// Creates a [UserRole].
  const UserRole();

  /// Translates the [UserRole] to a human-readable string.
  String tr(AppLocalizations loc) {
    switch (this) {
      case Owner():
        return loc.owner;
      case Manager():
        return loc.manager;
      case User():
        return loc.user;
      case None():
        return loc.none;
    }
  }
}

/// Owner role - highest privilege level
final class Owner extends UserRole {
  /// Creates an [Owner] role.
  const Owner();
}

/// Manager role - middle tier privilege level
final class Manager extends UserRole {
  /// Creates a [Manager] role.
  const Manager();
}

/// User role - standard access level
final class User extends UserRole {
  /// Creates a [User] role.
  const User();
}

/// None role - represents unauthenticated state
final class None extends UserRole {
  /// Creates a [None] role.
  const None();
}

/// Extension for deriving user role from userId or email patterns.
///
/// Since the GraphQL API doesn't return role information, we derive it
/// from userId/email patterns. This is a simple implementation that can
/// be replaced with JWT claims or a separate API query in production.
extension UserRoleFromString on String {
  /// Derives [UserRole] from userId or email string.
  ///
  /// Examples:
  /// - "owner@company.com" → [Owner]
  /// - "owner-123" → [Owner]
  /// - "manager@company.com" → [Manager]
  /// - "manager-456" → [Manager]
  /// - "user@company.com" → [User]
  /// - "user-789" → [User]
  /// - Default → [User]
  UserRole toUserRole() {
    final lowerCase = toLowerCase();

    if (lowerCase.contains('owner') || lowerCase.startsWith('owner-')) {
      return const Owner();
    } else if (lowerCase.contains('manager') ||
        lowerCase.startsWith('manager-')) {
      return const Manager();
    } else if (lowerCase.contains('user') || lowerCase.startsWith('user-')) {
      return const User();
    }

    // Default to User role for any unrecognized pattern
    return const User();
  }
}
