import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/product.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_controller.g.dart';

/// Paginated products result.
class PaginatedProducts {
  /// Creates a [PaginatedProducts].
  const PaginatedProducts({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an empty result.
  factory PaginatedProducts.empty() {
    return const PaginatedProducts(
      items: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// The list of products.
  final List<Product> items;

  /// Total count of products.
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

/// Controller for managing products list state.
@riverpod
class ProductsController extends _$ProductsController {
  @override
  Future<PaginatedProducts> build(
    String companyId, {
    required int page,
    required int pageSize,
    String? search,
  }) async {
    if (companyId.isEmpty) {
      return PaginatedProducts.empty();
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final offset = (page - 1) * pageSize;

      final response = await managementClient
          .request(
            GListProductsPaginatedReq(
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
          'GraphQL errors while fetching products: ${response.graphqlErrors}',
        );
        throw Exception('Failed to fetch products');
      }

      final data = response.data?.listProductsPaginated;

      if (data != null) {
        final items = data.items.map(Product.fromGraphQL).toList();

        return PaginatedProducts(
          items: items,
          totalCount: data.pageInfo?.totalCount ?? 0,
          currentPage: data.pageInfo?.currentPage ?? 1,
          totalPages: data.pageInfo?.totalPages ?? 0,
          hasNextPage: data.pageInfo?.hasNextPage ?? false,
          hasPreviousPage: data.pageInfo?.hasPreviousPage ?? false,
        );
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch products', e);
      rethrow;
    }

    return PaginatedProducts.empty();
  }
}
