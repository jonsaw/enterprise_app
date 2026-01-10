import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_product_category_controller.g.dart';

/// Input data for updating a product category.
class UpdateProductCategoryInput {
  /// Creates an [UpdateProductCategoryInput].
  const UpdateProductCategoryInput({
    required this.name,
    this.description,
  });

  /// The category name.
  final String name;

  /// The category description (optional).
  final String? description;
}

/// Controller for updating product categories.
@riverpod
class UpdateProductCategoryController
    extends _$UpdateProductCategoryController {
  @override
  FutureOr<void> build(String companyId, String categoryId) {}

  /// Updates an existing product category.
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> updateCategory(
    UpdateProductCategoryInput input,
  ) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final categoryIdValue = GUUIDBuilder()..value = categoryId;

      final response = await managementClient
          .request(
            GUpdateProductCategoryReq(
              (b) => b
                ..vars.input.id = categoryIdValue
                ..vars.input.name = input.name
                ..vars.input.description = input.description
                ..vars.input.companyId = companyIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        final errorMessage =
            response.graphqlErrors?.firstOrNull?.message ?? 'Unknown error';
        talker.error(
          'GraphQL errors while updating product category: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to update product category', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
