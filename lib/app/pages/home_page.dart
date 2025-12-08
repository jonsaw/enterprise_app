import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Home page - serves as a redirect hub.
///
/// Users should never see this page as the router will redirect
/// them to their role-specific page based on permissions.
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      child: Center(
        child: Text(
          'Redirecting...',
          style: theme.typography.lg.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
