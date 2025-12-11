import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app_clients.dart';
import 'package:enterprise/l10n.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Dropdown widget for selecting a company.
class CompanyDropdown extends ConsumerWidget {
  /// Creates a [CompanyDropdown].
  const CompanyDropdown({super.key, this.onChange, this.initialValue});

  /// Callback when the selected company changes.
  final void Function(CompanyUser?)? onChange;

  /// The initial selected company.
  final CompanyUser? initialValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(gqlManagementClientProvider);

    return FSelect<CompanyUser>.searchBuilder(
      hint: context.tr.selectCompany,
      initialValue: initialValue,
      format: (value) => value.company?.name ?? context.tr.unknownCompany,
      onChange: onChange,
      filter: (query) async {
        final response = await client
            .request(
              GListMyCompaniesReq(
                (b) => b
                  ..fetchPolicy = FetchPolicy.NetworkOnly
                  ..vars.input.search = query
                  ..vars.input.offset = 0
                  ..vars.input.limit = 20,
              ),
            )
            .first;

        return response.data?.listMyCompanies.map((c) {
              return CompanyUser.fromGListMyCompaniesData(c);
            }).toList() ??
            [];
      },
      contentBuilder:
          (BuildContext context, String query, Iterable<CompanyUser> values) =>
              [
                for (final companyUser in values)
                  FSelectItem(
                    title: Text(
                      companyUser.company?.name ?? context.tr.unknownCompany,
                    ),
                    value: companyUser,
                  ),
              ],
    );
  }
}
