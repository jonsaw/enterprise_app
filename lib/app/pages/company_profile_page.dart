import 'package:enterprise/app/state/auth_controller.dart';
import 'package:enterprise/app/widgets/page_app_bar.dart';
import 'package:enterprise/app/widgets/section_widget.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Company profile page
class CompanyProfilePage extends ConsumerWidget {
  /// Creates a [CompanyProfilePage].
  const CompanyProfilePage({super.key});

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
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
            style: FButtonStyle.outline(),
            onPress: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: Text(context.tr.cancel),
          ),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: Text(context.tr.signOut),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).value;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PageAppBar(
              title: context.tr.profilePageTitle,
            ),
          ),

          SectionWidget(
            header: 'Personal Information',
            description: 'Manage your personal details and settings.',
            children: [
              Text(auth?.name ?? ''),
              Text(auth?.email ?? ''),
            ],
          ),
          // Session Management Section
          SectionWidget(
            header: context.tr.sessionManagement,
            description: context.tr.sessionManagementDescription,
            children: [
              FButton(
                style: FButtonStyle.destructive(),
                mainAxisSize: .min,
                onPress: () => _showSignOutDialog(context, ref),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    const Icon(FIcons.logOut, size: 16),
                    const SizedBox(width: 8),
                    Text(context.tr.signOut),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
