import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/product_category.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_categories_controller.g.dart';

/// Paginated product categories result.
class PaginatedProductCategories {
  /// Creates a [PaginatedProductCategories].
  const PaginatedProductCategories({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an empty result.
  factory PaginatedProductCategories.empty() {
    return const PaginatedProductCategories(
      items: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// The list of product categories.
  final List<ProductCategory> items;

  /// Total count of categories.
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

/// Controller for managing product categories list state.
@riverpod
class ProductCategoriesController extends _$ProductCategoriesController {
  @override
  Future<PaginatedProductCategories> build(
    String companyId, {
    required int page,
    required int pageSize,
    String? search,
  }) async {
    if (companyId.isEmpty) {
      return PaginatedProductCategories.empty();
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final offset = (page - 1) * pageSize;

      final response = await managementClient
          .request(
            GListProductCategoriesPaginatedReq(
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
          'GraphQL errors while fetching product categories: ${response.graphqlErrors}',
        );
        throw Exception('Failed to fetch product categories');
      }

      final data = response.data?.listProductCategoriesPaginated;

      if (data != null) {
        final items = data.items.map(ProductCategory.fromGraphQL).toList();

        return PaginatedProductCategories(
          items: items,
          totalCount: data.pageInfo?.totalCount ?? 0,
          currentPage: data.pageInfo?.currentPage ?? 1,
          totalPages: data.pageInfo?.totalPages ?? 0,
          hasNextPage: data.pageInfo?.hasNextPage ?? false,
          hasPreviousPage: data.pageInfo?.hasPreviousPage ?? false,
        );
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch product categories', e);
      rethrow;
    }

    return PaginatedProductCategories.empty();
  }
}
