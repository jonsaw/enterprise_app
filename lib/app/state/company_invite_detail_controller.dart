import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company_invite.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_invite_detail_controller.g.dart';

/// Controller for managing company invite detail state.
@riverpod
class CompanyInviteDetailController extends _$CompanyInviteDetailController {
  @override
  Future<CompanyInvite?> build(String companyId, String inviteId) async {
    if (companyId.isEmpty || inviteId.isEmpty) {
      return null;
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final inviteIdValue = GUUIDBuilder()..value = inviteId;

      final response = await managementClient
          .request(
            GGetMyCompanyInviteReq(
              (b) => b
                ..vars.companyId = companyIdValue
                ..vars.id = inviteIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        talker.error(
          'GraphQL errors while fetching company invite: ${response.graphqlErrors}',
        );
        return null;
      }

      final inviteData = response.data?.getMyCompanyInvite;

      if (inviteData != null) {
        return CompanyInvite.fromGGetMyCompanyInviteData(inviteData);
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch company invite', e);
    }

    return null;
  }
}
