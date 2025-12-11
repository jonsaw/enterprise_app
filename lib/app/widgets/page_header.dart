import 'package:enterprise/app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Page header widget used in pages
class PageHeader extends StatelessWidget {
  /// Creates a [PageHeader].
  const PageHeader({required this.title, super.key});

  /// The title of the page.
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 768 + sidebarWidth;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 32 : 16,
        vertical: isLargeScreen ? 24 : 0,
      ),
      child: Text(
        title,
        style: theme.typography.xl3.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colors.foreground,
        ),
      ),
    );
  }
}
