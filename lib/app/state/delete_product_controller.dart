import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_product_controller.g.dart';

/// Controller for deleting products.
@riverpod
class DeleteProductController extends _$DeleteProductController {
  @override
  FutureOr<void> build(String companyId, String productId) {}

  /// Deletes a product (soft delete).
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> delete() async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final productIdValue = GUUIDBuilder()..value = productId;

      final response = await managementClient
          .request(
            GDeleteProductReq(
              (b) => b
                ..vars.id = productIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        final errorMessage =
            response.graphqlErrors?.firstOrNull?.message ?? 'Unknown error';
        talker.error(
          'GraphQL errors while deleting product: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      final success = response.data?.deleteProduct ?? false;

      if (success) {
        state = const AsyncData(null);
        return (true, null);
      } else {
        state = AsyncError(
          Exception('Failed to delete product'),
          StackTrace.current,
        );
        return (false, null);
      }
    } on Exception catch (e, st) {
      talker.error('Failed to delete product', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
