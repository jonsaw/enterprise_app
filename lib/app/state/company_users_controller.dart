import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_users_controller.g.dart';

/// Paginated company users result.
class PaginatedCompanyUsers {
  /// Creates a [PaginatedCompanyUsers].
  const PaginatedCompanyUsers({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an empty result.
  factory PaginatedCompanyUsers.empty() {
    return const PaginatedCompanyUsers(
      items: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// The list of company users.
  final List<CompanyUser> items;

  /// Total count of users.
  final int totalCount;

  /// Current page number.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Whether there is a next page.
  final bool hasNextPage;

  /// Whether there is a previous page.
  final bool hasPreviousPage;
}

/// Controller for managing company users list state.
@riverpod
class CompanyUsersController extends _$CompanyUsersController {
  @override
  Future<PaginatedCompanyUsers> build(
    String companyId, {
    required int page,
    required int pageSize,
    String? search,
  }) async {
    if (companyId.isEmpty) {
      return PaginatedCompanyUsers.empty();
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final offset = (page - 1) * pageSize;

      final response = await managementClient
          .request(
            GListMyCompanyUsersReq(
              (b) => b
                ..vars.input.companyId = companyIdValue
                ..vars.input.limit = pageSize
                ..vars.input.offset = offset
                ..vars.input.search = search
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        talker.error(
          'GraphQL errors while fetching company users: ${response.graphqlErrors}',
        );
        throw Exception('Failed to fetch company users');
      }

      final data = response.data?.listMyCompanyUsersPaginated;

      if (data != null) {
        final items = data.items
            .map(CompanyUser.fromGListMyCompanyUsersData)
            .toList();

        return PaginatedCompanyUsers(
          items: items,
          totalCount: data.pageInfo?.totalCount ?? 0,
          currentPage: data.pageInfo?.currentPage ?? 1,
          totalPages: data.pageInfo?.totalPages ?? 0,
          hasNextPage: data.pageInfo?.hasNextPage ?? false,
          hasPreviousPage: data.pageInfo?.hasPreviousPage ?? false,
        );
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch company users', e);
      rethrow;
    }

    return PaginatedCompanyUsers.empty();
  }
}
