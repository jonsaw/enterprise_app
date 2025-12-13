import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_user_detail_controller.g.dart';

/// Controller for managing company user detail state.
@riverpod
class CompanyUserDetailController extends _$CompanyUserDetailController {
  @override
  Future<CompanyUser?> build(String companyId, String userId) async {
    if (companyId.isEmpty || userId.isEmpty) {
      return null;
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;
      final userIdValue = GUUIDBuilder()..value = userId;

      final response = await managementClient
          .request(
            GGetMyCompanyUserReq(
              (b) => b
                ..vars.companyId = companyIdValue
                ..vars.userId = userIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        talker.error(
          'GraphQL errors while fetching company user: ${response.graphqlErrors}',
        );
        return null;
      }

      final userData = response.data?.getMyCompanyUser;

      if (userData != null) {
        return CompanyUser.fromGGetMyCompanyUserData(userData);
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch company user', e);
    }

    return null;
  }
}
