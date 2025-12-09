import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Home page
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

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
            context.tr.homePageTitle,
            style: theme.typography.xl3.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.foreground,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr.homePageContent,
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
