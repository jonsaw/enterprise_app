import 'package:api_management/api_management.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_product_type_controller.g.dart';

/// Input data for creating a product type.
class CreateProductTypeInput {
  /// Creates a [CreateProductTypeInput].
  const CreateProductTypeInput({
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

/// Controller for creating product types.
@riverpod
class CreateProductTypeController extends _$CreateProductTypeController {
  @override
  FutureOr<void> build(String companyId) {
    // No initial state needed
  }

  /// Creates a new product type.
  ///
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> createType(CreateProductTypeInput input) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);

      final response = await managementClient
          .request(
            GCreateProductTypeReq(
              (b) => b
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
          'GraphQL errors while creating product type:\n'
          'Errors: ${response.graphqlErrors}\n'
          'Link exception: ${response.linkException}\n'
          'Response: ${response.data}',
        );
        state = AsyncError(Exception(errorMessage), StackTrace.current);
        return (false, errorMessage);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to create product type', e);
      state = AsyncError(e, st);
      return (false, e.toString());
    }
  }
}
