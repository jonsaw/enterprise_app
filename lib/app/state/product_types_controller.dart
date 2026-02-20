import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/product_type.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_types_controller.g.dart';

/// Paginated product types result.
class PaginatedProductTypes {
  /// Creates a [PaginatedProductTypes].
  const PaginatedProductTypes({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an empty result.
  factory PaginatedProductTypes.empty() {
    return const PaginatedProductTypes(
      items: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// The list of product types.
  final List<ProductType> items;

  /// Total count of types.
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

/// Controller for managing product types list state.
@riverpod
class ProductTypesController extends _$ProductTypesController {
  @override
  Future<PaginatedProductTypes> build(
    String companyId, {
    required int page,
    required int pageSize,
    String? search,
  }) async {
    if (companyId.isEmpty) {
      return PaginatedProductTypes.empty();
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final offset = (page - 1) * pageSize;

      final response = await managementClient
          .request(
            GListProductTypesPaginatedReq(
              (b) => b
                ..vars.input.companyId = companyIdValue
                ..vars.input.limit = pageSize
                ..vars.input.offset = offset
                ..vars.input.search = search
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.linkException != null) {
        talker.error(
          'Network error while fetching product types: ${response.linkException}',
        );
        throw Exception(
          'Network error: ${response.linkException?.originalException ?? response.linkException}',
        );
      }

      if (response.graphqlErrors != null && response.graphqlErrors!.isNotEmpty) {
        final errors = response.graphqlErrors!.map((e) => e.message).join(', ');
        talker.error(
          'GraphQL errors while fetching product types: $errors',
        );
        throw Exception('Failed to fetch product types: $errors');
      }

      final data = response.data?.listProductTypesPaginated;

      if (data == null) {
        talker.error(
          'No data returned from listProductTypesPaginated query',
        );
        throw Exception('No data returned from server');
      }

      final items = data.items.map(ProductType.fromGraphQL).toList();

      return PaginatedProductTypes(
        items: items,
        totalCount: data.pageInfo?.totalCount ?? 0,
        currentPage: data.pageInfo?.currentPage ?? 1,
        totalPages: data.pageInfo?.totalPages ?? 0,
        hasNextPage: data.pageInfo?.hasNextPage ?? false,
        hasPreviousPage: data.pageInfo?.hasPreviousPage ?? false,
      );
    } on Exception catch (e) {
      talker.error('Failed to fetch product types', e);
      rethrow;
    }
  }
}
