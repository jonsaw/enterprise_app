import 'package:enterprise/app/state/company_controller.dart';
import 'package:enterprise/app/widgets/page_header.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Home page
class HomePage extends ConsumerWidget {
  /// Creates a [HomePage].
  const HomePage({required this.companyId, super.key});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final company = ref.watch(companyControllerProvider(companyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        PageHeader(title: context.tr.homePageTitle),
        Expanded(
          child: Center(
            child: Column(
              children: [
                Text(
                  context.tr.homePageContent,
                  style: theme.typography.base.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                switch (company) {
                  AsyncData(:final value) when value != null => Column(
                    children: [
                      Text(
                        'Current Company: ${value.company?.name ?? 'N/A'}',
                        style: theme.typography.base.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colors.foreground,
                        ),
                      ),
                      Text('Role: ${value.role.tr(context.tr)}'),
                    ],
                  ),
                  AsyncLoading() => const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: FCircularProgress(),
                  ),
                  AsyncError(
                    :final error,
                  ) =>
                    Text(
                      'Error loading company: $error',
                      style: theme.typography.base.copyWith(
                        color: theme.colors.errorForeground,
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ],
            ),
          ),
        ),
      ],
    );
  }
}
