import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

/// Company shell page that shows sidebar on medium+ screens
/// This wraps all company-related routes to ensure sidebar persistence
class CompanyShellPage extends ConsumerWidget {
  /// Creates a [CompanyShellPage].
  const CompanyShellPage({
    required this.child,
    required this.companyId,
    super.key,
  });

  /// The child widget to display (content area)
  final Widget child;

  /// The ID of the company
  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    // On medium+ screens, show sidebar + content
    if (isMediumScreen(context)) {
      return FScaffold(
        childPad: false,
        sidebar: AppSidebar(companyId: companyId, currentPath: currentPath),
        child: child,
      );
    }

    // On small screens, just show content (no sidebar)
    return child;
  }
}
