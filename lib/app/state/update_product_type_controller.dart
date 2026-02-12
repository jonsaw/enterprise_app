import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_product_type_controller.g.dart';

/// Input data for updating a product type.
class UpdateProductTypeInput {
  /// Creates an [UpdateProductTypeInput].
  const UpdateProductTypeInput({
    required this.name,
    required this.detailsUi,
    this.description,
  });

  /// The type name.
  final String name;

  /// The type description (optional).
  final String? description;

  /// The UI schema JSON string.
  final String detailsUi;
}

/// Controller for updating product types.
@riverpod
class UpdateProductTypeController extends _$UpdateProductTypeController {
  @override
  FutureOr<void> build(String companyId, String typeId) {}

  /// Updates an existing product type.
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> updateType(UpdateProductTypeInput input) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);

      final response = await managementClient
          .request(
            GUpdateProductTypeReq(
              (b) => b
                ..vars.input.id = GUUID(typeId).toBuilder()
                ..vars.input.name = input.name
                ..vars.input.description = input.description
                ..vars.input.detailsUi = input.detailsUi
                ..vars.input.companyId = GUUID(companyId).toBuilder()
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        final errorMessage =
            response.graphqlErrors?.firstOrNull?.message ?? 'Unknown error';
        talker.error(
          'GraphQL errors while updating product type: ${response.graphqlErrors}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to update product type', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
