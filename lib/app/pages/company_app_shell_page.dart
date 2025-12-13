import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/auth.dart';
import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app/state/auth_controller.dart';
import 'package:enterprise/app/state/company_controller.dart';
import 'package:enterprise/app/widgets/company_dropdown.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
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

/// App shell page with navigation.
///
/// Provides navigation to:
/// - Home
/// - Profile
class CompanyAppShellPage extends ConsumerWidget {
  /// Creates an [CompanyAppShellPage].
  const CompanyAppShellPage({required this.navigationShell, super.key});

  /// The navigation shell for managing sub-routes
  final StatefulNavigationShell navigationShell;

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    String? companyId,
    AsyncValue<CompanyUser?> company,
    Auth? auth,
    String currentPath,
  ) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colors.background),
      child: SafeArea(
        child: FSidebar(
          width: sidebarWidth,
          header: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: switch (company) {
                    AsyncData(:final value) => CompanyDropdown(
                      initialValue: value,
                      onChange: (cu) {
                        if (cu != null && cu.company != null) {
                          context.go('/companies/${cu.company?.id}');
                        }
                      },
                    ),
                    AsyncLoading() => Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colors.muted,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FCircularProgress(),
                        ],
                      ),
                    ),
                    AsyncError(:final error) => Text(
                      'Error loading company: $error',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.errorForeground,
                      ),
                    ),
                  },
                ),
                FDivider(
                  style: theme.dividerStyles.horizontalStyle
                      .copyWith(padding: EdgeInsets.zero)
                      .call,
                ),
              ],
            ),
          ),
          footer: auth != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => _navigateToBranch(
                      context,
                      ref,
                      1,
                      currentPath,
                      '/companies/$companyId/profile',
                      companyId,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: navigationShell.currentIndex == 1
                              ? theme.colors.primary
                              : theme.colors.border,
                        ),
                        color: navigationShell.currentIndex == 1
                            ? theme.colors.primary.withAlpha(25)
                            : theme.colors.background,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          FAvatar.raw(
                            child: Icon(
                              FIcons.user,
                              size: 18,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  auth.name,
                                  style: theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colors.foreground,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  auth.email,
                                  style: theme.typography.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          children: [
            FSidebarGroup(
              label: Text(context.tr.overview),
              children: [
                FSidebarItem(
                  icon: const Icon(FIcons.layoutDashboard),
                  label: Text(context.tr.home),
                  selected: _sidebarItemSelected(
                    currentPath,
                    '/companies/$companyId/home',
                  ),
                  onPress: () => _navigateToBranch(
                    context,
                    ref,
                    0,
                    currentPath,
                    '/companies/$companyId/home',
                    companyId,
                  ),
                ),
                FSidebarItem(
                  icon: const Icon(FIcons.users),
                  label: Text(context.tr.users),
                  selected: _sidebarItemSelected(
                    currentPath,
                    '/companies/$companyId/users',
                  ),
                  onPress: () => _navigateToBranch(
                    context,
                    ref,
                    2,
                    currentPath,
                    '/companies/$companyId/users',
                    companyId,
                  ),
                ),
                FSidebarItem(
                  icon: const Icon(FIcons.user),
                  label: Text(context.tr.profile),
                  selected: _sidebarItemSelected(
                    currentPath,
                    '/companies/$companyId/profile',
                  ),
                  onPress: () => _navigateToBranch(
                    context,
                    ref,
                    1,
                    currentPath,
                    '/companies/$companyId/profile',
                    companyId,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _sidebarItemSelected(String currentPath, String targetPath) {
    return currentPath.startsWith(targetPath);
  }

  void _navigateToBranch(
    BuildContext context,
    WidgetRef ref,
    int index,
    String currentPath,
    String path,
    String? activeCompanyId,
  ) {
    if (currentPath == path) {
      return;
    }

    // Get branch tracking state using read (not watch) since we're in an event handler
    final branchTracking = ref.read(branchCompanyTrackingProvider);
    final lastBranchCompanyId = branchTracking[index];
    final branchHasDifferentCompany =
        lastBranchCompanyId != null && lastBranchCompanyId != activeCompanyId;

    if (branchHasDifferentCompany) {
      // Branch has cached routes from a different company, use context.go() to reset
      context.go(path);
    } else {
      // Same company or first time, use goBranch() to preserve state
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    // Update the tracking state
    if (activeCompanyId != null) {
      ref
          .read(branchCompanyTrackingProvider.notifier)
          .updateBranch(
            index,
            activeCompanyId,
          );
    }

    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;
    final companyId = GoRouterState.of(context).pathParameters['companyId'];
    final currentPath = GoRouterState.of(context).uri.path;

    final company = ref.watch(companyControllerProvider(companyId));
    final auth = ref.watch(authControllerProvider).value;

    if (isSmallScreen) {
      return FScaffold(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colors.border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    FButton(
                      style: FButtonStyle.outline(),
                      onPress: () => showFSheet<void>(
                        context: context,
                        side: FLayout.ltr,
                        builder: (context) => _buildSidebar(
                          context,
                          ref,
                          companyId,
                          company,
                          auth,
                          currentPath,
                        ),
                      ),
                      child: const Icon(FIcons.menu),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: switch (company) {
                        AsyncData(:final value) when value?.company != null =>
                          Text(
                            value!.company!.name,
                            style: theme.typography.xl.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        _ => Text(
                          context.tr.appName,
                          style: theme.typography.xl.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.primary,
                          ),
                        ),
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    }

    return FScaffold(
      sidebar: _buildSidebar(
        context,
        ref,
        companyId,
        company,
        auth,
        currentPath,
      ),
      child: navigationShell,
    );
  }
}
