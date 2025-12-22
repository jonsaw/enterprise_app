import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company_invite.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_invites_controller.g.dart';

/// Paginated company invites result.
class PaginatedCompanyInvites {
  /// Creates a [PaginatedCompanyInvites].
  const PaginatedCompanyInvites({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an empty result.
  factory PaginatedCompanyInvites.empty() {
    return const PaginatedCompanyInvites(
      items: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// The list of company invites.
  final List<CompanyInvite> items;

  /// Total count of invites.
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

/// Controller for managing company invites list state.
@riverpod
class CompanyInvitesController extends _$CompanyInvitesController {
  @override
  Future<PaginatedCompanyInvites> build(
    String companyId, {
    required int page,
    required int pageSize,
    String? search,
  }) async {
    if (companyId.isEmpty) {
      return PaginatedCompanyInvites.empty();
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final offset = (page - 1) * pageSize;

      final response = await managementClient
          .request(
            GListMyCompanyInvitesPaginatedReq(
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
          'GraphQL errors while fetching company invites: ${response.graphqlErrors}',
        );
        throw Exception('Failed to fetch company invites');
      }

      final data = response.data?.listMyCompanyInvitesPaginated;

      if (data != null) {
        final items = data.items.map(CompanyInvite.fromGraphQL).toList();

        return PaginatedCompanyInvites(
          items: items,
          totalCount: data.pageInfo?.totalCount ?? 0,
          currentPage: data.pageInfo?.currentPage ?? 1,
          totalPages: data.pageInfo?.totalPages ?? 0,
          hasNextPage: data.pageInfo?.hasNextPage ?? false,
          hasPreviousPage: data.pageInfo?.hasPreviousPage ?? false,
        );
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch company invites', e);
      rethrow;
    }

    return PaginatedCompanyInvites.empty();
  }
}
