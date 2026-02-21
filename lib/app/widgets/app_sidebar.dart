import 'dart:async';

import 'package:enterprise/app/pages/company_app_shell_page.dart';
import 'package:enterprise/app/state/auth_controller.dart';
import 'package:enterprise/app/state/company_controller.dart';
import 'package:enterprise/app/state/selected_id_provider.dart';
import 'package:enterprise/app/widgets/company_dropdown.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

/// Shows the app sidebar.
Future<void> showAppSidebar(BuildContext context, String companyId) {
  final theme = context.theme;
  final currentPath = GoRouterState.of(context).uri.path;
  return showFSheet(
    useRootNavigator: true,
    context: context,
    side: FLayout.ltr,
    builder: (context) => DecoratedBox(
      decoration: BoxDecoration(color: theme.colors.background),
      child: AppSidebar(companyId: companyId, currentPath: currentPath),
    ),
  );
}

/// Icon button to open the app sidebar.
class AppSidebarIconButton extends StatelessWidget {
  /// Creates an [AppSidebarIconButton].
  const AppSidebarIconButton({required this.companyId, super.key});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      onPress: () {
        unawaited(
          showAppSidebar(context, companyId),
        );
      },
      child: const Icon(FIcons.menu),
    );
  }
}

/// Sidebar for the app.
class AppSidebar extends ConsumerWidget {
  /// Creates an [AppSidebar].
  const AppSidebar({
    required this.companyId,
    required this.currentPath,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The current path.
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final company = ref.watch(companyControllerProvider(companyId));
    final navigationShell = ref.watch(currentNavigationShellProvider);
    final auth = ref.watch(authControllerProvider).value;

    return SafeArea(
      right: false,
      child: FSidebar(
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
                        _clearAllSelectedIds(ref);
                        context.go('/companies/${cu.company?.id}');
                        unawaited(Navigator.of(context).maybePop());
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
              const FDivider(
                style: .delta(padding: .value(.zero)),
              ),
            ],
          ),
        ),
        footer: auth != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () => _navigateToBranch(
                    context,
                    ref,
                    1,
                    currentPath,
                    '/companies/$companyId/profile',
                    companyId,
                    navigationShell,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            currentPath.startsWith(
                              '/companies/$companyId/profile',
                            )
                            ? theme.colors.primary
                            : theme.colors.border,
                      ),
                      color:
                          currentPath.startsWith(
                            '/companies/$companyId/profile',
                          )
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
                  navigationShell,
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
                  navigationShell,
                ),
              ),
            ],
          ),
          FSidebarGroup(
            label: Text(context.tr.products),
            children: [
              FSidebarItem(
                icon: const Icon(FIcons.tag),
                label: Text(context.tr.categories),
                selected: _sidebarItemSelected(
                  currentPath,
                  '/companies/$companyId/product-categories',
                ),
                onPress: () => _navigateToBranch(
                  context,
                  ref,
                  4,
                  currentPath,
                  '/companies/$companyId/product-categories',
                  companyId,
                  navigationShell,
                ),
              ),
              FSidebarItem(
                icon: const Icon(FIcons.box),
                label: Text(context.tr.types),
                selected: _sidebarItemSelected(
                  currentPath,
                  '/companies/$companyId/product-types',
                ),
                onPress: () => _navigateToBranch(
                  context,
                  ref,
                  5,
                  currentPath,
                  '/companies/$companyId/product-types',
                  companyId,
                  navigationShell,
                ),
              ),
            ],
          ),
          FSidebarGroup(
            label: Text(context.tr.access),
            children: [
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
                  navigationShell,
                ),
              ),
              FSidebarItem(
                icon: const Icon(FIcons.mail),
                label: Text(context.tr.invites),
                selected: _sidebarItemSelected(
                  currentPath,
                  '/companies/$companyId/invites',
                ),
                onPress: () => _navigateToBranch(
                  context,
                  ref,
                  3,
                  currentPath,
                  '/companies/$companyId/invites',
                  companyId,
                  navigationShell,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToBranch(
    BuildContext context,
    WidgetRef ref,
    int index,
    String currentPath,
    String path,
    String? activeCompanyId,
    StatefulNavigationShell? navigationShell,
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
      _clearAllSelectedIds(ref);
      context.go(path);
    } else {
      // Same company or first time, use goBranch() to preserve state
      // initialLocation should be TRUE only when refreshing the current branch
      // FALSE when switching to a different branch (to preserve its navigation stack)
      final isAlreadyOnBranch = index == navigationShell?.currentIndex;

      navigationShell?.goBranch(
        index,
        initialLocation: isAlreadyOnBranch,
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

  void _clearAllSelectedIds(WidgetRef ref) {
    for (final type in SelectedIdType.values) {
      ref.read(selectedIdProvider(type).notifier).id = null;
    }
  }

  bool _sidebarItemSelected(String currentPath, String targetPath) {
    return currentPath.startsWith(targetPath);
  }
}
