import 'package:enterprise/app/entities/user_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';

/// Represents an authenticated user with their role information.
///
/// This entity stores the essential user data returned from the authentication
/// API along with the derived user role for access control.
@freezed
abstract class Auth with _$Auth {
  /// Creates an [Auth] instance.
  const factory Auth({
    required String userId,
    required String name,
    required String email,
    required UserRole role,
  }) = _Auth;

  const Auth._();
}
