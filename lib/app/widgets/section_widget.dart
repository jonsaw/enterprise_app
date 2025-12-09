import 'package:enterprise/app/pages/app_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A reusable Section widget that adapts to screen size.
///
/// On smaller screens (< 768px), displays header, description, and children
/// vertically. On larger screens, displays header/description on the left
/// and children on the right in a two-column layout.
class SectionWidget extends StatelessWidget {
  /// Creates a [SectionWidget].
  const SectionWidget({
    required this.header,
    required this.description,
    required this.children,
    super.key,
  });

  /// The section header.
  final String header;

  /// The section description.
  final String description;

  /// The children widgets (usually form fields or action buttons).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 768 + sidebarWidth;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 32 : 16,
        vertical: isLargeScreen ? 64 : 40,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colors.border),
        ),
      ),
      child: isLargeScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Header and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        header,
                        style: theme.typography.base.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                          height: 1.75,
                        ),
                      ),
                      Text(
                        description,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right column - Children
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: children,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                // Header and description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      header,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                        height: 1.75,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                // Children
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: children,
                ),
              ],
            ),
    );
  }
}
