import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_app_shell_page.g.dart';

/// Notifier to track which company each navigation branch last showed
@Riverpod(keepAlive: true)
class BranchCompanyTracking extends _$BranchCompanyTracking {
  @override
  Map<int, String> build() => {};

  /// Update the company ID for a specific branch
  void updateBranch(int branchIndex, String companyId) {
    state = {...state, branchIndex: companyId};
  }
}

/// Provider to expose the current navigation shell
/// This allows CompanyShellPage to access the navigation shell for branch navigation
@Riverpod(keepAlive: true)
class CurrentNavigationShell extends _$CurrentNavigationShell {
  @override
  StatefulNavigationShell? build() => null;

  /// Update the navigation shell reference
  set shell(StatefulNavigationShell? shell) {
    state = shell;
  }
}

/// App shell page with navigation.
class CompanyAppShellPage extends ConsumerWidget {
  /// Creates an [CompanyAppShellPage].
  const CompanyAppShellPage({required this.navigationShell, super.key});

  /// The navigation shell for managing sub-routes
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On medium+ screens, expose the navigation shell for CompanyShellPage after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentNavigationShellProvider.notifier).shell = navigationShell;
    });

    // CompanyShellPage handles the sidebar
    // Just return the navigation shell content
    return navigationShell;
  }
}
