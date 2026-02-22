import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_product_controller.g.dart';

/// Controller for updating products.
@riverpod
class UpdateProductController extends _$UpdateProductController {
  @override
  FutureOr<void> build(String companyId, String productId) {}

  /// Updates an existing product.
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> updateProduct({
    required String sku,
    required String description,
    required String detailsData,
    required bool affectsInventory,
    required int revision,
    String? brand,
    String? model,
    String? categoryId,
    String? typeId,
  }) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final productIdValue = GUUIDBuilder()..value = productId;

      final reqBuilder = GUpdateProductReqBuilder()
        ..vars.input.id = productIdValue
        ..vars.input.companyId = companyIdValue
        ..vars.input.sku = sku
        ..vars.input.brand = brand
        ..vars.input.model = model
        ..vars.input.affectsInventory = affectsInventory
        ..vars.input.revision = revision
        ..fetchPolicy = FetchPolicy.NetworkOnly;

      if (categoryId != null) {
        reqBuilder.vars.input.categoryId = (GUUIDBuilder()..value = categoryId);
      }
      if (typeId != null) {
        reqBuilder.vars.input.typeId = (GUUIDBuilder()..value = typeId);
      }

      reqBuilder.vars.input.description = description;
      reqBuilder.vars.input.detailsData = detailsData;

      final response = await managementClient.request(reqBuilder.build()).first;

      if (response.hasErrors) {
        final errorMessage =
            response.graphqlErrors?.firstOrNull?.message ?? 'Unknown error';
        talker.error(
          'GraphQL errors while updating product: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to update product', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
