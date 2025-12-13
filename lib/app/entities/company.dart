import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/user.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'company.freezed.dart';

/// Represents a company entity.
@freezed
abstract class Company with _$Company {
  /// Creates a [Company] instance.
  const factory Company({
    required String id,
    required String name,
    required String code,
  }) = _Company;

  const Company._();

  /// Creates a [Company] from GraphQL data.
  factory Company.fromGListMyCompaniesData(
    GListMyCompaniesData_listMyCompanies_company c,
  ) {
    return Company(
      id: c.id.value,
      name: c.name,
      code: c.code,
    );
  }
}

/// Converts GraphQL user role to [UserRole].
UserRole fromUserRole(GCompanyUserRole role) {
  switch (role) {
    case GCompanyUserRole.OWNER:
      return const Owner();
    case GCompanyUserRole.MANAGER:
      return const Manager();
    case GCompanyUserRole.USER:
      return const UserMember();
  }
  return const None();
}

/// Represents a user associated with a company.
@freezed
abstract class CompanyUser with _$CompanyUser {
  /// Creates a [CompanyUser] instance.
  const factory CompanyUser({
    required String id,
    required Company? company,
    required UserRole role,
    required User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CompanyUser;

  const CompanyUser._();

  /// Creates a [CompanyUser] from GraphQL data.
  factory CompanyUser.fromGListMyCompaniesData(
    GListMyCompaniesData_listMyCompanies u,
  ) {
    return CompanyUser(
      id: u.id.value,
      company: u.company != null
          ? Company.fromGListMyCompaniesData(u.company!)
          : null,
      role: fromUserRole(u.role),
      user: null,
    );
  }

  /// Creates a [CompanyUser] from GraphQL data.
  factory CompanyUser.fromGGetMyCompanyData(
    GGetMyCompanyData_getMyCompany u,
  ) {
    return CompanyUser(
      id: u.id.value,
      company: u.company != null
          ? Company(
              id: u.company!.id.value,
              name: u.company!.name,
              code: u.company!.code,
            )
          : null,
      role: fromUserRole(u.role),
      user: null,
    );
  }

  /// Creates a [CompanyUser] from list paginated GraphQL data.
  factory CompanyUser.fromGListMyCompanyUsersData(
    GListMyCompanyUsersData_listMyCompanyUsersPaginated_items u,
  ) {
    return CompanyUser(
      id: u.id.value,
      company: u.company != null
          ? Company(
              id: u.company!.id.value,
              name: u.company!.name,
              code: u.company!.code,
            )
          : null,
      role: fromUserRole(u.role),
      user: u.user != null ? User.fromGListMyCompanyUsersData(u.user!) : null,
      createdAt: DateTime.tryParse(u.createdAt.value),
      updatedAt: DateTime.tryParse(u.updatedAt.value),
    );
  }

  /// Creates a [CompanyUser] from detail GraphQL data.
  factory CompanyUser.fromGGetMyCompanyUserData(
    GGetMyCompanyUserData_getMyCompanyUser u,
  ) {
    return CompanyUser(
      id: u.id.value,
      company: u.company != null
          ? Company(
              id: u.company!.id.value,
              name: u.company!.name,
              code: u.company!.code,
            )
          : null,
      role: fromUserRole(u.role),
      user: u.user != null ? User.fromGGetMyCompanyUserData(u.user!) : null,
      createdAt: DateTime.tryParse(u.createdAt.value),
      updatedAt: DateTime.tryParse(u.updatedAt.value),
    );
  }
}
