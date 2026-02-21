import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A widget that wraps a form page with unsaved changes protection.
///
/// This widget provides:
/// - PopScope to intercept back button/gestures
/// - Confirmation dialog when there are unsaved changes
/// - Reusable logic across multiple form pages
class UnsavedChangesScope extends StatelessWidget {
  /// Creates an [UnsavedChangesScope].
  const UnsavedChangesScope({
    required this.hasChanges,
    required this.child,
    super.key,
  });

  /// Whether there are unsaved changes.
  final bool hasChanges;

  /// The child widget to wrap.
  final Widget child;

  /// Shows a confirmation dialog asking if user wants to discard changes.
  ///
  /// Returns true if user confirms, false otherwise.
  static Future<bool> showDiscardDialog(BuildContext context) async {
    final confirmed = await showFDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          title: Text(context.tr.unsavedChanges),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(context.tr.unsavedChangesMessage),
            ],
          ),
          actions: [
            // Mobile: [Discard] [Cancel]
            FButton(
              variant: .destructive,
              onPress: () =>
                  Navigator.of(context, rootNavigator: true).pop(true),
              child: Text(context.tr.discard),
            ),
            FButton(
              variant: .outline,
              onPress: () =>
                  Navigator.of(context, rootNavigator: true).pop(false),
              child: Text(context.tr.cancel),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  /// Handles the close action with unsaved changes check.
  ///
  /// Returns true if navigation should proceed, false otherwise.
  static Future<bool> handleClose(
    BuildContext context, {
    required bool hasChanges,
  }) async {
    if (!hasChanges) {
      return true; // Allow navigation
    }

    return showDiscardDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await handleClose(context, hasChanges: hasChanges);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
