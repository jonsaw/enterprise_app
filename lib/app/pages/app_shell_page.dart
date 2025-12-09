import 'package:enterprise/app/state/auth_controller.dart';
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

  static final List<(String, IconData, String)> _navigationItems = [
    ('Home', FIcons.layoutDashboard, '/home'),
    ('Profile', FIcons.user, '/profile'),
  ];

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final auth = ref.watch(authControllerProvider).value;

    return SafeArea(
      bottom: false,
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.colors.background),
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
                    'Enterprise',
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
                  child: FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          Row(
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
                          FButton(
                            style: FButtonStyle.outline(),
                            onPress: () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signOut();
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FIcons.logOut, size: 16),
                                SizedBox(width: 8),
                                Text('Sign Out'),
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
              label: const Text('Overview'),
              children: [
                for (var i = 0; i < _navigationItems.length; i++)
                  FSidebarItem(
                    icon: Icon(_navigationItems[i].$2),
                    label: Text(_navigationItems[i].$1),
                    selected: navigationShell.currentIndex == i,
                    onPress: () async {
                      navigationShell.goBranch(i);
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
                      'Enterprise',
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
