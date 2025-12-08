import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Splash screen shown while checking authentication state.
///
/// Displays app branding and a loading indicator while the app
/// initializes and validates the user's session.
class SplashPage extends StatelessWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enterprise',
              style: theme.typography.xl4.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: theme.typography.base.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
