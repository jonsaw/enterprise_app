import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/product_type.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_type_detail_controller.g.dart';

/// Controller for fetching a single product type's details.
@riverpod
class ProductTypeDetailController extends _$ProductTypeDetailController {
  @override
  Future<ProductType?> build(String companyId, String typeId) async {
    if (typeId.isEmpty) {
      return null;
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final typeIdValue = GUUIDBuilder()..value = typeId;

      final response = await managementClient
          .request(
            GGetProductTypeReq(
              (b) => b
                ..vars.id = typeIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.linkException != null) {
        talker.error(
          'Network error while fetching product type: ${response.linkException}',
        );
        return null;
      }

      if (response.graphqlErrors != null && response.graphqlErrors!.isNotEmpty) {
        final errors = response.graphqlErrors!.map((e) => e.message).join(', ');
        talker.error(
          'GraphQL errors while fetching product type: $errors',
        );
        return null;
      }

      final data = response.data?.productType;

      if (data != null) {
        return ProductType.fromGGetProductTypeData(data);
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch product type', e);
    }

    return null;
  }
}
