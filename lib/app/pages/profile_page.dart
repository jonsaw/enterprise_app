import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Profile page
class ProfilePage extends StatelessWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            context.tr.profilePageTitle,
            style: theme.typography.xl3.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.foreground,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr.profilePageContent,
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
