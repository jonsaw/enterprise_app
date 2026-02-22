import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/product.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_detail_controller.g.dart';

/// Controller for fetching a single product's details.
@riverpod
class ProductDetailController extends _$ProductDetailController {
  @override
  Future<Product?> build(String companyId, String productId) async {
    if (productId.isEmpty) {
      return null;
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final productIdValue = GUUIDBuilder()..value = productId;

      final response = await managementClient
          .request(
            GGetProductReq(
              (b) => b
                ..vars.id = productIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        talker.error(
          'GraphQL errors while fetching product: ${response.graphqlErrors}',
        );
        return null;
      }

      final data = response.data?.product;

      if (data != null) {
        return Product.fromGGetProductData(data);
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch product', e);
    }

    return null;
  }
}
