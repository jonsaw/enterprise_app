import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_product_category_controller.g.dart';

/// Controller for deleting product categories.
@riverpod
class DeleteProductCategoryController
    extends _$DeleteProductCategoryController {
  @override
  FutureOr<void> build(String companyId, String categoryId) {}

  /// Deletes a product category (soft delete).
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> delete() async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final categoryIdValue = GUUIDBuilder()..value = categoryId;

      final response = await managementClient
          .request(
            GDeleteProductCategoryReq(
              (b) => b
                ..vars.id = categoryIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        final errorMessage =
            response.graphqlErrors?.firstOrNull?.message ?? 'Unknown error';
        talker.error(
          'GraphQL errors while deleting product category: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      final success = response.data?.deleteProductCategory ?? false;

      if (success) {
        state = const AsyncData(null);
        return (true, null);
      } else {
        const errorMessage = 'Failed to delete category';
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }
    } on Exception catch (e, st) {
      talker.error('Failed to delete product category', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
