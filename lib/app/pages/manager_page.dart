import 'package:enterprise/app/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Manager page with team management features.
///
/// Provides navigation to:
/// - Dashboard
/// - Team Members
/// - Reports
class ManagerPage extends ConsumerStatefulWidget {
  /// Creates a [ManagerPage].
  const ManagerPage({super.key});

  @override
  ConsumerState<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends ConsumerState<ManagerPage> {
  int _selectedIndex = 0;

  static final List<(String, IconData)> _navigationItems = [
    ('Dashboard', FIcons.layoutDashboard),
    ('Team Members', FIcons.users),
    ('Reports', FIcons.fileText),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authControllerProvider).value;

    return FScaffold(
      sidebar: FSidebar(
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
                    .copyWith(
                      padding: EdgeInsets.zero,
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
            children: _navigationItems
                .asMap()
                .entries
                .map(
                  (entry) => FSidebarItem(
                    icon: Icon(entry.value.$2),
                    label: Text(entry.value.$1),
                    onPress: () {
                      setState(() {
                        _selectedIndex = entry.key;
                      });
                    },
                  ),
                )
                .toList(),
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
