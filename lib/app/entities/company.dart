import 'package:api_management/api_management.dart';
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

/// Represents a user associated with a company.
@freezed
abstract class CompanyUser with _$CompanyUser {
  /// Creates a [CompanyUser] instance.
  const factory CompanyUser({
    required String id,
    required Company? company,
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
    );
  }
}
