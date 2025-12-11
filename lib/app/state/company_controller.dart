import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_controller.g.dart';

/// Controller for managing company-related state.
@riverpod
class CompanyController extends _$CompanyController {
  @override
  Future<CompanyUser?> build(String? companyId) async {
    if (companyId == null) {
      return null;
    }

    final managementClient = ref.read(gqlManagementClientProvider);

    try {
      final companyIdValue = GUUIDBuilder()..value = companyId;

      final response = await managementClient
          .request(
            GGetMyCompanyReq(
              (b) => b
                ..vars.companyId = companyIdValue
                ..fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          )
          .first;

      if (response.hasErrors) {
        talker.error(
          'GraphQL errors while fetching company data: ${response.graphqlErrors}',
        );
        return null;
      }

      final companyData = response.data?.getMyCompany;

      if (companyData != null) {
        return CompanyUser.fromGGetMyCompanyData(companyData);
      }
    } on Exception catch (e) {
      talker.error('Failed to fetch company data', e);
    }

    return null;
  }
}
