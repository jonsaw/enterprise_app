import 'package:enterprise/app/utils/auth_dialogs.dart';
import 'package:enterprise/app/widgets/company_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

/// Companies page
class CompaniesPage extends ConsumerWidget {
  /// Creates a [CompaniesPage].
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return FScaffold(
      child: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  border: Border.all(color: theme.colors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CompanyDropdown(
                  onChange: (cu) {
                    if (cu != null && cu.company != null) {
                      context.go('/companies/${cu.company?.id}');
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FButton.icon(
                  onPress: () => showSignOutDialog(context, ref),
                  child: const Icon(FIcons.logOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
