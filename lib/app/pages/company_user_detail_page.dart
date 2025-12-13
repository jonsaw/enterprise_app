import 'package:enterprise/app/entities/company.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/state/company_user_detail_controller.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Company User Detail Page
class CompanyUserDetailPage extends ConsumerWidget {
  /// Creates a [CompanyUserDetailPage].
  const CompanyUserDetailPage({
    required this.companyId,
    required this.userId,
    this.onClose,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the user.
  final String userId;

  /// Optional callback for panel mode. If provided, shows close button instead of back button.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(
      companyUserDetailControllerProvider(companyId, userId),
    );

    return FScaffold(
      header: FHeader.nested(
        title: Text(context.tr.userDetails),
        prefixes: [
          if (onClose != null)
            FHeaderAction(
              icon: const Icon(Icons.close),
              onPress: onClose,
            )
          else
            FHeaderAction.back(
              onPress: () => context.go('/companies/$companyId/users'),
            ),
        ],
      ),
      child: _buildContent(context, ref, userAsync),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CompanyUser?> userAsync,
  ) {
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                const Icon(
                  Icons.person_off,
                  size: 64,
                  color: Colors.grey,
                ),
                Text(
                  context.tr.userNotFound,
                  style: const TextStyle(fontSize: 16),
                ),
                FButton(
                  style: FButtonStyle.outline(),
                  onPress: () => context.go('/companies/$companyId/users'),
                  child: Text(context.tr.backToUsers),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              // User Information Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    context.tr.userInformation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text(context.tr.name),
                        details: Text(
                          user.user?.name ?? context.tr.unknownUser,
                        ),
                      ),
                      FTile(
                        title: Text(context.tr.email),
                        details: Text(user.user?.email ?? '-'),
                      ),
                      FTile(
                        title: Text(context.tr.role),
                        suffix: _buildRoleBadge(context, user.role),
                      ),
                      FTile(
                        title: Text(context.tr.userId),
                        details: Text(user.user?.id ?? '-'),
                      ),
                    ],
                  ),
                ],
              ),

              // Company Information Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    context.tr.companyInformation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text(context.tr.companyName),
                        details: Text(user.company?.name ?? '-'),
                      ),
                      FTile(
                        title: Text(context.tr.companyCode),
                        details: Text(user.company?.code ?? '-'),
                      ),
                      FTile(
                        title: Text(context.tr.companyId),
                        details: Text(user.company?.id ?? '-'),
                      ),
                    ],
                  ),
                ],
              ),

              // Metadata Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    context.tr.metadata,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text(context.tr.createdAt),
                        details: Text(
                          user.createdAt != null
                              ? _formatDateTime(user.createdAt!)
                              : '-',
                        ),
                      ),
                      FTile(
                        title: Text(context.tr.updatedAt),
                        details: Text(
                          user.updatedAt != null
                              ? _formatDateTime(user.updatedAt!)
                              : '-',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: FCircularProgress(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text(
              context.tr.errorLoadingUsers,
              style: const TextStyle(fontSize: 16),
            ),
            FButton(
              style: FButtonStyle.outline(),
              onPress: () {
                ref.invalidate(
                  companyUserDetailControllerProvider(
                    companyId,
                    userId,
                  ),
                );
              },
              child: Text(context.tr.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    switch (role) {
      case Owner():
        return FBadge(
          style: FBadgeStyle.primary(),
          child: Text(context.tr.owner),
        );
      case Manager():
        return FBadge(
          style: FBadgeStyle.secondary(),
          child: Text(context.tr.manager),
        );
      case UserMember():
        return FBadge(
          style: FBadgeStyle.outline(),
          child: Text(context.tr.user),
        );
      case None():
        return FBadge(
          style: FBadgeStyle.outline(),
          child: Text(context.tr.none),
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    return formatter.format(dateTime.toLocal());
  }
}
