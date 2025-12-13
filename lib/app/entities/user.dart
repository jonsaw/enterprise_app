import 'package:api_management/api_management.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Represents a user entity.
@freezed
abstract class User with _$User {
  /// Creates a [User] instance.
  const factory User({
    required String id,
    required String name,
    required String email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  const User._();

  /// Creates a [User] from GraphQL list data.
  factory User.fromGListMyCompanyUsersData(
    GListMyCompanyUsersData_listMyCompanyUsersPaginated_items_user u,
  ) {
    return User(
      id: u.id.value,
      name: u.name,
      email: u.email,
      createdAt: DateTime.tryParse(u.createdAt.value),
      updatedAt: DateTime.tryParse(u.updatedAt.value),
    );
  }

  /// Creates a [User] from GraphQL detail data.
  factory User.fromGGetMyCompanyUserData(
    GGetMyCompanyUserData_getMyCompanyUser_user u,
  ) {
    return User(
      id: u.id.value,
      name: u.name,
      email: u.email,
      createdAt: DateTime.tryParse(u.createdAt.value),
      updatedAt: DateTime.tryParse(u.updatedAt.value),
    );
  }
}
