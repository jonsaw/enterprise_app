import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/utils/client_errors.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_company_invite_controller.g.dart';

/// Input for creating a company invite.
class CreateCompanyInviteInput {
  /// Creates a [CreateCompanyInviteInput].
  const CreateCompanyInviteInput({
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
  });

  /// The name of the invitee.
  final String name;

  /// The email of the invitee.
  final String email;

  /// The role for the invitee.
  final UserRole role;

  /// The company ID.
  final String companyId;
}

/// Controller for creating company invites.
@riverpod
class CreateCompanyInviteController extends _$CreateCompanyInviteController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Creates a new company invite.
  /// Returns a tuple of (success, errorMessage).
  Future<(bool, String?)> createInvite(CreateCompanyInviteInput input) async {
    state = const AsyncLoading();

    try {
      final managementClient = ref.read(gqlManagementClientProvider);
      final companyIdValue = GUUIDBuilder()..value = input.companyId;

      // Convert UserRole to GraphQL enum
      final roleEnum = _toGraphQLRole(input.role);

      final response = await managementClient
          .request(
            GCreateCompanyInviteReq(
              (b) => b
                ..vars.input.name = input.name
                ..vars.input.email = input.email
                ..vars.input.role = roleEnum
                ..vars.input.companyId = companyIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        final error = graphqlErrorMessage(response);

        talker.error(
          'Failed to create company invite: ${error.runtimeType} ${error.reason}',
        );

        state = AsyncError(
          Exception(error.reason),
          StackTrace.current,
        );
        return (false, error.reason);
      }

      state = const AsyncData(null);
      return (true, null);
    } on Exception catch (e, st) {
      talker.error('Failed to create company invite', e);
      final errorMessage = e.toString();
      state = AsyncError(e, st);
      return (false, errorMessage);
    }
  }

  GCompanyUserRole _toGraphQLRole(UserRole role) {
    return switch (role) {
      Owner() => GCompanyUserRole.OWNER,
      Manager() => GCompanyUserRole.MANAGER,
      UserMember() => GCompanyUserRole.USER,
      None() => GCompanyUserRole.USER, // Default fallback
    };
  }
}
