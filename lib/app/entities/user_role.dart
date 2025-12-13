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
      case UserMember():
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
final class UserMember extends UserRole {
  /// Creates a [UserMember] role.
  const UserMember();
}

/// None role - represents unauthenticated state
final class None extends UserRole {
  /// Creates a [None] role.
  const None();
}
