import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_product_controller.g.dart';

/// Controller for creating products.
@riverpod
class CreateProductController extends _$CreateProductController {
  @override
  FutureOr<void> build(String companyId) {
    // No initial state needed
  }

  /// Creates a new product.
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> createProduct({
    required String sku,
    required String description,
    required String detailsData,
    required bool affectsInventory,
    String? brand,
    String? model,
    String? categoryId,
    String? typeId,
  }) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final companyIdValue = GUUIDBuilder()..value = companyId;

      final reqBuilder = GCreateProductReqBuilder()
        ..vars.input.companyId = companyIdValue
        ..vars.input.sku = sku
        ..vars.input.brand = brand
        ..vars.input.model = model
        ..vars.input.affectsInventory = affectsInventory
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
          'GraphQL errors while creating product: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to create product', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
