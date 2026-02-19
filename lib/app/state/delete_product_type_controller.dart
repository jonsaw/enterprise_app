import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_product_type_controller.g.dart';

/// Controller for deleting product types.
@riverpod
class DeleteProductTypeController extends _$DeleteProductTypeController {
  @override
  FutureOr<void> build(String companyId, String typeId) {}

  /// Deletes a product type (soft delete).
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> delete() async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final typeIdValue = GUUIDBuilder()..value = typeId;

      final response = await managementClient
          .request(
            GDeleteProductTypeReq(
              (b) => b
                ..vars.id = typeIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        final errorMessage =
            response.graphqlErrors?.firstOrNull?.message ?? 'Unknown error';
        talker.error(
          'GraphQL errors while deleting product type: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      final success = response.data?.deleteProductType ?? false;

      if (success) {
        state = const AsyncData(null);
        return (true, null);
      } else {
        state = AsyncError(
          Exception('Failed to delete type'),
          StackTrace.current,
        );
        return (false, null);
      }
    } on Exception catch (e, st) {
      talker.error('Failed to delete product type', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
