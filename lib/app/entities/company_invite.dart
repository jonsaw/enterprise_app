import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app/entities/user.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_invite.freezed.dart';

/// Represents a company invite entity.
@freezed
abstract class CompanyInvite with _$CompanyInvite {
  /// Creates a [CompanyInvite] instance.
  const factory CompanyInvite({
    required String id,
    required String name,
    required String email,
    required UserRole role,
    required String companyId,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    DateTime? tokenExpiresAt,
    String? createdById,
    User? createdBy,
  }) = _CompanyInvite;

  const CompanyInvite._();

  /// Creates a [CompanyInvite] from GraphQL list data.
  factory CompanyInvite.fromGraphQL(
    GListMyCompanyInvitesPaginatedData_listMyCompanyInvitesPaginated_items data,
  ) {
    return CompanyInvite(
      id: data.id.value,
      name: data.name,
      email: data.email,
      role: fromUserRole(data.role),
      companyId: data.companyId.value,
      createdAt: DateTime.tryParse(data.createdAt.value),
      updatedAt: DateTime.tryParse(data.updatedAt.value),
      readAt: DateTime.tryParse(data.readAt.value),
      tokenExpiresAt: data.tokenExpiresAt?.value != null
          ? DateTime.tryParse(data.tokenExpiresAt!.value)
          : null,
      createdById: data.createdById.value,
      createdBy: data.createdBy != null
          ? User(
              id: data.createdBy!.id.value,
              name: data.createdBy!.name,
              email: data.createdBy!.email,
            )
          : null,
    );
  }

  /// Creates a [CompanyInvite] from GetMyCompanyInvite GraphQL query data.
  factory CompanyInvite.fromGGetMyCompanyInviteData(
    GGetMyCompanyInviteData_getMyCompanyInvite data,
  ) {
    return CompanyInvite(
      id: data.id.value,
      name: data.name,
      email: data.email,
      role: fromUserRole(data.role),
      companyId: data.companyId.value,
      token: data.token,
      createdAt: DateTime.tryParse(data.createdAt.value),
      updatedAt: DateTime.tryParse(data.updatedAt.value),
      readAt: DateTime.tryParse(data.readAt.value),
      tokenExpiresAt: data.tokenExpiresAt?.value != null
          ? DateTime.tryParse(data.tokenExpiresAt!.value)
          : null,
      createdById: data.createdById.value,
      createdBy: data.createdBy != null
          ? User(
              id: data.createdBy!.id.value,
              name: data.createdBy!.name,
              email: data.createdBy!.email,
            )
          : null,
    );
  }
}
