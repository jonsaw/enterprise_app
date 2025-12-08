import 'package:enterprise/app/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// User page with standard access features.
///
/// Provides navigation to:
/// - Home
/// - Profile
class UserPage extends ConsumerStatefulWidget {
  /// Creates a [UserPage].
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  int _selectedIndex = 0;

  static final List<(String, IconData)> _navigationItems = [
    ('Home', FIcons.layoutDashboard),
    ('Profile', FIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authControllerProvider).value;

    return FScaffold(
      sidebar: FSidebar(
        header: Padding(
          padding: const .symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const .fromLTRB(12, 0, 12, 8),
                child: Text(
                  'Enterprise',
                  style: theme.typography.xl2.copyWith(
                    fontWeight: .bold,
                    color: theme.colors.primary,
                  ),
                ),
              ),
              FDivider(
                style: theme.dividerStyles.horizontalStyle
                    .copyWith(
                      padding: .zero,
                    )
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
              FSidebarItem(
                icon: Icon(_navigationItems[0].$2),
                label: Text(_navigationItems[0].$1),
                onPress: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              FSidebarItem(
                icon: Icon(_navigationItems[1].$2),
                label: Text(_navigationItems[1].$1),
                onPress: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      child: _buildContent(theme),
    );
  }

  Widget _buildContent(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            _navigationItems[_selectedIndex].$1,
            style: theme.typography.xl3.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.foreground,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Content for ${_navigationItems[_selectedIndex].$1} '
                'will be implemented here.',
                style: theme.typography.base.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
