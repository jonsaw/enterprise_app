import 'dart:async';

import 'package:enterprise/app/entities/company_invite.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/state/company_invite_detail_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Company Invite Detail Page
class CompanyInviteDetailPage extends ConsumerStatefulWidget {
  /// Creates a [CompanyInviteDetailPage].
  const CompanyInviteDetailPage({
    required this.companyId,
    required this.inviteId,
    this.onClose,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the invite.
  final String inviteId;

  /// Optional callback for closing the panel (when used in split view).
  final VoidCallback? onClose;

  @override
  ConsumerState<CompanyInviteDetailPage> createState() =>
      _CompanyInviteDetailPageState();
}

class _CompanyInviteDetailPageState
    extends ConsumerState<CompanyInviteDetailPage> {
  bool _tokenVisible = false;

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  void _copyToken(BuildContext context, String token) {
    unawaited(Clipboard.setData(ClipboardData(text: token)));
    showFToast(
      context: context,
      title: Text(context.tr.copiedToClipboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inviteAsync = ref.watch(
      companyInviteDetailControllerProvider(widget.companyId, widget.inviteId),
    );

    // Use FScaffold for mobile/small screen view
    return FScaffold(
      header: AppHeader.nested(
        title: Text(context.tr.inviteDetails),
        prefixes: [
          if (widget.onClose != null)
            FHeaderAction(
              icon: const Icon(FIcons.x),
              onPress: widget.onClose,
            )
          else
            FHeaderAction.back(
              onPress: () =>
                  context.go('/companies/${widget.companyId}/invites'),
            ),
        ],
      ),
      child: SafeArea(
        top: false,
        left: false,
        child: Builder(
          builder: (context) => _buildContent(context, ref, inviteAsync),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CompanyInvite?> inviteAsync,
  ) {
    return inviteAsync.when(
      data: (invite) {
        if (invite == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                const Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                Text(context.tr.inviteNotFound),
                FButton(
                  variant: .outline,
                  onPress: () =>
                      context.go('/companies/${widget.companyId}/invites'),
                  child: Text(context.tr.backToInvites),
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
              // Invite Information Section
              _buildInviteInformationSection(context, invite),

              // Token Information Section
              if (invite.token != null) _buildTokenSection(context, invite),

              // Creator Information Section
              if (invite.createdBy != null)
                _buildCreatorInformationSection(context, invite),

              // Metadata Section
              _buildMetadataSection(context, invite),
            ],
          ),
        );
      },
      loading: () => const Center(child: FCircularProgress()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text(context.tr.errorLoadingInvites),
            FButton(
              variant: .outline,
              onPress: () {
                ref.invalidate(
                  companyInviteDetailControllerProvider(
                    widget.companyId,
                    widget.inviteId,
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

  Widget _buildInviteInformationSection(
    BuildContext context,
    CompanyInvite invite,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.inviteInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.name),
              details: Text(invite.name),
            ),
            FTile(
              title: Text(context.tr.email),
              details: Text(invite.email),
            ),
            FTile(
              title: Text(context.tr.role),
              suffix: _buildRoleBadge(context, invite.role),
            ),
            FTile(
              title: Text(context.tr.status),
              suffix: _buildStatusBadge(context, invite),
            ),
            FTile(
              title: Text(context.tr.inviteId),
              details: Text(
                invite.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenSection(BuildContext context, CompanyInvite invite) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.tokenInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.inviteToken),
              details: GestureDetector(
                onTap: () {
                  setState(() {
                    _tokenVisible = !_tokenVisible;
                  });
                },
                child: Text(
                  _tokenVisible ? invite.token! : '••••••••••••••••',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  FButton(
                    variant: .outline,
                    onPress: () {
                      setState(() {
                        _tokenVisible = !_tokenVisible;
                      });
                    },
                    child: Icon(
                      _tokenVisible ? FIcons.eyeOff : FIcons.eye,
                      size: 16,
                    ),
                  ),
                  FButton(
                    variant: .outline,
                    onPress: () => _copyToken(context, invite.token!),
                    child: const Icon(FIcons.copy, size: 16),
                  ),
                ],
              ),
            ),
            if (invite.tokenExpiresAt != null)
              FTile(
                title: Text(context.tr.tokenExpiresAt),
                details: Text(_formatDateTime(invite.tokenExpiresAt)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatorInformationSection(
    BuildContext context,
    CompanyInvite invite,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.creatorInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.createdBy),
              details: Text(invite.createdBy?.name ?? '-'),
            ),
            FTile(
              title: Text(context.tr.email),
              details: Text(invite.createdBy?.email ?? '-'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, CompanyInvite invite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.metadata,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.createdAt),
              details: Text(_formatDateTime(invite.createdAt)),
            ),
            FTile(
              title: Text(context.tr.updatedAt),
              details: Text(_formatDateTime(invite.updatedAt)),
            ),
            if (invite.readAt != null)
              FTile(
                title: Text(context.tr.readAt),
                details: Text(_formatDateTime(invite.readAt)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, CompanyInvite invite) {
    final now = DateTime.now();
    final isExpired =
        invite.tokenExpiresAt != null && invite.tokenExpiresAt!.isBefore(now);

    if (isExpired) {
      return FBadge(
        variant: .destructive,
        child: Text(context.tr.expired),
      );
    }

    return FBadge(
      child: Text(context.tr.pending),
    );
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    switch (role) {
      case Owner():
        return FBadge(
          child: Text(context.tr.owner),
        );
      case Manager():
        return FBadge(
          variant: .secondary,
          child: Text(context.tr.manager),
        );
      case UserMember():
        return FBadge(
          variant: .outline,
          child: Text(context.tr.user),
        );
      case None():
        return FBadge(
          variant: .outline,
          child: Text(context.tr.none),
        );
    }
  }
}
