import 'dart:async';

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

/// Width of the sidebar
const sidebarWidth = 400.0;

/// App shell page with navigation.
///
/// Provides navigation to:
/// - Home
/// - Profile
class AppShellPage extends ConsumerWidget {
  /// Creates an [AppShellPage].
  const AppShellPage({required this.navigationShell, super.key});

  /// The navigation shell for managing sub-routes
  final StatefulNavigationShell navigationShell;

  Widget _buildSidebar(
    BuildContext context,
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
                      '/companies/$companyId/profile',
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
                  selected: currentPath.startsWith(
                    '/companies/$companyId/home',
                  ),
                  onPress: () => _navigateToBranch(
                    context,
                    '/companies/$companyId/home',
                  ),
                ),
                FSidebarItem(
                  icon: const Icon(FIcons.user),
                  label: Text(context.tr.profile),
                  selected: currentPath.startsWith(
                    '/companies/$companyId/profile',
                  ),
                  onPress: () => _navigateToBranch(
                    context,
                    '/companies/$companyId/profile',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBranch(
    BuildContext context,
    String path,
  ) {
    context.go(path);
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
      sidebar: _buildSidebar(context, companyId, company, auth, currentPath),
      child: navigationShell,
    );
  }
}
