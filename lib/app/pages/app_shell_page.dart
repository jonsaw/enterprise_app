import 'package:enterprise/app/state/auth_controller.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

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

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final auth = ref.watch(authControllerProvider).value;

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colors.background),
      child: SafeArea(
        child: FSidebar(
          width: 400,
          header: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    context.tr.appName,
                    style: theme.typography.xl2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.primary,
                    ),
                  ),
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
                    onTap: () async {
                      navigationShell.goBranch(1);
                      await Navigator.of(context).maybePop();
                    },
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
                  selected: navigationShell.currentIndex == 0,
                  onPress: () async {
                    navigationShell.goBranch(0);
                    await Navigator.of(context).maybePop();
                  },
                ),
                FSidebarItem(
                  icon: const Icon(FIcons.user),
                  label: Text(context.tr.profile),
                  selected: navigationShell.currentIndex == 1,
                  onPress: () async {
                    navigationShell.goBranch(1);
                    await Navigator.of(context).maybePop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;

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
                        builder: (context) => _buildSidebar(context, ref),
                      ),
                      child: const Icon(FIcons.menu),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr.appName,
                      style: theme.typography.xl.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colors.primary,
                      ),
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
      sidebar: _buildSidebar(context, ref),
      child: navigationShell,
    );
  }
}
