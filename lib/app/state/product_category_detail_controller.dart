import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/product_category.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_category_detail_controller.g.dart';

/// Controller for fetching a single product category's details.
@riverpod
class ProductCategoryDetailController
    extends _$ProductCategoryDetailController {
  @override
  Future<ProductCategory?> build(String companyId, String categoryId) async {
    if (categoryId.isEmpty) {
      return null;
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final categoryIdValue = GUUIDBuilder()..value = categoryId;

      final response = await managementClient
          .request(
            GGetProductCategoryReq(
              (b) => b
                ..vars.id = categoryIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        talker.error(
          'GraphQL errors while fetching product category: ${response.graphqlErrors}',
        );
        return null;
      }

      final data = response.data?.productCategory;

      if (data != null) {
        return ProductCategory.fromGGetProductCategoryData(data);
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch product category', e);
    }

    return null;
  }
}
