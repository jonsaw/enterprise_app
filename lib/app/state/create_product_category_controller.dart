import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_product_category_controller.g.dart';

/// Input data for creating a product category.
class CreateProductCategoryInput {
  /// Creates a [CreateProductCategoryInput].
  const CreateProductCategoryInput({
    required this.name,
    this.description,
  });

  /// The category name.
  final String name;

  /// The category description (optional).
  final String? description;
}

/// Controller for creating product categories.
@riverpod
class CreateProductCategoryController
    extends _$CreateProductCategoryController {
  @override
  FutureOr<void> build(String companyId) {
    // No initial state needed
  }

  /// Creates a new product category.
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> createCategory(
    CreateProductCategoryInput input,
  ) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final companyIdValue = GUUIDBuilder()..value = companyId;

      final response = await managementClient
          .request(
            GCreateProductCategoryReq(
              (b) => b
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
          'GraphQL errors while creating product category: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to create product category', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
