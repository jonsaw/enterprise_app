import 'package:enterprise/app/state/auth_controller.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Shows a sign out confirmation dialog and handles the sign out process.
///
/// Returns a [Future] that completes when the dialog is dismissed.
/// If the user confirms, the sign out process will be triggered.
Future<void> showSignOutDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showFDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context, style, animation) => FDialog(
      style: style.call,
      animation: animation,
      title: Text(context.tr.signOutConfirmTitle),
      body: Text(context.tr.signOutConfirmMessage),
      actions: [
        FButton(
          style: FButtonStyle.destructive(),
          onPress: () => Navigator.of(context, rootNavigator: true).pop(true),
          child: Text(context.tr.signOut),
        ),
        FButton(
          style: FButtonStyle.outline(),
          onPress: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
          child: Text(context.tr.cancel),
        ),
      ],
    ),
  );

  if (confirmed ?? false) {
    await ref.read(authControllerProvider.notifier).signOut();
  }
}
