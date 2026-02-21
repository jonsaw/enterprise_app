import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/company_invite_detail_page.dart';
import 'package:enterprise/app/pages/create_company_invite_page.dart';
import 'package:enterprise/app/state/company_invites_controller.dart';
import 'package:enterprise/app/state/selected_id_provider.dart';
import 'package:enterprise/app/state/split_view_size_provider.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/app_sidebar.dart';
import 'package:enterprise/app/widgets/resizable_split_view.dart';
import 'package:enterprise/app/widgets/selectable_tile.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

/// Company Invites Page
class CompanyInvitesPage extends ConsumerStatefulWidget {
  /// Creates a [CompanyInvitesPage].
  const CompanyInvitesPage({required this.companyId, super.key});

  /// The ID of the company.
  final String companyId;

  @override
  ConsumerState<CompanyInvitesPage> createState() => _CompanyInvitesPageState();
}

class _CompanyInvitesPageState extends ConsumerState<CompanyInvitesPage> {
  int _currentPage = 1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  static const int _pageSize = 20;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(TextEditingValue value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.text;
        _currentPage = 1; // Reset to first page on search
      });
    });
  }

  void _onNextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _onPreviousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  void _onInviteTap(String inviteId) {
    ref.read(selectedIdProvider(SelectedIdType.invite).notifier).id = inviteId;
    if (!isMediumOrLargeScreen(context)) {
      // On small/medium screens, push the detail route
      context.go('/companies/${widget.companyId}/invites/$inviteId');
    }
    // On large screens, just update the selected ID (split view handles it)
  }

  @override
  Widget build(BuildContext context) {
    final invitesAsync = ref.watch(
      companyInvitesControllerProvider(
        widget.companyId,
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ),
    );
    final selectedInviteId = ref.watch(
      selectedIdProvider(SelectedIdType.invite),
    );
    final theme = context.theme;

    final invitesList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        FTextField(
          control: .managed(
            controller: _searchController,
            onChange: _onSearchChanged,
          ),
          hint: context.tr.searchInvites,
        ),

        const SizedBox(height: 16),

        // Content area
        Expanded(
          child: invitesAsync.when(
            data: (paginatedInvites) {
              if (paginatedInvites.items.isEmpty) {
                return _buildNoticeContainer(
                  context,
                  Text(
                    context.tr.noInvitesFound,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // Invites list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FTileGroup.builder(
                        count: paginatedInvites.items.length,
                        tileBuilder: (context, index) {
                          final invite = paginatedInvites.items[index];
                          final isSelected =
                              invite.id ==
                              ref.watch(
                                selectedIdProvider(SelectedIdType.invite),
                              );
                          return SelectableTile(
                            title: Text(invite.name),
                            subtitle: Text(invite.email),
                            suffix: _buildRoleBadge(context, invite.role),
                            onPress: () => _onInviteTap(invite.id),
                            selected: isSelected,
                          );
                        },
                      ),
                    ),
                  ),

                  // Pagination controls
                  if (paginatedInvites.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        FButton(
                          variant: .outline,
                          onPress: paginatedInvites.hasPreviousPage
                              ? _onPreviousPage
                              : null,
                          child: Text(context.tr.previous),
                        ),
                        Text(
                          '${context.tr.page} $_currentPage ${context.tr.ofPage} ${paginatedInvites.totalPages}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        FButton(
                          variant: .outline,
                          onPress: paginatedInvites.hasNextPage
                              ? _onNextPage
                              : null,
                          child: Text(context.tr.next),
                        ),
                      ],
                    ),
                ],
              );
            },
            loading: () => _buildNoticeContainer(
              context,
              const FCircularProgress(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Text(
                    context.tr.errorLoadingInvites,
                    style: const TextStyle(fontSize: 16),
                  ),
                  FButton(
                    variant: .outline,
                    onPress: () {
                      ref.invalidate(
                        companyInvitesControllerProvider(
                          widget.companyId,
                          page: _currentPage,
                          pageSize: _pageSize,
                          search: _searchQuery.isEmpty ? null : _searchQuery,
                        ),
                      );
                    },
                    child: Text(context.tr.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    // On large screens, use resizable layout
    if (isMediumOrLargeScreen(context)) {
      return ResizableSplitView(
        sizeGroup: companyPagesGroup,
        leftPanel: FScaffold(
          header: AppHeader(
            safeAreaRight: false,
            title: Text(context.tr.invites),
            prefixes: [
              if (isMediumScreen(context))
                AppSidebarIconButton(companyId: widget.companyId),
            ],
            suffixes: [
              FButton.icon(
                variant: .ghost,
                onPress: () {
                  if (isMediumOrLargeScreen(context)) {
                    // Show as sheet on larger screens
                    unawaited(
                      showFSheet<void>(
                        useRootNavigator: true,
                        context: context,
                        side: FLayout.rtl,
                        builder: (context) => CreateCompanyInvitePage(
                          companyId: widget.companyId,
                          showAsSheet: true,
                          onSuccess: () {
                            ref.invalidate(companyInvitesControllerProvider);
                          },
                        ),
                      ),
                    );
                  } else {
                    // Push as route on mobile screens
                    unawaited(
                      context
                          .push(
                            '/companies/${widget.companyId}/invites/create',
                          )
                          .then((_) {
                            // Refresh the list when returning from create page
                            ref.invalidate(companyInvitesControllerProvider);
                          }),
                    );
                  }
                },
                child: const Icon(FIcons.plus),
              ),
            ],
          ),
          child: SafeArea(
            right: false,
            bottom: false,
            child: invitesList,
          ),
        ),
        rightPanel: selectedInviteId != null
            ? CompanyInviteDetailPage(
                companyId: widget.companyId,
                inviteId: selectedInviteId,
                onClose: () {
                  ref
                          .read(
                            selectedIdProvider(SelectedIdType.invite).notifier,
                          )
                          .id =
                      null;
                },
              )
            : FScaffold(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 64,
                        color: theme.colors.mutedForeground,
                      ),
                      Text(
                        context.tr.selectInviteToViewDetails,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    return FScaffold(
      header: AppHeader(
        title: Text(context.tr.invites),
        prefixes: [
          if (isSmallScreen(context))
            AppSidebarIconButton(
              companyId: widget.companyId,
            ),
        ],
        suffixes: [
          FButton.icon(
            onPress: () {
              unawaited(
                context
                    .push(
                      '/companies/${widget.companyId}/invites/create',
                    )
                    .then((_) {
                      // Refresh the list when returning from create page
                      ref.invalidate(companyInvitesControllerProvider);
                    }),
              );
            },
            child: const Icon(FIcons.plus),
          ),
        ],
      ),
      child: SafeArea(top: false, left: false, child: invitesList),
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

  Widget _buildNoticeContainer(BuildContext context, Widget notice) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colors.border,
              ),
            ),
            child: Center(child: notice),
          ),
        ),
      ],
    );
  }
}
